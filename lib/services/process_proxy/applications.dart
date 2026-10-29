import 'dart:convert';

import 'policy.dart';

class ProcessProxyApplication {
  final String name;
  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final String source;

  const ProcessProxyApplication({
    required this.name,
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.source,
  });
}

List<ProcessProxyApplication> parseApplicationCandidates(
  String data,
  String query,
) {
  if (data.length > 4 * 1024 * 1024) {
    throw const ProcessProxyException('responseTooLarge');
  }
  final decoded = jsonDecode(data.trim().isEmpty ? '[]' : data);
  final rows = decoded is List ? decoded : [decoded];
  final needle = query.trim().toLowerCase();
  final unique = <String>{};
  final result = <ProcessProxyApplication>[];
  for (final row in rows.take(10000)) {
    if (row is! Map) continue;
    final name = row['Name'];
    final executable = row['ExecutablePath'];
    final arguments = row['Arguments'];
    final directory = row['WorkingDirectory'];
    final source = row['Source'];
    if (name is! String ||
        name.isEmpty ||
        name.length > 256 ||
        name.contains(RegExp(r'[\x00-\x1f]')) ||
        executable is! String ||
        arguments is! List ||
        arguments.any((v) => v is! String) ||
        directory is! String ||
        !const {'app-paths', 'start-menu'}.contains(source)) {
      continue;
    }
    final args = arguments.cast<String>();
    try {
      validateExecutablePath(executable);
      validateWorkingDirectoryPath(directory);
      if (args.length > 128 ||
          args.fold<int>(0, (n, a) => n + a.length) > 16000 ||
          args.any((a) => a.contains('\x00'))) {
        continue;
      }
    } on ProcessProxyException {
      continue;
    }
    if (needle.isNotEmpty &&
        !'$name $executable'.toLowerCase().contains(needle)) {
      continue;
    }
    final identity = jsonEncode([
      executable.replaceAll('/', r'\').toLowerCase(),
      args,
      directory.replaceAll('/', r'\').toLowerCase(),
    ]);
    if (!unique.add(identity)) continue;
    result.add(
      ProcessProxyApplication(
        name: name,
        executable: executable,
        arguments: List.unmodifiable(args),
        workingDirectory: directory,
        source: source as String,
      ),
    );
    if (result.length == 200) break;
  }
  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return result;
}

const processProxyApplicationQuery = r'''
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class FlClashArguments {
  [DllImport("shell32.dll", CharSet=CharSet.Unicode)] static extern IntPtr CommandLineToArgvW(string command, out int count);
  [DllImport("kernel32.dll")] static extern IntPtr LocalFree(IntPtr memory);
  public static string[] Parse(string text) {
    if (String.IsNullOrEmpty(text)) return new string[0];
    int count; IntPtr block = CommandLineToArgvW("application.exe " + text, out count);
    if (block == IntPtr.Zero) throw new InvalidOperationException();
    try {
      if (count > 129) throw new InvalidOperationException();
      string[] result = new string[count - 1];
      for (int i = 1; i < count; i++) result[i - 1] = Marshal.PtrToStringUni(Marshal.ReadIntPtr(block, i * IntPtr.Size));
      return result;
    } finally { LocalFree(block); }
  }
}
'@
$rows = New-Object 'System.Collections.Generic.List[object]'
function Add-Application($name, $target, $arguments, $directory, $source) {
  if ($rows.Count -ge 10000) { return }
  $target = [Environment]::ExpandEnvironmentVariables([string]$target)
  $directory = [Environment]::ExpandEnvironmentVariables([string]$directory)
  if ($target.Length -ge 2 -and $target[0] -eq '"' -and $target[$target.Length-1] -eq '"') { $target = $target.Substring(1,$target.Length-2) }
  if ($target -notmatch '^[A-Za-z]:[\\/]' -or $target -notmatch '(?i)\.exe$') { return }
  if ($directory -and $directory -notmatch '^[A-Za-z]:[\\/]') { return }
  if ([string]$arguments -and ([string]$arguments).Length -gt 16000) { return }
  $item = Get-Item -LiteralPath $target -ErrorAction SilentlyContinue
  if (-not $item -or $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return }
  $argsList = [FlClashArguments]::Parse([string]$arguments)
  $rows.Add([pscustomobject]@{ Name=[string]$name; ExecutablePath=$target; Arguments=@($argsList); WorkingDirectory=$directory; Source=$source })
}
foreach ($hive in @([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryHive]::LocalMachine)) {
  foreach ($view in @([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
    $root = $null; $paths = $null
    try {
      $root = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $view)
      $paths = $root.OpenSubKey('Software\Microsoft\Windows\CurrentVersion\App Paths', $false)
      if ($paths) {
        foreach ($name in ($paths.GetSubKeyNames() | Select-Object -First 4096)) {
          $app = $null
          try {
            $app = $paths.OpenSubKey($name, $false)
            if ($app) { Add-Application $name ($app.GetValue('')) '' '' 'app-paths' }
          } catch { } finally { if ($app) { $app.Dispose() } }
        }
      }
    } catch { } finally { if ($paths) { $paths.Dispose() }; if ($root) { $root.Dispose() } }
  }
}
$shell = New-Object -ComObject WScript.Shell
$visited = 0
function Read-StartMenu($directory, $depth) {
  if ($depth -gt 12 -or $script:visited -ge 10000 -or $rows.Count -ge 10000) { return }
  if ($directory -notmatch '^[A-Za-z]:[\\/]') { return }
  $rootItem = Get-Item -LiteralPath $directory -ErrorAction SilentlyContinue
  if (-not $rootItem -or ($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return }
  foreach ($entry in (Get-ChildItem -LiteralPath $directory -ErrorAction SilentlyContinue)) {
    $script:visited++
    if ($script:visited -gt 10000) { break }
    if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
    if ($entry.PSIsContainer) { Read-StartMenu $entry.FullName ($depth + 1) }
    elseif ($entry.Extension -ieq '.lnk') {
      $link = $null
      try {
        $link = $shell.CreateShortcut($entry.FullName)
        Add-Application $entry.BaseName $link.TargetPath $link.Arguments $link.WorkingDirectory 'start-menu'
      } catch { } finally { if ($link) { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($link) } }
    }
  }
}
try {
  Read-StartMenu ([Environment]::GetFolderPath('Programs')) 0
  Read-StartMenu ([Environment]::GetFolderPath('CommonPrograms')) 0
} finally { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($shell) }
ConvertTo-Json -InputObject @($rows.ToArray()) -Compress -Depth 4
''';
