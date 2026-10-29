import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../lib/services/process_proxy/backend.dart';
import '../../lib/services/process_proxy/policy.dart';

void _check(bool condition) {
  if (!condition) throw StateError('Assertion failed');
}

Future<void> _probe(
  Future<void> Function(Socket socket) handle, {
  String type = 'SOCKS5',
  String username = '',
  String password = '',
  String? expectedError,
}) async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final sockets = <Socket>[];
  final tasks = <Future<void>>[];
  final subscription = server.listen((socket) {
    sockets.add(socket);
    tasks.add(handle(socket));
  });
  try {
    await probeProcessProxyEndpoint(
      ProcessProxyEndpoint(type, server.port, username, password),
    );
    _check(expectedError == null);
  } on ProcessProxyException catch (error) {
    _check(error.code == expectedError);
  } finally {
    for (final socket in sockets) {
      socket.destroy();
    }
    await subscription.cancel();
    await server.close();
    await Future.wait(tasks);
  }
}

final Map<String, Future<void> Function()> processProxyBackendCases = {
  'read-only process results include same-named PIDs separately': () async {
    final results = parseProcessCandidates(
      jsonEncode([
        {
          'ProcessId': 12,
          'Name': 'app.exe',
          'ExecutablePath': r'C:\One\app.exe',
        },
        {
          'ProcessId': 13,
          'Name': 'app.exe',
          'ExecutablePath': r'C:\Two\app.exe',
        },
      ]),
      'app',
    );
    _check(results.length == 2 && results[0].pid != results[1].pid);
  },
  'process results reject protected missing paths and scripts': () async {
    final results = parseProcessCandidates(
      jsonEncode([
        {'ProcessId': 1, 'Name': 'system', 'ExecutablePath': null},
        {'ProcessId': 2, 'Name': 'bad', 'ExecutablePath': r'C:\bad.cmd'},
        {'ProcessId': 3, 'Name': 'ok.exe', 'ExecutablePath': r'C:\ok.exe'},
      ]),
      '',
    );
    _check(results.length == 1 && results.single.pid == 3);
  },
  'process search treats shell syntax as literal data': () async {
    final results = parseProcessCandidates(
      '[{"ProcessId":3,"Name":"ok.exe","ExecutablePath":"C:\\\\ok.exe"}]',
      ';whoami',
    );
    _check(results.isEmpty);
  },
  'process result count is bounded': () async {
    final results = parseProcessCandidates(
      jsonEncode(
        List.generate(
          300,
          (i) => {
            'ProcessId': i + 1,
            'Name': 'app.exe',
            'ExecutablePath': r'C:\app.exe',
          },
        ),
      ),
      '',
    );
    _check(results.length == 200);
  },
  'SOCKS greeting uses configured ephemeral port': () async {
    await _probe((socket) async {
      final first = await socket.first;
      _check(first.length == 3 && first[0] == 5 && first[2] == 0);
      socket.add([5, 0]);
      await socket.flush();
    });
  },
  'SOCKS greeting tolerates fragmented response': () async {
    await _probe((socket) async {
      await socket.first;
      socket.add([5]);
      await socket.flush();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      socket.add([0]);
      await socket.flush();
    });
  },
  'SOCKS rejects wrong protocol': () async {
    await _probe((socket) async {
      await socket.first;
      socket.add([4, 0]);
      await socket.flush();
    }, expectedError: 'listenerHandshakeFailed');
  },
  'SOCKS rejects unacceptable authentication method': () async {
    await _probe((socket) async {
      await socket.first;
      socket.add([5, 255]);
      await socket.flush();
    }, expectedError: 'listenerHandshakeFailed');
  },
  'SOCKS performs authentication without target connection': () async {
    await _probe(
      (socket) async {
        var step = 0;
        await for (final bytes in socket) {
          if (step++ == 0) {
            _check(bytes[2] == 2);
            socket.add([5, 2]);
          } else {
            _check(bytes[0] == 1 && bytes[1] == 4);
            _check(utf8.decode(bytes.sublist(2, 6)) == 'user');
            socket.add([1, 0]);
            await socket.flush();
            break;
          }
          await socket.flush();
        }
      },
      username: 'user',
      password: 'password',
    );
  },
  'SOCKS reports rejected credentials': () async {
    await _probe(
      (socket) async {
        var step = 0;
        await for (final bytes in socket) {
          socket.add(step++ == 0 ? [5, 2] : [1, 1]);
          await socket.flush();
          if (step == 2) break;
        }
      },
      username: 'user',
      password: 'password',
      expectedError: 'listenerAuthenticationFailed',
    );
  },
  'HTTP verifies response without requesting external resource': () async {
    await _probe((socket) async {
      final bytes = await socket.first;
      _check(ascii.decode(bytes).startsWith('HEAD / HTTP/1.1'));
      socket.add(
        ascii.encode('HTTP/1.1 400 Bad Request\r\nConnection: close\r\n\r\n'),
      );
      await socket.flush();
    }, type: 'HTTP11');
  },
  'HTTP rejects proxy authentication challenge': () async {
    await _probe(
      (socket) async {
        await socket.first;
        socket.add(
          ascii.encode('HTTP/1.1 407 Proxy Authentication Required\r\n\r\n'),
        );
        await socket.flush();
      },
      type: 'HTTP11',
      expectedError: 'listenerAuthenticationFailed',
    );
  },
};
