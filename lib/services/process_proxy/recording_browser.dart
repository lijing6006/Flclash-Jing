import 'dart:convert';

import 'policy.dart';

const _maxId = 9007199254740991;

class ProcessProxyRecordingQuery {
  final int offset;
  final int limit;
  final String filter;
  final int protocol;

  const ProcessProxyRecordingQuery({
    this.offset = 0,
    this.limit = 16,
    this.filter = '',
    this.protocol = 0,
  });

  Map<String, dynamic> toJson() {
    if (offset < 0 ||
        offset > _maxId ||
        limit < 1 ||
        limit > 64 ||
        protocol < 0 ||
        protocol > 6 ||
        utf8.encode(filter).length > 256 ||
        filter.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
      throw const ProcessProxyException('recordingQueryInvalid');
    }
    return {
      'type': 'recording_page',
      'offset': offset,
      'limit': limit,
      'filter': filter,
      'protocol': protocol,
    };
  }
}

class ProcessProxyRecordingRow {
  final String runId;
  final int? cacheId;
  final String? connectionId;
  final String label;
  final String context;

  const ProcessProxyRecordingRow({
    required this.runId,
    required this.label,
    required this.context,
    this.cacheId,
    this.connectionId,
  });

  Map<String, dynamic> detailQuery() {
    _recordingRun(runId);
    if ((cacheId == null) == (connectionId == null)) _invalid();
    if (cacheId != null) _integer(cacheId, minimum: 1);
    if (connectionId != null) _connectionId(connectionId);
    return {
      'type': 'recording_detail',
      'run_id': runId,
      if (cacheId != null) 'cache_id': cacheId,
      if (connectionId != null) 'connection_id': connectionId,
      'preview_bytes': 16384,
    };
  }
}

class ProcessProxyRecordingText {
  final String text;
  final bool truncated;

  const ProcessProxyRecordingText(this.text, this.truncated);
}

class ProcessProxyRecordingPage {
  final String runId;
  final List<ProcessProxyRecordingRow> rows;
  final int offset;
  final int total;
  final int all;
  final int warnings;
  final ProcessProxyRecordingText metadata;

  const ProcessProxyRecordingPage({
    required this.runId,
    required this.rows,
    required this.offset,
    required this.total,
    required this.all,
    required this.warnings,
    required this.metadata,
  });

  int get nextOffset => offset + rows.length;
  bool get stalled => rows.isEmpty && offset < total;
  bool get hasNext => !stalled && nextOffset < total;
}

Never _invalid() => throw const ProcessProxyException('bridgeProtocolError');

int _integer(Object? value, {int minimum = 0}) {
  if (value is! int || value < minimum || value > _maxId) _invalid();
  return value;
}

String _recordingRun(Object? value) {
  if (value is! String ||
      !value.startsWith('recording:') ||
      value.length <= 'recording:'.length ||
      utf8.encode(value).length > 256 ||
      value.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
    _invalid();
  }
  return value;
}

String _connectionId(Object? value) {
  if (value is! String || !RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(value)) {
    _invalid();
  }
  return value;
}

String _display(Object? value) {
  if (value is! String && value is! int) return '';
  final text = value.toString().replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ');
  return text.length > 192 ? '${text.substring(0, 192)}…' : text;
}

ProcessProxyRecordingRow _row(Map<String, dynamic> record, String runId) {
  if (record['format'] != 'ProxyLaneSession' ||
      record['version'] is! int ||
      record['version'] != 2) {
    _invalid();
  }
  final type = record['type'];
  if (!const {'connection', 'exchange', 'stream', 'dns'}.contains(type)) {
    _invalid();
  }
  final connection = record['connection'];
  if (connection is! Map) _invalid();
  final int? cacheId;
  final String? connectionId;
  if (type == 'connection') {
    cacheId = null;
    connectionId = _connectionId(connection['id']);
  } else {
    cacheId = _integer(record['cache_id'], minimum: 1);
    connectionId = null;
  }
  final exchange = record['exchange'];
  final request = exchange is Map ? exchange['request'] : null;
  final protocol = _display(record['protocol']);
  final method = request is Map ? _display(request['method']) : '';
  final target = request is Map ? _display(request['target']) : '';
  final destination = _display(connection['destination']);
  return ProcessProxyRecordingRow(
    runId: runId,
    cacheId: cacheId,
    connectionId: connectionId,
    label: [
      protocol.isEmpty ? _display(type) : protocol,
      if (method.isNotEmpty) method,
      if (target.isNotEmpty)
        target
      else if (destination.isNotEmpty)
        destination,
    ].join(' · '),
    context: [
      if (_display(connection['process_name']).isNotEmpty)
        _display(connection['process_name']),
      'PID ${_display(connection['pid'])}',
      cacheId == null ? connectionId! : '#$cacheId',
      if (_display(record['status']).isNotEmpty) _display(record['status']),
    ].join(' · '),
  );
}

ProcessProxyRecordingText _format(Object? value) {
  final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(value));
  const limit = 48 * 1024;
  var end = bytes.length > limit ? limit : bytes.length;
  if (end < bytes.length) {
    while (end > 0 && (bytes[end] & 0xc0) == 0x80) {
      end--;
    }
  }
  return ProcessProxyRecordingText(
    utf8.decode(bytes.sublist(0, end)),
    bytes.length > limit,
  );
}

ProcessProxyRecordingPage parseProcessProxyRecordingPage(
  Map<String, dynamic> response,
) {
  if (response['type'] != 'records') _invalid();
  final runId = _recordingRun(response['run_id']);
  final offset = _integer(response['offset']);
  final total = _integer(response['total']);
  final all = _integer(response['all']);
  final warnings = _integer(response['warnings']);
  final records = response['records'];
  if (records is! List ||
      records.length > 64 ||
      total > all ||
      offset > total ||
      offset + records.length > total) {
    _invalid();
  }
  final rows = <ProcessProxyRecordingRow>[];
  final identities = <String>{};
  for (final record in records) {
    if (record is! Map<String, dynamic>) _invalid();
    final row = _row(record, runId);
    if (!identities.add('${row.cacheId}:${row.connectionId}')) _invalid();
    rows.add(row);
  }
  return ProcessProxyRecordingPage(
    runId: runId,
    rows: List.unmodifiable(rows),
    offset: offset,
    total: total,
    all: all,
    warnings: warnings,
    metadata: _format({
      'run_id': runId,
      'offset': offset,
      'total': total,
      'all': all,
      'warnings': warnings,
      'manifest': response['manifest'],
      'directory': response['directory'],
    }),
  );
}

void validateProcessProxyRecordingPage(
  ProcessProxyRecordingPage page,
  ProcessProxyRecordingQuery query, {
  String? previousRunId,
}) {
  query.toJson();
  if (page.rows.length > query.limit ||
      page.offset != (query.offset > page.total ? page.total : query.offset)) {
    _invalid();
  }
  if (previousRunId != null && page.runId != previousRunId) {
    throw const ProcessProxyException('recordingChanged');
  }
}

ProcessProxyRecordingText formatProcessProxyRecordingDetail(
  ({Map<String, dynamic> response, ProcessProxyRecordingRow row}) input,
) {
  input.row.detailQuery();
  final actual = _row(input.response, input.row.runId);
  if (actual.cacheId != input.row.cacheId ||
      actual.connectionId != input.row.connectionId) {
    _invalid();
  }
  return _format(input.response);
}
