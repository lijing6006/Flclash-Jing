// ignore_for_file: avoid_relative_lib_imports

import 'dart:async';
import 'dart:convert';

import '../../lib/services/process_proxy/bridge_client.dart';
import '../../lib/services/process_proxy/policy.dart';

void _check(bool condition) {
  if (!condition) throw StateError('Assertion failed');
}

class _Transport {
  final output = StreamController<List<int>>(sync: true);
  final requests = <Map<String, dynamic>>[];
  late final ProcessProxyBridgeClient client;
  void Function(Map<String, dynamic>)? respond;
  var closeCount = 0;

  _Transport({Duration timeout = const Duration(seconds: 1)}) {
    client = ProcessProxyBridgeClient(
      output: output.stream,
      write: (bytes) {
        final request = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        requests.add(request);
        respond?.call(request);
      },
      closeTransport: () async {
        closeCount++;
        await output.close();
      },
      timeout: timeout,
    );
  }

  void reply(Map<String, dynamic> request, Map<String, dynamic> result) {
    output.add(
      utf8.encode(
        '${jsonEncode({'v': 1, 'id': request['id'], 'ok': true, 'result': result})}\n',
      ),
    );
  }

  Future<void> ready() async {
    respond = (request) => reply(request, {
      'session_token': 'a' * 64,
      'capabilities': <String, dynamic>{'monitor': true},
    });
    await client.handshake();
    respond = null;
  }
}

Future<void> _fails(Future<dynamic> future, String code) async {
  try {
    await future;
  } on ProcessProxyException catch (error) {
    _check(error.code == code);
    return;
  }
  throw StateError('Expected $code');
}

final Map<String, Future<void> Function()> processProxyBridgeCases = {
  'bridge requires authenticated handshake before commands': () async {
    final transport = _Transport();
    await _fails(transport.client.request('status'), 'bridgeNotReady');
    _check(transport.requests.isEmpty);
    await transport.client.close();
  },
  'bridge validates token length and advertised capability shape': () async {
    final transport = _Transport();
    transport.respond = (r) =>
        transport.reply(r, {'session_token': 'short', 'capabilities': {}});
    await _fails(transport.client.handshake(), 'bridgeProtocolError');
    await transport.client.close();
  },
  'bridge propagates token and strictly increasing request identifiers':
      () async {
        final transport = _Transport();
        await transport.ready();
        transport.respond = (r) => transport.reply(r, {'state': 'ready'});
        await transport.client.request('status');
        await transport.client.request('status');
        _check(transport.requests[1]['token'] == 'a' * 64);
        _check(transport.requests.map((r) => r['id']).join(',') == '1,2,3');
        await transport.client.close();
      },
  'bridge rejects arbitrary command before writing': () async {
    final transport = _Transport();
    await transport.ready();
    await _fails(
      transport.client.request('shell.exec', {'cmd': 'whoami'}),
      'bridgeUnsupportedOperation',
    );
    _check(transport.requests.length == 1);
    await transport.client.close();
  },
  'bridge handles fragmented UTF8 JSON framing': () async {
    final transport = _Transport();
    await transport.ready();
    transport.respond = (r) {
      final bytes = utf8.encode(
        '${jsonEncode({
          'v': 1,
          'id': r['id'],
          'ok': true,
          'result': {'text': '中文'},
        })}\n',
      );
      for (final byte in bytes) {
        transport.output.add([byte]);
      }
    };
    _check((await transport.client.request('status'))['text'] == '中文');
    await transport.client.close();
  },
  'bridge routes out-of-order replies by request ID': () async {
    final transport = _Transport();
    await transport.ready();
    final first = transport.client.request('status');
    final second = transport.client.request('logs');
    transport.reply(transport.requests[2], {'value': 2});
    transport.reply(transport.requests[1], {'value': 1});
    _check((await first)['value'] == 1 && (await second)['value'] == 2);
    await transport.client.close();
  },
  'bridge malformed frame fails pending requests closed': () async {
    final transport = _Transport();
    await transport.ready();
    final pending = _fails(
      transport.client.request('status'),
      'bridgeProtocolError',
    );
    transport.output.add(utf8.encode('not-json\n'));
    await pending;
    await _fails(transport.client.request('status'), 'bridgeExited');
    await transport.client.close();
  },
  'fatal protocol failure closes transport without another user action':
      () async {
        final transport = _Transport();
        await transport.ready();
        final pending = _fails(
          transport.client.request('status'),
          'bridgeProtocolError',
        );
        transport.output.add(utf8.encode('not-json\n'));
        await pending;
        await Future<void>.delayed(Duration.zero);
        _check(transport.closeCount == 1);
        await transport.client.close();
      },
  'synchronous pipe write failure closes transport and does not retry':
      () async {
        final transport = _Transport();
        await transport.ready();
        transport.respond = (_) => throw StateError('closed pipe');
        await _fails(
          transport.client.request('status'),
          'bridgeTransportFailed',
        );
        await Future<void>.delayed(Duration.zero);
        _check(transport.closeCount == 1 && transport.requests.length == 2);
        await transport.client.close();
      },
  'bridge rejects oversized reply without JSON parsing': () async {
    final transport = _Transport();
    await transport.ready();
    final pending = _fails(
      transport.client.request('status'),
      'bridgeFrameTooLarge',
    );
    transport.output.add(
      List.filled(ProcessProxyBridgeClient.maximumFrameBytes + 1, 97),
    );
    await pending;
    await transport.client.close();
  },
  'bridge rejects oversized requests before transport': () async {
    final transport = _Transport();
    await transport.ready();
    await _fails(
      transport.client.request('query', {
        'type': 'poll',
        'junk': 'x' * ProcessProxyBridgeClient.maximumFrameBytes,
      }),
      'bridgeFrameTooLarge',
    );
    _check(transport.requests.length == 1);
    await transport.client.close();
  },
  'bridge operation failures retain safe code only': () async {
    final transport = _Transport();
    await transport.ready();
    transport.respond = (r) => transport.output.add(
      utf8.encode(
        '${jsonEncode({
          'v': 1,
          'id': r['id'],
          'ok': false,
          'error': {'code': 'ca_untrusted', 'message': 'SECRET_VALUE'},
        })}\n',
      ),
    );
    try {
      await transport.client.request('monitor.start');
      throw StateError('Expected error');
    } on ProcessProxyException catch (error) {
      _check(
        error.detail == 'ca_untrusted' &&
            !error.toString().contains('SECRET_VALUE'),
      );
    }
    await transport.client.close();
  },
  'bridge timeout closes channel and never retries mutation': () async {
    final transport = _Transport(timeout: const Duration(milliseconds: 10));
    await transport.ready();
    await _fails(
      transport.client.request('launch', {'confirm': true}),
      'bridgeTimeout',
    );
    await transport.client.close();
    _check(transport.requests.length == 2 && transport.closeCount == 1);
    await _fails(transport.client.request('launch'), 'bridgeExited');
  },
  'explicit certificate actions allow policy prompts without retry': () async {
    final transport = _Transport(timeout: const Duration(milliseconds: 10));
    await transport.ready();
    transport.respond = (r) {
      Timer(
        const Duration(milliseconds: 25),
        () => transport.reply(r, {'trusted': true}),
      );
    };
    final result = await transport.client.request('ca.trust', {
      'scope': 'current-user',
      'confirm': true,
    });
    _check(result['trusted'] == true && transport.requests.length == 2);
    await transport.client.close();
  },
  'maintenance operations use authenticated allowlist without shell access':
      () async {
        final transport = _Transport();
        await transport.ready();
        transport.respond = (r) =>
            transport.reply(r, {'preparation_id': '7', 'count': 2});
        for (final operation in [
          'connections.prepare_reconnect',
          'connections.cancel_reconnect',
          'connections.reconnect',
          'replay.rebuild_index',
        ]) {
          await transport.client.request(operation);
        }
        _check(
          transport.requests.length == 5 &&
              transport.requests.skip(1).every((r) => r['token'] == 'a' * 64),
        );
        await transport.client.close();
      },
  'disk and stop operations allow draining beyond the ordinary timeout':
      () async {
        final transport = _Transport(timeout: const Duration(milliseconds: 10));
        await transport.ready();
        transport.respond = (r) {
          Timer(
            const Duration(milliseconds: 25),
            () => transport.reply(r, {'done': true}),
          );
        };
        for (final operation in [
          'monitor.start',
          'monitor.stop',
          'recording.start',
          'recording.stop',
          'replay.open',
          'replay.close',
          'stop',
          'shutdown',
        ]) {
          _check((await transport.client.request(operation))['done'] == true);
        }
        _check(transport.requests.length == 9 && transport.closeCount == 0);
        await transport.client.close();
      },
  'owned broker cleanup waits for slow drain without termination': () async {
    var terminated = false;
    await closeOwnedProcessProxyBridge(
      closeInput: () async {},
      exited: Future.delayed(const Duration(milliseconds: 25), () => 0),
      terminate: () => terminated = true,
      grace: const Duration(seconds: 1),
    );
    _check(!terminated);
  },
  'owned broker cleanup bounds a hung input close as well as exit': () async {
    final input = Completer<void>();
    final exit = Completer<int>();
    var kills = 0;
    await closeOwnedProcessProxyBridge(
      closeInput: () => input.future,
      exited: exit.future,
      terminate: () => kills++,
      grace: const Duration(milliseconds: 10),
    );
    _check(kills == 1);
    input.complete();
    exit.complete(1);
  },
  'already closed broker input still permits graceful process exit': () async {
    var terminated = false;
    await closeOwnedProcessProxyBridge(
      closeInput: () async => throw const ProcessProxyException('bridgeExited'),
      exited: Future.value(0),
      terminate: () => terminated = true,
    );
    _check(!terminated);
  },
  'bridge close is idempotent and resolves in-flight errors': () async {
    final transport = _Transport();
    await transport.ready();
    final pending = _fails(transport.client.request('status'), 'bridgeExited');
    await transport.client.close();
    await pending;
    await transport.client.close();
    _check(transport.closeCount == 1);
  },
};
