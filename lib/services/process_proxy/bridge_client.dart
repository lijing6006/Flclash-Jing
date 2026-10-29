import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'policy.dart';

class ProcessProxyBridgeClient {
  static const protocolVersion = 1;
  static const maximumFrameBytes = 1024 * 1024;
  static const maximumRequestBytes = 64 * 1024;
  static const operations = {
    'hello',
    'configure',
    'launch',
    'status',
    'logs',
    'monitor.start',
    'monitor.stop',
    'query',
    'capture.options',
    'recording.start',
    'recording.stop',
    'replay.open',
    'replay.close',
    'ca.query',
    'ca.initialize',
    'ca.trust',
    'ca.remove',
    'stop',
    'shutdown',
  };

  final void Function(List<int> bytes) _write;
  final Future<void> Function() _closeTransport;
  final Duration timeout;
  final Duration certificateTimeout;
  final int processId;
  final Future<int>? processExit;
  Future<void>? _closing;
  late final StreamSubscription<List<int>> _subscription;
  final Map<int, Completer<Map<String, dynamic>>> _pending = {};
  final List<int> _buffer = [];
  int _nextId = 0;
  String? _token;
  bool _closed = false;
  Map<String, dynamic> capabilities = const {};

  ProcessProxyBridgeClient({
    required Stream<List<int>> output,
    required void Function(List<int>) write,
    required Future<void> Function() closeTransport,
    this.timeout = const Duration(seconds: 15),
    this.certificateTimeout = const Duration(seconds: 120),
    this.processId = 0,
    this.processExit,
  }) : _write = write,
       _closeTransport = closeTransport {
    _subscription = output.listen(
      _receive,
      onError: (_) =>
          _fail(const ProcessProxyException('bridgeTransportFailed')),
      onDone: () => _fail(const ProcessProxyException('bridgeExited')),
    );
  }

  static Future<ProcessProxyBridgeClient> start(String executable) async {
    final process = await Process.start(
      executable,
      const [],
      runInShell: false,
    );
    unawaited(process.stderr.drain<void>());
    final client = ProcessProxyBridgeClient(
      output: process.stdout,
      processId: process.pid,
      processExit: process.exitCode,
      write: process.stdin.add,
      closeTransport: () async {
        await process.stdin.close();
        try {
          await process.exitCode.timeout(const Duration(seconds: 5));
        } on TimeoutException {
          process.kill();
        }
      },
    );
    try {
      await client.handshake();
      return client;
    } catch (_) {
      await client.close();
      rethrow;
    }
  }

  Future<void> handshake() async {
    if (_token != null) throw const ProcessProxyException('bridgeAlreadyReady');
    final result = await request('hello');
    final token = result['session_token'];
    final advertised = result['capabilities'];
    if (token is! String ||
        token.length < 32 ||
        token.length > 128 ||
        advertised is! Map) {
      _fail(const ProcessProxyException('bridgeProtocolError'));
      throw const ProcessProxyException('bridgeProtocolError');
    }
    _token = token;
    capabilities = Map<String, dynamic>.from(advertised);
  }

  Future<Map<String, dynamic>> request(
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    if (_closed) throw const ProcessProxyException('bridgeExited');
    if (!operations.contains(operation)) {
      throw const ProcessProxyException('bridgeUnsupportedOperation');
    }
    if (operation != 'hello' && _token == null) {
      throw const ProcessProxyException('bridgeNotReady');
    }
    if (_pending.length >= 16) throw const ProcessProxyException('bridgeBusy');
    final id = ++_nextId;
    final bytes = utf8.encode(
      '${jsonEncode({'v': protocolVersion, 'id': id, if (_token != null) 'token': _token, 'op': operation, 'args': arguments})}\n',
    );
    if (bytes.length > maximumRequestBytes) {
      throw const ProcessProxyException('bridgeFrameTooLarge');
    }
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    try {
      _write(bytes);
      return await completer.future.timeout(
        const {'ca.initialize', 'ca.trust', 'ca.remove'}.contains(operation)
            ? certificateTimeout
            : timeout,
      );
    } on TimeoutException {
      _fail(const ProcessProxyException('bridgeTimeout'));
      unawaited(close());
      throw const ProcessProxyException('bridgeTimeout');
    } finally {
      _pending.remove(id);
    }
  }

  void _receive(List<int> bytes) {
    if (_closed) return;
    for (final byte in bytes) {
      if (byte == 10) {
        final frame = List<int>.of(_buffer);
        _buffer.clear();
        try {
          _handle(jsonDecode(utf8.decode(frame)));
        } catch (_) {
          _fail(const ProcessProxyException('bridgeProtocolError'));
          return;
        }
      } else {
        if (_buffer.length >= maximumFrameBytes) {
          _fail(const ProcessProxyException('bridgeFrameTooLarge'));
          return;
        }
        _buffer.add(byte);
      }
    }
  }

  void _handle(dynamic response) {
    if (response is! Map ||
        response['v'] != protocolVersion ||
        response['id'] is! int ||
        response['ok'] is! bool) {
      throw const FormatException();
    }
    final completer = _pending[response['id']];
    if (completer == null || completer.isCompleted) return;
    if (response['ok'] == true) {
      final result = response['result'];
      if (result is! Map) throw const FormatException();
      completer.complete(Map<String, dynamic>.from(result));
    } else {
      final error = response['error'];
      final code = error is Map ? error['code'] : null;
      completer.completeError(
        ProcessProxyException(
          'bridgeOperationFailed',
          code is String ? code : null,
        ),
      );
    }
  }

  void _fail(ProcessProxyException error) {
    if (_closed) return;
    _closed = true;
    _buffer.clear();
    for (final pending in _pending.values) {
      if (!pending.isCompleted) pending.completeError(error);
    }
    _pending.clear();
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    _fail(const ProcessProxyException('bridgeExited'));
    await _subscription.cancel();
    try {
      await _closeTransport();
    } on Exception {
      // A dead child may reject stdin close; the session is already failed.
    }
  }
}
