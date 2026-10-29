import 'dart:convert';

import '../../lib/services/process_proxy/policy.dart';
import '../../lib/services/process_proxy/recording_browser.dart';

Map<String, dynamic> recordingFixtureRow({
  int cacheId = 7,
  String type = 'exchange',
  String connectionId = 'conn-1',
}) => {
  'format': 'ProxyLaneSession',
  'version': 2,
  'type': type,
  if (type != 'connection') 'cache_id': cacheId,
  'protocol': 'h2',
  'connection': {
    'id': connectionId,
    'pid': 42,
    'process_name': 'Example.exe',
    'destination': 'example.com:443',
    'transport': 'tcp',
  },
  'exchange': {
    'request': {'method': 'GET', 'target': '/work'},
  },
};

Map<String, dynamic> recordingFixturePage({
  int offset = 0,
  int total = 3,
  String runId = 'recording:100',
  List<Map<String, dynamic>>? records,
}) => {
  'type': 'records',
  'run_id': runId,
  'records': records ?? [recordingFixtureRow(cacheId: offset + 7)],
  'offset': offset,
  'total': total,
  'all': total + 2,
  'next': 0,
  'warnings': 1,
  'manifest': {'format': 'ProxyLaneRecording', 'version': 2},
  'directory': r'C:\Recordings',
};

void _check(bool value) {
  if (!value) throw StateError('Assertion failed');
}

void _fails(void Function() action, [String code = 'bridgeProtocolError']) {
  try {
    action();
  } on ProcessProxyException catch (error) {
    _check(error.code == code);
    return;
  }
  throw StateError('Expected $code');
}

final Map<String, void Function()> processProxyRecordingCases = {
  'page query uses offset not live cursor and has no mutation fields': () {
    final query = const ProcessProxyRecordingQuery().toJson();
    _check(query['type'] == 'recording_page' && query['offset'] == 0);
    _check(
      query['limit'] == 16 && query['protocol'] == 0 && query['filter'] == '',
    );
    _check(!query.containsKey('after') && !query.containsKey('confirm'));
  },
  'all seven upstream protocol values are accepted': () {
    for (var protocol = 0; protocol <= 6; protocol++) {
      final query = ProcessProxyRecordingQuery(
        protocol: protocol,
        filter: 'worker',
      ).toJson();
      _check(query['protocol'] == protocol && query['filter'] == 'worker');
    }
  },
  'query limits and numeric boundaries are enforced': () {
    for (final query in [
      const ProcessProxyRecordingQuery(offset: -1),
      const ProcessProxyRecordingQuery(offset: 9007199254740992),
      const ProcessProxyRecordingQuery(limit: 0),
      const ProcessProxyRecordingQuery(limit: 65),
      const ProcessProxyRecordingQuery(protocol: -1),
      const ProcessProxyRecordingQuery(protocol: 7),
    ]) {
      _fails(query.toJson, 'recordingQueryInvalid');
    }
  },
  'filter length uses UTF8 bytes and rejects control characters': () {
    _fails(
      () => ProcessProxyRecordingQuery(filter: '界' * 86).toJson(),
      'recordingQueryInvalid',
    );
    _fails(
      () => const ProcessProxyRecordingQuery(filter: 'bad\nfilter').toJson(),
      'recordingQueryInvalid',
    );
    _check(
      ProcessProxyRecordingQuery(filter: 'a' * 256).toJson()['filter'] ==
          'a' * 256,
    );
  },
  'actual index row identifies cache and retains immutable recording run': () {
    final page = parseProcessProxyRecordingPage(recordingFixturePage());
    final row = page.rows.single;
    _check(row.cacheId == 7 && row.connectionId == null);
    _check(row.runId == 'recording:100' && row.label.contains('GET'));
    _check(row.context.contains('PID 42'));
  },
  'connection-only rows use connection ID and never fake a cache ID': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(records: [recordingFixtureRow(type: 'connection')]),
    );
    final row = page.rows.single;
    final query = row.detailQuery();
    _check(row.cacheId == null && query['connection_id'] == 'conn-1');
    _check(!query.containsKey('cache_id'));
  },
  'cache detail query carries exact run and bounded preview': () {
    final row = parseProcessProxyRecordingPage(recordingFixturePage())
        .rows
        .single;
    final query = row.detailQuery();
    _check(query['type'] == 'recording_detail');
    _check(query['run_id'] == 'recording:100' && query['cache_id'] == 7);
    _check(
      query['preview_bytes'] == 16384 && !query.containsKey('connection_id'),
    );
  },
  'next is always ignored in favor of returned offset plus row count': () {
    final response = recordingFixturePage(offset: 1)..['next'] = 99999;
    final page = parseProcessProxyRecordingPage(response);
    _check(page.nextOffset == 2 && page.hasNext);
  },
  'short pages advance by actual count rather than requested page size': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(total: 100),
    );
    validateProcessProxyRecordingPage(
      page,
      const ProcessProxyRecordingQuery(limit: 16),
    );
    _check(page.nextOffset == 1 && page.hasNext);
  },
  'empty page before total halts pagination': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(total: 10, records: []),
    );
    _check(page.stalled && !page.hasNext && page.nextOffset == 0);
  },
  'empty page at the end is exhausted rather than stalled': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(offset: 3, total: 3, records: []),
    );
    _check(!page.stalled && !page.hasNext && page.nextOffset == 3);
  },
  'empty filtered result retains all-record count and warnings': () {
    final response = recordingFixturePage(total: 0, records: [])..['all'] = 500;
    final page = parseProcessProxyRecordingPage(response);
    _check(page.all == 500 && page.total == 0 && page.warnings == 1);
    _check(page.metadata.text.contains('ProxyLaneRecording'));
  },
  'live runs and missing recording identity are rejected': () {
    for (final run in ['live:1', '', 'recording:', 'recording:bad\n']) {
      _fails(
        () => parseProcessProxyRecordingPage(recordingFixturePage(runId: run)),
      );
    }
  },
  'invalid count types and impossible totals are rejected': () {
    for (final patch in <Map<String, dynamic>>[
      {'offset': '0'},
      {'total': -1},
      {'all': 0},
      {'warnings': -1},
      {'warnings': 0.0},
      {'offset': 10},
    ]) {
      _fails(
        () => parseProcessProxyRecordingPage(
          recordingFixturePage()..addAll(patch),
        ),
      );
    }
  },
  'oversized pages are rejected rather than silently truncated': () {
    final response = recordingFixturePage(
      total: 65,
      records: List.generate(65, (i) => recordingFixtureRow(cacheId: i + 1)),
    );
    _fails(() => parseProcessProxyRecordingPage(response));
  },
  'record count must fit inside the reported total': () {
    _fails(
      () => parseProcessProxyRecordingPage(recordingFixturePage(total: 0)),
    );
  },
  'duplicate record identities are rejected without skewing pagination': () {
    _fails(
      () => parseProcessProxyRecordingPage(
        recordingFixturePage(
          records: [recordingFixtureRow(), recordingFixtureRow()],
        ),
      ),
    );
  },
  'missing cache identities and unsupported record formats are rejected': () {
    for (final patch in <Map<String, dynamic>>[
      {'cache_id': 0},
      {'cache_id': 7.0},
      {'type': 'unknown'},
      {'version': 2.0},
      {'format': 'other'},
      {'connection': null},
    ]) {
      final row = recordingFixtureRow()..addAll(patch);
      _fails(
        () => parseProcessProxyRecordingPage(
          recordingFixturePage(records: [row]),
        ),
      );
    }
  },
  'connection identity cannot contain a relative path': () {
    final row = recordingFixtureRow(
      type: 'connection',
      connectionId: '../other',
    );
    _fails(
      () =>
          parseProcessProxyRecordingPage(recordingFixturePage(records: [row])),
    );
  },
  'query and response offsets must match upstream clamping behavior': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(offset: 3, total: 3, records: []),
    );
    validateProcessProxyRecordingPage(
      page,
      const ProcessProxyRecordingQuery(offset: 100),
    );
    _fails(
      () => validateProcessProxyRecordingPage(
        page,
        const ProcessProxyRecordingQuery(offset: 1),
      ),
    );
  },
  'returned rows cannot exceed the requested limit': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(
        records: [recordingFixtureRow(), recordingFixtureRow(cacheId: 8)],
      ),
    );
    _fails(
      () => validateProcessProxyRecordingPage(
        page,
        const ProcessProxyRecordingQuery(limit: 1),
      ),
    );
  },
  'changing recording mid-pagination requires restarting from first page': () {
    final page = parseProcessProxyRecordingPage(
      recordingFixturePage(offset: 1, runId: 'recording:new'),
    );
    _fails(
      () => validateProcessProxyRecordingPage(
        page,
        const ProcessProxyRecordingQuery(offset: 1),
        previousRunId: 'recording:old',
      ),
      'recordingChanged',
    );
    final first = parseProcessProxyRecordingPage(
      recordingFixturePage(runId: 'recording:new'),
    );
    validateProcessProxyRecordingPage(
      first,
      const ProcessProxyRecordingQuery(),
    );
  },
  'back to first page still rejects a changed recording identity': () {
    final first = parseProcessProxyRecordingPage(
      recordingFixturePage(runId: 'recording:new'),
    );
    _fails(
      () => validateProcessProxyRecordingPage(
        first,
        const ProcessProxyRecordingQuery(),
        previousRunId: 'recording:old',
      ),
      'recordingChanged',
    );
  },
  'detail must match the selected cache identity': () {
    final row = parseProcessProxyRecordingPage(recordingFixturePage())
        .rows
        .single;
    final text = formatProcessProxyRecordingDetail((
      response: recordingFixtureRow(),
      row: row,
    ));
    _check(text.text.contains('ProxyLaneSession') && !text.truncated);
    _fails(
      () => formatProcessProxyRecordingDetail((
        response: recordingFixtureRow(cacheId: 9),
        row: row,
      )),
    );
  },
  'connection detail must match the selected connection identity': () {
    final response = recordingFixtureRow(type: 'connection');
    final row = parseProcessProxyRecordingPage(
      recordingFixturePage(records: [response]),
    ).rows.single;
    _check(
      !formatProcessProxyRecordingDetail((response: response, row: row))
          .truncated,
    );
    _fails(
      () => formatProcessProxyRecordingDetail((
        response: recordingFixtureRow(
          type: 'connection',
          connectionId: 'other',
        ),
        row: row,
      )),
    );
  },
  'detail query rejects ambiguous or missing identifiers': () {
    for (final row in [
      const ProcessProxyRecordingRow(
        runId: 'recording:1',
        label: '',
        context: '',
      ),
      const ProcessProxyRecordingRow(
        runId: 'recording:1',
        label: '',
        context: '',
        cacheId: 7,
        connectionId: 'both',
      ),
      const ProcessProxyRecordingRow(
        runId: 'recording:1',
        label: '',
        context: '',
        cacheId: -1,
      ),
    ]) {
      _fails(row.detailQuery);
    }
  },
  'recorded peer strings cannot create unbounded labels or controls': () {
    final record = recordingFixtureRow();
    (record['exchange'] as Map)['request'] = {
      'method': 'GET',
      'target': 'x' * 5000 + '\nunsafe',
    };
    final row = parseProcessProxyRecordingPage(
      recordingFixturePage(records: [record]),
    ).rows.single;
    _check(row.label.length < 600 && !row.label.contains('\n'));
  },
  'manifest and detail rendering are bounded and report truncation': () {
    final response = recordingFixturePage()
      ..['manifest'] = {'data': 'x' * 60000};
    final page = parseProcessProxyRecordingPage(response);
    _check(
      page.metadata.truncated &&
          utf8.encode(page.metadata.text).length <= 48 * 1024,
    );
    final detail = recordingFixtureRow()..['headers'] = 'x' * 60000;
    final rendered = formatProcessProxyRecordingDetail((
      response: detail,
      row: page.rows.single,
    ));
    _check(
      rendered.truncated && utf8.encode(rendered.text).length <= 48 * 1024,
    );
  },
  'multibyte preview truncation preserves UTF8 boundaries and byte budget': () {
    for (final value in ['界', '😀']) {
      final response = recordingFixturePage()
        ..['manifest'] = {'data': value * 20000};
      final page = parseProcessProxyRecordingPage(response);
      _check(page.metadata.truncated);
      _check(utf8.encode(page.metadata.text).length <= 48 * 1024);
      _check(!page.metadata.text.contains('\ufffd'));
    }
  },
};
