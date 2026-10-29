// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';

import '../../lib/services/process_proxy/policy.dart';
import '../../lib/services/process_proxy/record_detail.dart';

Map<String, dynamic> detailFixture({String protocol = 'h2'}) => {
  'type': 'exchange',
  'protocol': protocol,
  'connection': {'id': 'conn-1', 'pid': 42, 'destination': 'example.test:443'},
  'exchange': {
    'cache': {'id': 7},
    'request': {
      'method': 'GET',
      'target': '/hello',
      'complete': true,
      'headers': [
        [':authority', 'example.test'],
        ['x-repeat', 'one'],
        ['x-repeat', 'two'],
      ],
      'trailers': [
        ['checksum', 'abc'],
      ],
    },
    'response': {
      'status': 200,
      'headers': [
        ['content-type', 'text/plain'],
      ],
      'complete': true,
    },
    'informational': [
      {
        'status': 103,
        'headers': [
          ['link', '</style>'],
        ],
        'complete': true,
      },
    ],
  },
};

Map<String, dynamic> datagramFixture({String protocol = 'udp'}) => {
  'type': 'stream',
  'protocol': protocol,
  'connection': {'id': 'udp-1', 'pid': 42},
  'stream': {
    'cache': {'id': 7},
    'datagrams': [
      [
        [0, 3],
        [3, 0],
        [3, 20000],
      ],
      [
        [0, 5],
      ],
    ],
    'packet_counts': [3, 1],
  },
};

ProcessProxyRecordDetail _parse(Map<String, dynamic> record) =>
    parseProcessProxyRecordDetail(
      ProcessProxyRecordInput(record: record, runId: 'run-1', cacheId: 7),
    );
void _check(bool value) {
  if (!value) throw StateError('Assertion failed');
}

void _fails(void Function() action) {
  try {
    action();
  } on ProcessProxyException {
    return;
  }
  throw StateError('Expected safe failure');
}

final Map<String, void Function()> processProxyRecordDetailCases = {
  'HTTP request response and informational preserve semantic metadata': () {
    final d = _parse(detailFixture());
    _check(d.request!.summary == 'GET /hello' && d.response!.summary == '200');
    _check(d.informational.single.summary == '103' && d.request!.complete);
  },
  'ordered duplicate headers and trailers are never collapsed': () {
    final m = _parse(detailFixture()).request!;
    _check(m.headers.length == 3 && m.headers[1].name == m.headers[2].name);
    _check(m.headers[1].value == 'one' && m.headers[2].value == 'two');
    _check(m.trailers.single.name == 'checksum');
  },
  'all three supported HTTP representations use actual fields': () {
    for (final p in ['http1', 'h2', 'h3']) {
      _check(_parse(detailFixture(protocol: p)).request != null);
    }
  },
  'unsupported protocol never invents HTTP messages': () {
    for (final p in ['websocket', 'unknown', 'tls_encrypted']) {
      _check(_parse(detailFixture(protocol: p)).request == null);
    }
  },
  'absent header metadata differs from empty actual headers': () {
    final record = detailFixture();
    ((record['exchange'] as Map)['request'] as Map).remove('headers');
    _check(!_parse(record).request!.headersAvailable);
    ((record['exchange'] as Map)['request'] as Map)['headers'] = [];
    _check(_parse(record).request!.headersAvailable);
  },
  'unconfirmed completion remains incomplete': () {
    final record = detailFixture();
    ((record['exchange'] as Map)['request'] as Map).remove('complete');
    _check(!_parse(record).request!.complete);
  },
  'malformed header or trailer pairs fail rather than forging text': () {
    for (final value in [
      'text',
      [
        [1, 'value'],
      ],
      [
        ['name'],
      ],
      [
        ['a', 'b', 'c'],
      ],
    ]) {
      for (final field in ['headers', 'trailers']) {
        final record = detailFixture();
        ((record['exchange'] as Map)['request'] as Map)[field] = value;
        _fails(() => _parse(record));
      }
    }
  },
  'peer control characters are escaped instead of adding fake lines': () {
    final record = detailFixture();
    ((record['exchange'] as Map)['request'] as Map)['headers'] = [
      ['safe', 'one\r\nforged: true\x00'],
    ];
    final v = _parse(record).request!.headers.single.value;
    _check(v.contains(r'\x0d\x0a') && !v.contains('\n') && !v.contains('\x00'));
  },
  'per-message headers stop at 128 and disclose truncation': () {
    final record = detailFixture();
    ((record['exchange'] as Map)['request'] as Map)['headers'] = List.generate(
      130,
      (i) => ['name', '$i'],
    );
    final d = _parse(record);
    _check(
      d.request!.headers.length == 128 && d.request!.truncated && d.truncated,
    );
  },
  'total header rows are bounded even for empty values': () {
    final record = detailFixture();
    final exchange = record['exchange'] as Map;
    exchange['informational'] = List.generate(
      16,
      (_) => {
        'headers': List.generate(128, (_) => ['', '']),
      },
    );
    final d = _parse(record);
    final messages = [d.request!, d.response!, ...d.informational];
    _check(
      messages.fold<int>(
                0,
                (n, m) => n + m.headers.length + m.trailers.length,
              ) <=
              256 &&
          d.truncated,
    );
  },
  'informational response list is bounded to 16 entries': () {
    final record = detailFixture();
    (record['exchange'] as Map)['informational'] = List.generate(
      30,
      (_) => {'status': 103, 'headers': []},
    );
    final d = _parse(record);
    _check(d.informational.length == 16 && d.truncated);
  },
  'large multibyte header values keep UTF8 boundary and limits': () {
    final record = detailFixture();
    ((record['exchange'] as Map)['request'] as Map)['headers'] = [
      ['value', '😀' * 20000],
    ];
    final d = _parse(record);
    final v = d.request!.headers.single.value;
    _check(
      utf8.encode(v).length <= 4096 && !v.contains('\ufffd') && d.truncated,
    );
  },
  'record and selected cache identities must agree': () {
    final record = detailFixture()..['cache_id'] = 8;
    _fails(() => _parse(record));
    _fails(
      () => parseProcessProxyRecordDetail(
        ProcessProxyRecordInput(
          record: detailFixture(),
          runId: 'run-1',
          cacheId: 8,
        ),
      ),
    );
  },
  'missing fractional and contradictory cache identities fail': () {
    for (final id in [null, 7.0, 8]) {
      final record = detailFixture();
      (record['exchange'] as Map)['cache'] = {'id': id};
      _fails(() => _parse(record));
    }
  },
  'record cannot override the row run identity': () {
    final record = detailFixture()..['run_id'] = 'other-run';
    _fails(() => _parse(record));
  },
  'invalid run and ambiguous selected identity fail': () {
    for (final run in ['', 'bad\n', '界' * 100]) {
      _fails(
        () => parseProcessProxyRecordDetail(
          ProcessProxyRecordInput(
            record: detailFixture(),
            runId: run,
            cacheId: 7,
          ),
        ),
      );
    }
    _fails(
      () => parseProcessProxyRecordDetail(
        ProcessProxyRecordInput(
          record: detailFixture(),
          runId: 'run',
          cacheId: 7,
          connectionId: 'conn-1',
        ),
      ),
    );
  },
  'connection-only metadata retains exact connection identity': () {
    final record = {
      'type': 'connection',
      'protocol': 'quic',
      'connection': {'id': 'conn-1'},
    };
    final d = parseProcessProxyRecordDetail(
      ProcessProxyRecordInput(
        record: record,
        runId: 'recording:1',
        connectionId: 'conn-1',
      ),
    );
    _check(d.identity.cacheId == null && d.encrypted);
    _fails(
      () => parseProcessProxyRecordDetail(
        ProcessProxyRecordInput(
          record: record,
          runId: 'recording:1',
          connectionId: 'other',
        ),
      ),
    );
  },
  'UDP offsets lengths and zero packets are actual index entries': () {
    final d = _parse(datagramFixture());
    final p = d.datagrams.first.packets;
    _check(
      p[0].offset == 0 &&
          p[0].length == 3 &&
          p[1].length == 0 &&
          p[2].offset == 3,
    );
    _check(
      p[2].previewLength == 16384 && d.datagrams[1].packets.single.length == 5,
    );
  },
  'each packet preview cannot cross its own length': () {
    _check(const ProcessProxyDatagram(50, 3).previewLength == 3);
    _check(const ProcessProxyDatagram(50, 0).previewLength == 0);
    _check(const ProcessProxyDatagram(50, 20000).previewLength == 16384);
  },
  'all supported datagram protocols preserve boundaries': () {
    for (final p in ['udp', 'quic', 'quic_datagram']) {
      _check(_parse(datagramFixture(protocol: p)).datagrams.length == 2);
    }
  },
  'TCP and QUIC streams do not inherit datagram semantics': () {
    for (final p in ['tcp', 'quic_stream', 'tls_stream']) {
      _check(_parse(datagramFixture(protocol: p)).datagrams.isEmpty);
    }
  },
  'encrypted TLS and QUIC are not called plaintext': () {
    for (final p in ['tls_encrypted', 'quic']) {
      _check(_parse(datagramFixture(protocol: p)).encrypted);
    }
    _check(!_parse(datagramFixture(protocol: 'quic_datagram')).encrypted);
  },
  'missing datagram index never synthesizes boundaries from counts': () {
    final record = datagramFixture();
    (record['stream'] as Map).remove('datagrams');
    final d = _parse(record).datagrams.first;
    _check(!d.indexed && d.packets.isEmpty && d.truncated);
  },
  'empty supplied index remains distinct from absent index': () {
    final record = datagramFixture();
    (record['stream'] as Map)['datagrams'] = [[], []];
    _check(_parse(record).datagrams.first.indexed);
  },
  'per-direction index is bounded to 128 packets with a limit flag': () {
    final record = datagramFixture();
    (record['stream'] as Map)['datagrams'] = [
      List.generate(200, (i) => [i, 1]),
      [],
    ];
    final d = _parse(record).datagrams.first;
    _check(d.packets.length == 128 && d.truncated);
  },
  'reported packet count beyond index is disclosed': () {
    final record = datagramFixture();
    (record['stream'] as Map)['packet_counts'] = [100, 1];
    _check(_parse(record).datagrams.first.truncated);
  },
  'partial or stale reported counts are retained without fabricating packets':
      () {
        final record = datagramFixture();
        (record['stream'] as Map)['packet_counts'] = [0, 0];
        final d = _parse(record).datagrams.first;
        _check(d.reportedCount == 0 && d.packets.length == 3);
      },
  'negative fractional overlapping and overflowing index ranges fail': () {
    for (final values in [
      [
        [-1, 3],
      ],
      [
        [0, 1.0],
      ],
      [
        [0, 3],
        [2, 1],
      ],
      [
        [9007199254740991, 1],
      ],
      [
        [0, -1],
      ],
    ]) {
      final record = datagramFixture();
      (record['stream'] as Map)['datagrams'] = [values, []];
      _fails(() => _parse(record));
    }
  },
  'malformed index shapes fail without creating packet actions': () {
    for (final value in [
      'text',
      [],
      [[], [], []],
      [
        [1],
        [],
      ],
      [
        [
          [0, 1, 2],
        ],
        [],
      ],
    ]) {
      final record = datagramFixture();
      (record['stream'] as Map)['datagrams'] = value;
      _fails(() => _parse(record));
    }
  },
  'malformed packet counts fail safely': () {
    for (final value in [
      [],
      [1],
      [-1, 0],
      [1.0, 0],
    ]) {
      final record = datagramFixture();
      (record['stream'] as Map)['packet_counts'] = value;
      _fails(() => _parse(record));
    }
  },
};
