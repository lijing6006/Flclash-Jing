import 'dart:convert';

import 'policy.dart';

const _maxNumber = 9007199254740991;

class ProcessProxyRecordInput {
  final Map<String, dynamic> record;
  final String runId;
  final int? cacheId;
  final String? connectionId;

  const ProcessProxyRecordInput({
    required this.record,
    required this.runId,
    this.cacheId,
    this.connectionId,
  });
}

class ProcessProxyHeader {
  final String name;
  final String value;
  const ProcessProxyHeader(this.name, this.value);
}

class ProcessProxyHttpMessage {
  final String summary;
  final List<ProcessProxyHeader> headers;
  final List<ProcessProxyHeader> trailers;
  final bool headersAvailable;
  final bool truncated;
  final bool complete;

  const ProcessProxyHttpMessage({
    required this.summary,
    required this.headers,
    required this.trailers,
    required this.headersAvailable,
    required this.truncated,
    required this.complete,
  });
}

class ProcessProxyDatagram {
  final int offset;
  final int length;
  const ProcessProxyDatagram(this.offset, this.length);
  int get previewLength => length > 16384 ? 16384 : length;
}

class ProcessProxyDatagramDirection {
  final List<ProcessProxyDatagram> packets;
  final int? reportedCount;
  final bool indexed;
  final bool truncated;

  const ProcessProxyDatagramDirection({
    required this.packets,
    required this.reportedCount,
    required this.indexed,
    required this.truncated,
  });
}

class ProcessProxyRecordDetail {
  final ProcessProxyRecordInput identity;
  final String protocol;
  final String context;
  final bool encrypted;
  final bool truncated;
  final ProcessProxyHttpMessage? request;
  final ProcessProxyHttpMessage? response;
  final List<ProcessProxyHttpMessage> informational;
  final List<ProcessProxyDatagramDirection> datagrams;

  const ProcessProxyRecordDetail({
    required this.identity,
    required this.protocol,
    required this.context,
    required this.encrypted,
    required this.truncated,
    required this.request,
    required this.response,
    required this.informational,
    required this.datagrams,
  });
}

Never _invalid() => throw const ProcessProxyException('bridgeProtocolError');

int _number(Object? value) {
  if (value is! int || value < 0 || value > _maxNumber) _invalid();
  return value;
}

Map _object(Object? value) {
  if (value == null) return const {};
  if (value is! Map) _invalid();
  return value;
}

class _TextBudget {
  int remaining = 48 * 1024;
  int pairsRemaining = 256;
  bool truncated = false;

  String take(Object? value, {int limit = 4096}) {
    if (value == null) return '';
    if (value is! String && value is! int) _invalid();
    final escaped = value.toString().replaceAllMapped(
      RegExp(r'[\x00-\x1f\x7f]'),
      (m) => '\\x${m[0]!.codeUnitAt(0).toRadixString(16).padLeft(2, '0')}',
    );
    final bytes = utf8.encode(escaped);
    final available = remaining < limit ? remaining : limit;
    var end = bytes.length > available ? available : bytes.length;
    if (end < bytes.length) {
      while (end > 0 && (bytes[end] & 0xc0) == 0x80) {
        end--;
      }
      truncated = true;
    }
    remaining -= end;
    return utf8.decode(bytes.sublist(0, end));
  }
}

List<ProcessProxyHeader> _headers(Object? value, _TextBudget budget) {
  if (value == null) return const [];
  if (value is! List) _invalid();
  final pairs = <ProcessProxyHeader>[];
  for (var i = 0; i < value.length; i++) {
    final pair = value[i];
    if (pair is! List ||
        pair.length != 2 ||
        pair[0] is! String ||
        pair[1] is! String) {
      _invalid();
    }
    if (i >= 128 || budget.remaining == 0 || budget.pairsRemaining == 0) {
      budget.truncated = true;
      continue;
    }
    budget.pairsRemaining--;
    pairs.add(ProcessProxyHeader(budget.take(pair[0]), budget.take(pair[1])));
  }
  return List.unmodifiable(pairs);
}

ProcessProxyHttpMessage? _message(Object? value, _TextBudget budget) {
  final message = _object(value);
  if (message.isEmpty) return null;
  final previousTruncation = budget.truncated;
  budget.truncated = false;
  final status = message['status'];
  if (status != null) _number(status);
  final summary = [
    if (message['method'] != null) budget.take(message['method'], limit: 128),
    if (message['target'] != null) budget.take(message['target']),
    if (status != null) '$status',
  ].join(' ');
  final headers = _headers(message['headers'], budget);
  final trailers = _headers(message['trailers'], budget);
  final truncated = budget.truncated;
  budget.truncated |= previousTruncation;
  return ProcessProxyHttpMessage(
    summary: summary,
    headers: headers,
    trailers: trailers,
    headersAvailable: message['headers'] is List,
    truncated: truncated,
    complete: message['complete'] == true,
  );
}

List<ProcessProxyDatagramDirection> _datagrams(Map stream) {
  final raw = stream['datagrams'];
  final counts = stream['packet_counts'];
  if (raw != null && (raw is! List || raw.length != 2)) _invalid();
  if (counts != null && (counts is! List || counts.length != 2)) _invalid();
  final directions = <ProcessProxyDatagramDirection>[];
  for (var side = 0; side < 2; side++) {
    final values = raw == null ? null : (raw as List)[side];
    if (values != null && values is! List) _invalid();
    final packets = <ProcessProxyDatagram>[];
    var previousEnd = 0;
    for (final value in values ?? const []) {
      if (value is! List || value.length != 2) _invalid();
      final offset = _number(value[0]);
      final length = _number(value[1]);
      if (offset < previousEnd || length > _maxNumber - offset) _invalid();
      previousEnd = offset + length;
      if (packets.length < 128) {
        packets.add(ProcessProxyDatagram(offset, length));
      }
    }
    final count = counts == null ? null : _number((counts as List)[side]);
    directions.add(
      ProcessProxyDatagramDirection(
        packets: List.unmodifiable(packets),
        reportedCount: count,
        indexed: values != null,
        truncated:
            (values is List && values.length > packets.length) ||
            (count != null && count > packets.length),
      ),
    );
  }
  return List.unmodifiable(directions);
}

ProcessProxyRecordDetail parseProcessProxyRecordDetail(
  ProcessProxyRecordInput input,
) {
  if (input.runId.isEmpty ||
      utf8.encode(input.runId).length > 256 ||
      input.runId.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
    _invalid();
  }
  if ((input.cacheId == null) == (input.connectionId == null)) _invalid();
  final record = input.record;
  final connection = _object(record['connection']);
  final exchange = _object(record['exchange']);
  final stream = _object(record['stream']);
  final ids = [
    record['cache_id'],
    _object(exchange['cache'])['id'],
    _object(stream['cache'])['id'],
  ].where((id) => id != null).toList();
  if (input.cacheId case final id?) {
    if (_number(id) == 0 ||
        ids.isEmpty ||
        ids.any((actual) => actual is! int || actual != id)) {
      _invalid();
    }
  } else if (input.connectionId == null ||
      !RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(input.connectionId!) ||
      connection['id'] != input.connectionId ||
      record['type'] != 'connection') {
    _invalid();
  }
  if (record['run_id'] != null && record['run_id'] != input.runId) _invalid();
  final budget = _TextBudget();
  final protocol = budget.take(record['protocol'], limit: 128);
  final context = [
    budget.take(connection['process_name'], limit: 256),
    if (connection['pid'] != null) 'PID ${_number(connection['pid'])}',
    budget.take(connection['destination'], limit: 512),
    budget.take(connection['id'], limit: 128),
    budget.take(record['status'], limit: 128),
  ].where((s) => s.isNotEmpty).join(' · ');
  final isHttp =
      record['type'] == 'exchange' &&
      const {'http1', 'h2', 'h3'}.contains(protocol);
  final request = isHttp ? _message(exchange['request'], budget) : null;
  final response = isHttp ? _message(exchange['response'], budget) : null;
  final information = <ProcessProxyHttpMessage>[];
  if (isHttp && exchange['informational'] != null) {
    final values = exchange['informational'];
    if (values is! List) _invalid();
    for (var i = 0; i < values.length; i++) {
      if (i >= 16) {
        budget.truncated = true;
        break;
      }
      final message = _message(values[i], budget);
      if (message != null) information.add(message);
    }
  }
  final udp =
      record['type'] == 'stream' &&
      const {'udp', 'quic', 'quic_datagram'}.contains(protocol);
  return ProcessProxyRecordDetail(
    identity: input,
    protocol: protocol,
    context: context,
    encrypted: const {'tls_encrypted', 'quic'}.contains(protocol),
    truncated: budget.truncated,
    request: request,
    response: response,
    informational: List.unmodifiable(information),
    datagrams: udp ? _datagrams(stream) : const [],
  );
}
