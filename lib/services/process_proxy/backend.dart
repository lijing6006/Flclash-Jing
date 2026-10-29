import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'policy.dart';
import 'applications.dart';

const processProxyBackendVersion = '1.3.5';
const processProxyCoreFiles = [
  'ProxyLane.exe',
  'ProxyLane64.exe',
  'ProxyLaneHook32.dll',
  'ProxyLaneHook64.dll',
];
const processProxyOptionalFiles = [
  'ProxyLaneMitm64.dll',
  'ProxyLaneSecureTransport64.dll',
  'LICENSE',
];

class ProcessProxyCandidate {
  final int pid;
  final String name;
  final String executable;

  const ProcessProxyCandidate({
    required this.pid,
    required this.name,
    required this.executable,
  });
}

List<ProcessProxyCandidate> parseProcessCandidates(String data, String query) {
  final decoded = jsonDecode(data.trim().isEmpty ? '[]' : data);
  final rows = decoded is List ? decoded : [decoded];
  final needle = query.trim().toLowerCase();
  final result = <ProcessProxyCandidate>[];
  for (final row in rows.take(10000)) {
    if (row is! Map) continue;
    final id = row['ProcessId'];
    final name = row['Name'];
    final executable = row['ExecutablePath'];
    if (id is! int || id <= 0 || name is! String || executable is! String) {
      continue;
    }
    try {
      validateExecutablePath(executable);
    } on ProcessProxyException {
      continue;
    }
    if (needle.isNotEmpty &&
        !'$id $name $executable'.toLowerCase().contains(needle)) {
      continue;
    }
    result.add(
      ProcessProxyCandidate(pid: id, name: name, executable: executable),
    );
    if (result.length == 200) break;
  }
  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return result;
}

String get _powershell {
  final root = Platform.environment['SystemRoot'];
  if (root == null || !RegExp(r'^[a-zA-Z]:\\').hasMatch(root)) {
    throw const ProcessProxyException('windowsUnavailable');
  }
  return '$root\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
}

Future<String> _runPowerShell(
  String script, {
  Map<String, String> environment = const {},
}) async {
  final process = await Process.start(
    _powershell,
    ['-NoLogo', '-NoProfile', '-NonInteractive', '-Command', script],
    environment: environment,
    runInShell: false,
  );
  final output = _readBounded(process, process.stdout);
  final errors = process.stderr.drain<void>();
  try {
    final results = await Future.wait<Object?>([
      process.exitCode,
      output,
      errors,
    ]).timeout(const Duration(seconds: 15));
    if (results[0] != 0) {
      throw const ProcessProxyException('windowsQueryFailed');
    }
    return results[1] as String;
  } on TimeoutException {
    process.kill();
    throw const ProcessProxyException('windowsQueryTimeout');
  }
}

Future<String> _readBounded(Process process, Stream<List<int>> stream) async {
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    if (bytes.length + chunk.length > 4 * 1024 * 1024) {
      process.kill();
      throw const ProcessProxyException('responseTooLarge');
    }
    bytes.add(chunk);
  }
  return utf8.decode(bytes.takeBytes());
}

Future<List<ProcessProxyCandidate>> searchWindowsProcesses(String query) async {
  final data = await _runPowerShell(r'''
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$session = (Get-Process -Id $PID).SessionId
@(Get-CimInstance Win32_Process -Filter "SessionId=$session" |
  Where-Object { $_.ExecutablePath } |
  Select-Object -First 10000 ProcessId,Name,ExecutablePath) | ConvertTo-Json -Compress
''');
  return parseProcessCandidates(data, query);
}

Future<List<ProcessProxyApplication>> searchWindowsApplications(
  String query,
) async {
  final data = await _runPowerShell(processProxyApplicationQuery);
  return parseApplicationCandidates(data, query);
}

Future<void> verifyBackendVersion(String directory) async {
  final data = await _runPowerShell(
    r'''
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$names = 'ProxyLane.exe','ProxyLane64.exe','ProxyLaneHook32.dll','ProxyLaneHook64.dll'
@($names | ForEach-Object {
  $p = Join-Path $env:FLCLASH_BACKEND_DIRECTORY $_
  $v = (Get-Item -LiteralPath $p).VersionInfo
  "$($v.FileMajorPart).$($v.FileMinorPart).$($v.FileBuildPart)"
}) | ConvertTo-Json -Compress
''',
    environment: {'FLCLASH_BACKEND_DIRECTORY': directory},
  );
  final versions = jsonDecode(data);
  if (versions is! List ||
      versions.length != processProxyCoreFiles.length ||
      versions.any((v) => !RegExp(r'^1\.[23]\.').hasMatch(v.toString()))) {
    throw const ProcessProxyException('backendVersionMismatch');
  }
}

Future<void> revealBackendWindow(int pid, String executable) async {
  await _runPowerShell(
    r'''
$ErrorActionPreference = 'Stop'
$p = Get-Process -Id ([int]$env:FLCLASH_BACKEND_PID) -ErrorAction Stop
if ($p.Path -ne $env:FLCLASH_BACKEND_EXECUTABLE) { throw 'Process identity changed' }
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class FlClashWindow {
  public delegate bool Callback(IntPtr hwnd, IntPtr parameter);
  [DllImport("user32.dll")] public static extern bool EnumWindows(Callback callback, IntPtr parameter);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
  [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hwnd, int show);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
}
'@
$script:found = $false
$wanted = [uint32]$p.Id
[FlClashWindow]::EnumWindows({ param($hwnd,$parameter)
  [uint32]$owner = 0
  [void][FlClashWindow]::GetWindowThreadProcessId($hwnd,[ref]$owner)
  if ($owner -eq $wanted) {
    [void][FlClashWindow]::ShowWindowAsync($hwnd,9)
    [void][FlClashWindow]::SetForegroundWindow($hwnd)
    $script:found = $true
    return $false
  }
  return $true
},[IntPtr]::Zero) | Out-Null
if (-not $script:found) { throw 'No backend window' }
''',
    environment: {
      'FLCLASH_BACKEND_PID': '$pid',
      'FLCLASH_BACKEND_EXECUTABLE': executable,
    },
  );
}

Future<void> probeProcessProxyEndpoint(ProcessProxyEndpoint endpoint) async {
  Socket? socket;
  StreamIterator<List<int>>? reader;
  final pending = <int>[];
  Future<List<int>> readBytes(int count) async {
    while (pending.length < count) {
      if (!await reader!.moveNext().timeout(const Duration(seconds: 3))) {
        throw const ProcessProxyException('listenerHandshakeFailed');
      }
      pending.addAll(reader!.current);
      if (pending.length > 8192) {
        throw const ProcessProxyException('listenerHandshakeFailed');
      }
    }
    final result = pending.take(count).toList();
    pending.removeRange(0, count);
    return result;
  }

  try {
    socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      endpoint.port,
      timeout: const Duration(seconds: 3),
    );
    reader = StreamIterator(socket);
    if (endpoint.type == 'SOCKS5') {
      socket.add(endpoint.username.isEmpty ? [5, 1, 0] : [5, 1, 2]);
      await socket.flush();
      final answer = await readBytes(2);
      final expected = endpoint.username.isEmpty ? 0 : 2;
      if (answer[0] != 5 || answer[1] != expected) {
        throw const ProcessProxyException('listenerHandshakeFailed');
      }
      if (expected == 2) {
        final user = utf8.encode(endpoint.username);
        final pass = utf8.encode(endpoint.password);
        if (user.isEmpty || user.length > 255 || pass.length > 255) {
          throw const ProcessProxyException('invalidAuthentication');
        }
        socket.add([1, user.length, ...user, pass.length, ...pass]);
        await socket.flush();
        final auth = await readBytes(2);
        if (auth[0] != 1 || auth[1] != 0) {
          throw const ProcessProxyException('listenerAuthenticationFailed');
        }
      }
    } else {
      final auth = endpoint.username.isEmpty
          ? ''
          : 'Proxy-Authorization: Basic ${base64Encode(utf8.encode('${endpoint.username}:${endpoint.password}'))}\r\n';
      socket.add(
        ascii.encode(
          'HEAD / HTTP/1.1\r\nHost: localhost\r\n${auth}Connection: close\r\n\r\n',
        ),
      );
      await socket.flush();
      while (!pending.contains(10)) {
        if (!await reader.moveNext().timeout(const Duration(seconds: 3))) break;
        pending.addAll(reader.current);
        if (pending.length > 8192) break;
      }
      final status = ascii
          .decode(pending, allowInvalid: true)
          .split('\r\n')
          .first;
      if (!RegExp(r'^HTTP/1\.[01] [1-5][0-9][0-9]').hasMatch(status)) {
        throw const ProcessProxyException('listenerHandshakeFailed');
      }
      if (status.startsWith('HTTP/1.1 407') ||
          status.startsWith('HTTP/1.0 407')) {
        throw const ProcessProxyException('listenerAuthenticationFailed');
      }
    }
  } on ProcessProxyException {
    rethrow;
  } on Exception {
    throw const ProcessProxyException('listenerUnavailable');
  } finally {
    socket?.destroy();
    await reader?.cancel();
  }
}
