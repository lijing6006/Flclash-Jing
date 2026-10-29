import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'process_proxy/backend.dart';
import 'process_proxy/policy.dart';

export 'process_proxy/backend.dart' show ProcessProxyCandidate;
export 'process_proxy/policy.dart';

class ProcessProxySession {
  final String id;
  final String executable;
  final int backendPid;
  final String backendExecutable;
  final String status;
  final int? exitCode;

  const ProcessProxySession({
    required this.id,
    required this.executable,
    required this.backendPid,
    required this.backendExecutable,
    required this.status,
    this.exitCode,
  });
}

class ProcessProxyService extends ChangeNotifier {
  bool _busy = false;
  bool _disposed = false;
  final List<ProcessProxySession> _sessions = [];

  bool get busy => _busy;
  List<ProcessProxySession> get sessions => List.unmodifiable(_sessions);

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<Directory> _root() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'process-proxy'))
        .create(recursive: true);
  }

  Future<ProcessProxyLaunchRequest?> loadSettings() async {
    final file = File(p.join((await _root()).path, 'settings.json'));
    if (!await file.exists()) return null;
    if (await file.length() > 65536) {
      throw const ProcessProxyException('invalidSettings');
    }
    try {
      final json = jsonDecode(await file.readAsString());
      return ProcessProxyLaunchRequest.fromJson(json as Map<String, dynamic>);
    } on Exception {
      throw const ProcessProxyException('invalidSettings');
    }
  }

  Future<void> saveSettings(ProcessProxyLaunchRequest request) async {
    final file = File(p.join((await _root()).path, 'settings.json'));
    final temp = File('${file.path}.pending');
    await temp.writeAsString(jsonEncode(request.toJson()), flush: true);
    await temp.rename(file.path);
  }

  Future<List<ProcessProxyCandidate>> searchProcesses(String query) async {
    if (!Platform.isWindows) return [];
    return searchWindowsProcesses(query);
  }

  Future<void> launch({
    required ProcessProxyLaunchRequest request,
    required Future<ProcessProxyRuntime> Function() runtime,
  }) async {
    if (_busy) throw const ProcessProxyException('launchBusy');
    if (_disposed) throw const ProcessProxyException('serviceDisposed');
    if (!Platform.isWindows) {
      throw const ProcessProxyException('windowsOnly');
    }
    _busy = true;
    _changed();
    Directory? sessionDirectory;
    var started = false;
    try {
      request.validate();
      final endpoint = (await runtime()).endpoint;
      final source = p.windows.dirname(request.backendPath);
      for (final path in [
        request.executable,
        ...processProxyCoreFiles.map((name) => p.windows.join(source, name)),
      ]) {
        if (await FileSystemEntity.type(path, followLinks: false) !=
            FileSystemEntityType.file) {
          throw const ProcessProxyException('missingExecutable');
        }
      }
      await verifyBackendVersion(source);
      await probeProcessProxyEndpoint(endpoint);
      final root = await _root();
      final sessionsRoot = await Directory(p.join(root.path, 'sessions'))
          .create(recursive: true);
      sessionDirectory = await sessionsRoot.createTemp('session_');
      final id = p
          .basename(sessionDirectory.path)
          .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
      final profile = 'FlClash_$id';
      for (final name in [
        ...processProxyCoreFiles,
        ...processProxyOptionalFiles,
      ]) {
        final original = p.windows.join(source, name);
        if (await FileSystemEntity.type(original, followLinks: false) !=
            FileSystemEntityType.file) {
          if (processProxyCoreFiles.contains(name)) {
            throw const ProcessProxyException('missingBackendComponent');
          }
          continue;
        }
        await File(original).copy(p.join(sessionDirectory.path, name));
      }
      if ((request.decryptHttps || request.decryptQuic) &&
          !await File(p.join(sessionDirectory.path, 'ProxyLaneMitm64.dll'))
              .exists()) {
        throw const ProcessProxyException('missingAdvancedModule');
      }
      final ini = buildProcessProxyIni(request, endpoint, profile);
      await File(p.join(sessionDirectory.path, 'ProxyLane.ini'))
          .writeAsBytes(encodeProcessProxyIni(ini), flush: true);
      final latest = (await runtime()).endpoint;
      if (!endpoint.sameAs(latest)) {
        throw const ProcessProxyException('coreConfigurationChanged');
      }
      if (_disposed) throw const ProcessProxyException('serviceDisposed');
      final executable = p.join(sessionDirectory.path, 'ProxyLane64.exe');
      final process = await Process.start(
        executable,
        [
          '--auto',
          '--profile',
          profile,
          '--run',
          request.executable,
          if (request.arguments.isNotEmpty) ...['--', ...request.arguments],
        ],
        workingDirectory: sessionDirectory.path,
        runInShell: false,
      );
      started = true;
      unawaited(process.stdout.drain<void>());
      unawaited(process.stderr.drain<void>());
      _sessions.insert(
        0,
        ProcessProxySession(
          id: id,
          executable: request.executable,
          backendPid: process.pid,
          backendExecutable: executable,
          status: 'backendRunning',
        ),
      );
      _changed();
      unawaited(
        process.exitCode.then((code) {
          final index = _sessions.indexWhere((s) => s.id == id);
          if (index < 0) return;
          _sessions[index] = ProcessProxySession(
            id: id,
            executable: request.executable,
            backendPid: process.pid,
            backendExecutable: executable,
            status: code == 0 ? 'exited' : 'failed',
            exitCode: code,
          );
          _changed();
        }),
      );
    } on ProcessProxyException {
      rethrow;
    } on Exception {
      throw const ProcessProxyException('launchFailed');
    } finally {
      if (!started && sessionDirectory != null) {
        await sessionDirectory
            .delete(recursive: true)
            .catchError((_) => sessionDirectory!);
      }
      _busy = false;
      _changed();
    }
  }

  Future<void> showBackendWindow(String id) async {
    final selected = _sessions.where((s) => s.id == id).firstOrNull;
    if (selected == null || selected.status != 'backendRunning') {
      throw const ProcessProxyException('sessionUnavailable');
    }
    await revealBackendWindow(selected.backendPid, selected.backendExecutable);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
