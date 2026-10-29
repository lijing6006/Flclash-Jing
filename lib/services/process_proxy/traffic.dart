import 'dart:convert';

import 'policy.dart';

class ProcessProxyPayloadPreview {
  final String raw;
  final String hex;
  final String metadata;
  final bool truncated;
  final bool incomplete;

  const ProcessProxyPayloadPreview({
    required this.raw,
    required this.hex,
    required this.metadata,
    required this.truncated,
    required this.incomplete,
  });
}

ProcessProxyPayloadPreview formatProcessProxyPayload(
  Map<String, dynamic> response,
) {
  final payload = response['payload'];
  if (payload is! Map || payload['data_base64'] is! String) {
    throw const ProcessProxyException('invalidQuery');
  }
  final encoded = payload['data_base64'] as String;
  if (encoded.length > 87384) {
    throw const ProcessProxyException('bridgeFrameTooLarge');
  }
  final List<int> bytes;
  try {
    bytes = base64Decode(encoded);
  } on FormatException {
    throw const ProcessProxyException('invalidQuery');
  }
  if (bytes.length > 65536) {
    throw const ProcessProxyException('bridgeFrameTooLarge');
  }
  const displayLimit = 16384;
  final preview = bytes.take(displayLimit).toList();
  final offset = payload['offset'];
  if (offset is! int || offset < 0) {
    throw const ProcessProxyException('invalidQuery');
  }
  final hex = StringBuffer();
  for (var start = 0; start < preview.length; start += 16) {
    final line = preview.skip(start).take(16).toList();
    final octets = line
        .map((n) => n.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    final ascii = String.fromCharCodes(
      line.map((n) => n >= 32 && n <= 126 ? n : 46),
    );
    hex.writeln(
      '${(offset + start).toRadixString(16).padLeft(8, '0')}  ${octets.padRight(47)}  $ascii',
    );
  }
  final cache = payload['cache'];
  final cacheMap = cache is Map ? cache : const {};
  final total = payload['direction'] == 'client'
      ? cacheMap['request_bytes']
      : cacheMap['response_bytes'];
  final decodedBytes = payload['decoded_bytes'];
  final warning = payload['warning'];
  final meta = <String, dynamic>{
    'run_id': response['run_id'],
    'direction': payload['direction'],
    'offset': offset,
    'returned_bytes': bytes.length,
    'displayed_bytes': preview.length,
    'decoded': payload['decoded'] == true,
    'decoded_bytes': decodedBytes,
    'warning': warning,
    'decode_error': response['decode_error'],
    'cache': cacheMap,
    if (response['text'] is String) 'dns_text': response['text'],
  };
  final metadata = const JsonEncoder.withIndent('  ').convert(meta);
  if (metadata.length > 65536) {
    throw const ProcessProxyException('bridgeFrameTooLarge');
  }
  final raw = utf8
      .decode(preview, allowMalformed: true)
      .replaceAllMapped(
        RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'),
        (m) => '\\x${m[0]!.codeUnitAt(0).toRadixString(16).padLeft(2, '0')}',
      );
  return ProcessProxyPayloadPreview(
    raw: raw,
    hex: hex.toString(),
    metadata: metadata,
    truncated:
        bytes.length > displayLimit ||
        (decodedBytes is int && decodedBytes > bytes.length) ||
        (payload['decoded'] != true &&
            total is int &&
            total > offset + bytes.length),
    incomplete:
        cacheMap['evicted'] == true ||
        cacheMap['finished'] != true ||
        (cacheMap['pending_chunks'] is int && cacheMap['pending_chunks'] > 0) ||
        cacheMap['reason'] != null ||
        warning != null ||
        response['decode_error'] != null,
  );
}

class ProcessProxyTrafficRow {
  final String label;
  final int cacheId;
  final String runId;

  const ProcessProxyTrafficRow(this.label, this.cacheId, this.runId);
}

List<ProcessProxyTrafficRow> processProxyTrafficRows(
  Map<String, dynamic> response,
) {
  final records = response['records'];
  final runId = response['run_id'];
  if (runId is! String || runId.isEmpty || runId.length > 256) return const [];
  if (records is! List) return const [];
  final rows = <ProcessProxyTrafficRow>[];
  for (final record in records.take(64)) {
    if (record is! Map) continue;
    final content = record['exchange'] ?? record['stream'];
    final cache = content is Map ? content['cache'] : null;
    final id = cache is Map ? cache['id'] : record['cache_id'];
    if (id is! int || id <= 0) continue;
    final connection = record['connection'];
    final pid = connection is Map ? connection['pid'] : null;
    final protocol = record['protocol'];
    final label =
        '${protocol is String ? protocol : record['type']} · PID ${pid is int ? pid : '—'} · #$id';
    rows.add(
      ProcessProxyTrafficRow(
        label.length > 256 ? label.substring(0, 256) : label,
        id,
        runId,
      ),
    );
  }
  return rows;
}
