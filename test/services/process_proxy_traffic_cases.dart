import 'dart:convert';

import '../../lib/services/process_proxy/traffic.dart';
import '../../lib/services/process_proxy/policy.dart';

void _check(bool value) {
  if (!value) throw StateError('Assertion failed');
}

Map<String, dynamic> _payload(
  List<int> data, {
  Map<String, dynamic> fields = const {},
  Map<String, dynamic> cache = const {},
}) => {
  'run_id': 'run-1',
  'payload': {
    'data_base64': base64Encode(data),
    'direction': 'client',
    'offset': 16,
    'decoded': false,
    'decoded_bytes': data.length,
    'cache': {
      'finished': true,
      'pending_chunks': 0,
      'request_bytes': data.length + 16,
      ...cache,
    },
    ...fields,
  },
};
final Map<String, void Function()> processProxyTrafficCases = {
  'Raw text and Hex preserve bytes without running content': () {
    final preview = formatProcessProxyPayload(_payload([65, 0, 255, 10]));
    _check(
      preview.raw.startsWith(r'A\x00') &&
          preview.hex.contains('00000010  41 00 ff 0a'),
    );
    _check(!preview.truncated && !preview.incomplete);
  },
  'payload display is bounded and explicitly truncated': () {
    final preview = formatProcessProxyPayload(_payload(List.filled(65536, 65)));
    _check(preview.raw.length == 16384 && preview.truncated);
  },
  'pending and evicted caches never masquerade as complete': () {
    for (final cache in [
      {'finished': false},
      {'evicted': true},
      {'pending_chunks': 1},
      {'reason': 'limit'},
    ]) {
      _check(formatProcessProxyPayload(_payload([], cache: cache)).incomplete);
    }
  },
  'compressed-body warning and DNS errors remain visible': () {
    final response = _payload([1], fields: {'warning': 'encoded bytes'});
    response['decode_error'] = 'incomplete message';
    final preview = formatProcessProxyPayload(response);
    _check(
      preview.incomplete &&
          preview.metadata.contains('encoded bytes') &&
          preview.metadata.contains('incomplete message'),
    );
  },
  'decoded total indicates truncation without guessing decoded status': () {
    final preview = formatProcessProxyPayload(
      _payload([65], fields: {'decoded': true, 'decoded_bytes': 2048}),
    );
    _check(preview.truncated && preview.metadata.contains('"decoded": true'));
  },
  'malformed and oversized Base64 fail safely': () {
    for (final value in ['***', 'A' * 87385]) {
      try {
        formatProcessProxyPayload(_payload([], fields: {'data_base64': value}));
        throw StateError('Expected failure');
      } on ProcessProxyException {}
    }
  },
  'rows without a valid run identity cannot open a payload from another run':
      () {
        _check(
          processProxyTrafficRows({
            'records': [
              {
                'exchange': {
                  'cache': {'id': 1},
                },
              },
            ],
          }).isEmpty,
        );
      },
  'live rows use actual exchange and stream cache identities': () {
    final rows = processProxyTrafficRows({
      'run_id': 'actual-run',
      'records': [
        {
          'type': 'exchange',
          'protocol': 'h2',
          'connection': {'pid': 42},
          'exchange': {
            'cache': {'id': 7},
          },
        },
        {
          'type': 'stream',
          'protocol': 'tcp',
          'stream': {
            'cache': {'id': 8},
          },
        },
        {'type': 'connection', 'status': 'Established'},
      ],
    });
    _check(
      rows.length == 2 &&
          rows.first.cacheId == 7 &&
          rows.first.runId == 'actual-run' &&
          rows.last.cacheId == 8,
    );
  },
};
