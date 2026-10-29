import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'process_proxy/backend.dart';
import 'process_proxy/applications.dart';
import 'process_proxy/bridge_client.dart';
import 'process_proxy/policy.dart';
import 'process_proxy/runtime_lease.dart';

export 'process_proxy/backend.dart' show ProcessProxyCandidate;
export 'process_proxy/applications.dart' show ProcessProxyApplication;
export 'process_proxy/policy.dart';
export 'process_proxy/runtime_lease.dart';

class ProcessProxySession {
  final String id;
  final String executable;
  final int backendPid;
  final String backendExecutable;
  final String status;
  final int? exitCode;
  final bool nativeBridge;
  final int? targetPid;

  const ProcessProxySession({
    required this.id,
    required this.executable,
    required this.backendPid,
    required this.backendExecutable,
    required this.status,
    this.exitCode,
    this.nativeBridge = false,
    this.targetPid,
  });
}

class ProcessProxyService extends ChangeNotifier {
  static final shared = ProcessProxyService();
  final Map<String, ProcessProxyBridgeClient> _bridges = {};
  final Map<String, Future<ProcessProxyRuntime> Function()> _runtimeChecks = {};
  final Map<String, ProcessProxyRuntimeLease> _runtimeLeases = {};
  final Map<String, void Function()> _runtimeSubscriptions = {};
  final Map<String, Process> _compatibilityProcesses = {};
  final Set<String> _invalidated = {};
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
    return Directory(
      p.join(support.path, 'process-proxy'),
    ).create(recursive: true);
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
    if (_busy) throw const ProcessProxyException('launchBusy');
    if (_disposed) throw const ProcessProxyException('serviceDisposed');
    _busy = true;
    _changed();
    try {
      final file = File(p.join((await _root()).path, 'settings.json'));
      final temp = File('${file.path}.pending');
      await temp.writeAsString(jsonEncode(request.toJson()), flush: true);
      await temp.rename(file.path);
    } finally {
      _busy = false;
      _changed();
    }
  }

  Future<List<ProcessProxyCandidate>> searchProcesses(String query) async {
    if (!Platform.isWindows) return [];
    return searchWindowsProcesses(query);
  }

  Future<List<ProcessProxyApplication>> searchApplications(String query) async {
    if (!Platform.isWindows) return [];
    return searchWindowsApplications(query);
  }

  Future<void> launch({
    required ProcessProxyLaunchRequest request,
    required Future<ProcessProxyRuntime> Function() runtime,
    required ProcessProxyRuntimeObserver observeRuntime,
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
    var tracked = false;
    ProcessProxyRuntimeLease? lease;
    void Function()? unsubscribe;
    Process? compatibilityProcess;
    String? trackedId;
    try {
      request.validate();
      var changedDuringSetup = false;
      unsubscribe = observeRuntime((current) {
        final activeLease = lease;
        if (activeLease == null) {
          changedDuringSetup = true;
        } else {
          activeLease.observe(current);
        }
      });
      final initialRuntime = await runtime();
      if (changedDuringSetup) {
        throw const ProcessProxyException('coreConfigurationChanged');
      }
      lease = ProcessProxyRuntimeLease(initialRuntime, () {
        if (tracked && trackedId != null) {
          unawaited(_invalidateSession(trackedId));
        }
      });
      final endpoint = lease.endpoint;
      validateProcessProxyAuthentication(endpoint);
      if (request.prepareQuic && endpoint.type != 'SOCKS5') {
        throw const ProcessProxyException('quicNeedsSocks');
      }
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
      final sessionsRoot = await Directory(
        p.join(root.path, 'sessions'),
      ).create(recursive: true);
      sessionDirectory = await sessionsRoot.createTemp('session_');
      for (final name in [
        ...processProxyCoreFiles,
        ...processProxyOptionalFiles.where((name) => name.endsWith('.dll')),
        'FlClashProxyBridge.exe',
      ]) {
        if (utf8.encode(p.join(sessionDirectory.path, name)).length > 240) {
          throw const ProcessProxyException('pathTooLong');
        }
      }
      final id = p
          .basename(sessionDirectory.path)
          .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
      trackedId = id;
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
      if ((request.decryptHttps ||
              request.decryptQuic ||
              request.prepareQuic) &&
          !await File(
            p.join(sessionDirectory.path, 'ProxyLaneMitm64.dll'),
          ).exists()) {
        throw const ProcessProxyException('missingAdvancedModule');
      }
      lease.requireCurrent(await runtime());
      if (_disposed) throw const ProcessProxyException('serviceDisposed');
      final packagedBridge = File(
        p.join(
          p.dirname(Platform.resolvedExecutable),
          'FlClashProxyBridge.exe',
        ),
      );
      if (await packagedBridge.exists()) {
        final executable = p.join(
          sessionDirectory.path,
          'FlClashProxyBridge.exe',
        );
        await packagedBridge.copy(executable);
        final bridge = await ProcessProxyBridgeClient.start(executable);
        _bridges[id] = bridge;
        try {
          await bridge.request('configure', {
            'backend_directory': sessionDirectory.path,
            'port': endpoint.port,
            'proxy_type': endpoint.type,
            'username': endpoint.username,
            'password': endpoint.password,
            'children': request.includeChildren,
            'block_udp': request.blockUdp,
            'remote_dns': request.remoteDns,
            'prepare_quic': request.prepareQuic,
            'confirm_quic': request.prepareQuic,
            'include_targets': compileProxyOnlyRules(request.proxyOnlyRules),
            'child_filter': compileChildRules(request.childRules),
            'child_filter_mode': request.childRuleInclude
                ? 'include'
                : 'exclude',
            'bypass': compileBypassRules(
              request.bypassRules,
              privateNetworks: request.bypassPrivateNetworks,
            ),
          });
          lease.requireCurrent(await runtime());
          if (_disposed) throw const ProcessProxyException('serviceDisposed');
          final launched = await bridge.request('launch', {
            'executable': request.executable,
            'arguments': request.arguments,
            'working_directory': request.workingDirectory,
            'confirm': true,
          });
          started = true;
          lease.requireCurrent(await runtime());
          _runtimeChecks[id] = runtime;
          _runtimeLeases[id] = lease;
          _runtimeSubscriptions[id] = unsubscribe;
          tracked = true;
          _trackSession(
            ProcessProxySession(
              id: id,
              executable: request.executable,
              backendPid: bridge.processId,
              backendExecutable: executable,
              status: 'backendRunning',
              nativeBridge: true,
              targetPid: launched['target_pid'] as int?,
            ),
            bridge.processExit!,
          );
        } catch (_) {
          _bridges.remove(id);
          await bridge.close();
          rethrow;
        }
      } else {
        if (request.prepareQuic ||
            request.workingDirectory.isNotEmpty ||
            request.proxyOnlyRules.trim().isNotEmpty ||
            request.childRules.trim().isNotEmpty) {
          throw const ProcessProxyException('nativeBridgeRequired');
        }
        final ini = buildProcessProxyIni(request, endpoint, profile);
        await File(
          p.join(sessionDirectory.path, 'ProxyLane.ini'),
        ).writeAsBytes(encodeProcessProxyIni(ini), flush: true);
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
        compatibilityProcess = process;
        unawaited(process.stdout.drain<void>());
        unawaited(process.stderr.drain<void>());
        lease.requireCurrent(await runtime());
        _runtimeLeases[id] = lease;
        _runtimeSubscriptions[id] = unsubscribe;
        _compatibilityProcesses[id] = process;
        tracked = true;
        _trackSession(
          ProcessProxySession(
            id: id,
            executable: request.executable,
            backendPid: process.pid,
            backendExecutable: executable,
            status: 'backendRunning',
          ),
          process.exitCode,
        );
      }
    } on ProcessProxyException {
      rethrow;
    } on Exception {
      throw const ProcessProxyException('launchFailed');
    } finally {
      if (!tracked) {
        unsubscribe?.call();
        lease?.dispose();
        compatibilityProcess?.kill();
      }
      if (!started && sessionDirectory != null) {
        await sessionDirectory
            .delete(recursive: true)
            .catchError((_) => sessionDirectory!);
      }
      _busy = false;
      _changed();
    }
  }

  void _trackSession(ProcessProxySession session, Future<int> exit) {
    _sessions.insert(0, session);
    _changed();
    unawaited(
      exit.then((code) async {
        final index = _sessions.indexWhere((s) => s.id == session.id);
        if (index < 0) return;
        _sessions[index] = ProcessProxySession(
          id: session.id,
          executable: session.executable,
          backendPid: session.backendPid,
          backendExecutable: session.backendExecutable,
          status: _invalidated.contains(session.id)
              ? 'coreInvalidated'
              : code == 0
              ? 'exited'
              : 'failed',
          exitCode: code,
          nativeBridge: session.nativeBridge,
          targetPid: session.targetPid,
        );
        final bridge = _bridges.remove(session.id);
        if (bridge != null) unawaited(bridge.close());
        _runtimeChecks.remove(session.id);
        _runtimeLeases.remove(session.id)?.dispose();
        _runtimeSubscriptions.remove(session.id)?.call();
        _compatibilityProcesses.remove(session.id);
        if (!session.nativeBridge) {
          final ini = File(
            p.join(p.dirname(session.backendExecutable), 'ProxyLane.ini'),
          );
          try {
            if (await FileSystemEntity.type(ini.path, followLinks: false) ==
                FileSystemEntityType.file) {
              await ini.delete();
            }
          } on FileSystemException {
            // Locked credentials remain for the documented manual cleanup.
          }
        }
        _changed();
      }),
    );
  }

  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final bridge = _bridges[sessionId];
    if (bridge == null) throw const ProcessProxyException('sessionUnavailable');
    if (const {
      'monitor.start',
      'recording.start',
      'connections.prepare_reconnect',
      'connections.reconnect',
    }.contains(operation)) {
      final check = _runtimeChecks[sessionId];
      final lease = _runtimeLeases[sessionId];
      if (check == null || lease == null || !lease.valid) {
        throw const ProcessProxyException('coreConfigurationChanged');
      }
      lease.requireCurrent(await check());
    }
    return bridge.request(operation, arguments);
  }

  Future<void> _invalidateSession(String id) async {
    if (!_invalidated.add(id)) return;
    _runtimeSubscriptions.remove(id)?.call();
    final index = _sessions.indexWhere((session) => session.id == id);
    if (index >= 0) {
      final old = _sessions[index];
      _sessions[index] = ProcessProxySession(
        id: old.id,
        executable: old.executable,
        backendPid: old.backendPid,
        backendExecutable: old.backendExecutable,
        status: 'coreInvalidated',
        nativeBridge: old.nativeBridge,
        targetPid: old.targetPid,
      );
      _changed();
    }
    final bridge = _bridges.remove(id);
    if (bridge != null) {
      try {
        await bridge.request('stop', {'confirm': true});
      } on Exception {
        // EOF cleanup is still required if the explicit stop was uncertain.
      } finally {
        await bridge.close();
      }
    }
    _compatibilityProcesses.remove(id)?.kill();
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
    for (final bridge in _bridges.values) {
      unawaited(bridge.close());
    }
    _bridges.clear();
    _runtimeChecks.clear();
    for (final unsubscribe in _runtimeSubscriptions.values) {
      unsubscribe();
    }
    _runtimeSubscriptions.clear();
    for (final lease in _runtimeLeases.values) {
      lease.dispose();
    }
    _runtimeLeases.clear();
    for (final process in _compatibilityProcesses.values) {
      process.kill();
    }
    _compatibilityProcesses.clear();
    super.dispose();
  }
}
