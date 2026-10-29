import 'dart:convert';
import 'dart:isolate';

import 'policy.dart';

const processProxyProfilesMaxBytes = 256 * 1024;
const processProxyProfilesMaxCount = 32;
const _format = 'flclash-jing-process-profiles';
const _requestKeys = {
  'backendPath',
  'executable',
  'arguments',
  'bypassRules',
  'includeChildren',
  'bypassPrivateNetworks',
  'blockUdp',
  'remoteDns',
};

class ProcessProxyProfile {
  final String id;
  final String name;
  final ProcessProxyLaunchRequest request;

  ProcessProxyProfile({
    required this.id,
    required this.name,
    required ProcessProxyLaunchRequest request,
  }) : request = _safeRequest(request) {
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,64}$').hasMatch(id) ||
        name.isEmpty ||
        name.length > 64 ||
        name.trim() != name ||
        name.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
      throw const ProcessProxyException('profilesInvalid');
    }
  }

  Map<String, Object> _toJson({required bool includeArguments}) => {
    'id': id,
    'name': name,
    'request': {
      'backendPath': request.backendPath,
      'executable': request.executable,
      'workingDirectory': request.workingDirectory,
      'arguments': includeArguments ? request.arguments : <String>[],
      'bypassRules': request.bypassRules,
      'includeChildren': request.includeChildren,
      'bypassPrivateNetworks': request.bypassPrivateNetworks,
      'blockUdp': request.blockUdp,
      'remoteDns': request.remoteDns,
    },
  };
}

ProcessProxyLaunchRequest _safeRequest(ProcessProxyLaunchRequest request) {
  final validated = ProcessProxyLaunchRequest(
    backendPath: request.backendPath,
    executable: request.executable,
    workingDirectory: request.workingDirectory,
    arguments: List.unmodifiable(request.arguments),
    bypassRules: request.bypassRules,
    includeChildren: request.includeChildren,
    bypassPrivateNetworks: request.bypassPrivateNetworks,
    blockUdp: request.blockUdp,
    remoteDns: request.remoteDns,
    trustedBackend: true,
  );
  validated.validate();
  return ProcessProxyLaunchRequest.fromJson(validated.toJson());
}

void _keys(
  Map<String, dynamic> value,
  Set<String> expected, {
  Set<String> optional = const {},
}) {
  if (!expected.every(value.containsKey) ||
      value.keys.any(
        (key) => !expected.contains(key) && !optional.contains(key),
      )) {
    throw const ProcessProxyException('profilesInvalid');
  }
}

void _checkCollection(List<ProcessProxyProfile> profiles) {
  if (profiles.length > processProxyProfilesMaxCount) {
    throw const ProcessProxyException('profilesLimit');
  }
  final ids = <String>{};
  final names = <String>{};
  for (final profile in profiles) {
    if (!ids.add(profile.id) || !names.add(profile.name.toLowerCase())) {
      throw const ProcessProxyException('profilesConflict');
    }
  }
}

List<ProcessProxyProfile> decodeProcessProxyProfiles(String text) {
  if (text.length > processProxyProfilesMaxBytes ||
      utf8.encode(text).length > processProxyProfilesMaxBytes) {
    throw const ProcessProxyException('profilesTooLarge');
  }
  try {
    _checkStructure(text);
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    _keys(decoded, {'format', 'version', 'profiles'});
    if (decoded['format'] != _format ||
        decoded['version'] is! int ||
        decoded['version'] != 1 ||
        decoded['profiles'] is! List) {
      throw const FormatException();
    }
    final rows = decoded['profiles'] as List;
    if (rows.length > processProxyProfilesMaxCount) {
      throw const ProcessProxyException('profilesLimit');
    }
    final profiles = <ProcessProxyProfile>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) throw const FormatException();
      _keys(row, {'id', 'name', 'request'});
      final request = row['request'];
      if (row['id'] is! String ||
          row['name'] is! String ||
          request is! Map<String, dynamic>) {
        throw const FormatException();
      }
      _keys(request, _requestKeys, optional: {'workingDirectory'});
      if (request.containsKey('workingDirectory') &&
          request['workingDirectory'] is! String) {
        throw const FormatException();
      }
      for (final key in ['backendPath', 'executable', 'bypassRules']) {
        if (request[key] is! String) throw const FormatException();
      }
      for (final key in [
        'includeChildren',
        'bypassPrivateNetworks',
        'blockUdp',
        'remoteDns',
      ]) {
        if (request[key] is! bool) throw const FormatException();
      }
      final arguments = request['arguments'];
      if (arguments is! List || arguments.any((value) => value is! String)) {
        throw const FormatException();
      }
      profiles.add(
        ProcessProxyProfile(
          id: row['id'] as String,
          name: row['name'] as String,
          request: ProcessProxyLaunchRequest.fromJson(request),
        ),
      );
    }
    _checkCollection(profiles);
    return List.unmodifiable(profiles);
  } on ProcessProxyException {
    rethrow;
  } on Object {
    throw const ProcessProxyException('profilesInvalid');
  }
}

String encodeProcessProxyProfiles(
  List<ProcessProxyProfile> profiles, {
  bool includeArguments = false,
}) {
  _checkCollection(profiles);
  final text = const JsonEncoder.withIndent('  ').convert({
    'format': _format,
    'version': 1,
    'profiles': [
      for (final profile in profiles)
        profile._toJson(includeArguments: includeArguments),
    ],
  });
  if (utf8.encode(text).length > processProxyProfilesMaxBytes) {
    throw const ProcessProxyException('profilesTooLarge');
  }
  return text;
}

List<ProcessProxyProfile> mergeProcessProxyProfiles(
  List<ProcessProxyProfile> current,
  List<ProcessProxyProfile> incoming,
) {
  final merged = [...current, ...incoming];
  _checkCollection(merged);
  return List.unmodifiable(merged);
}

// Reject ambiguous duplicate keys and excessive nesting before jsonDecode.
void _checkStructure(String text) {
  final stack = <Set<String>?>[];
  for (var index = 0; index < text.length; index++) {
    final char = text[index];
    if (char == '{' || char == '[') {
      stack.add(char == '{' ? <String>{} : null);
      if (stack.length > 12) throw const FormatException();
    } else if (char == '}' || char == ']') {
      if (stack.isEmpty) throw const FormatException();
      stack.removeLast();
    } else if (char == '"') {
      final start = index++;
      while (index < text.length && text[index] != '"') {
        if (text[index] == r'\') index++;
        index++;
      }
      if (index >= text.length) throw const FormatException();
      var next = index + 1;
      while (next < text.length && ' \n\r\t'.contains(text[next])) {
        next++;
      }
      if (next < text.length && text[next] == ':') {
        final key = jsonDecode(text.substring(start, index + 1)) as String;
        if (stack.isEmpty || stack.last == null || !stack.last!.add(key)) {
          throw const FormatException();
        }
      }
    }
  }
}

abstract interface class ProcessProxyProfileStorage {
  Future<String?> read();
  Future<void> write(String text);
}

class ProcessProxyProfilesRepository {
  final ProcessProxyProfileStorage storage;
  bool _writing = false;

  ProcessProxyProfilesRepository(this.storage);

  Future<List<ProcessProxyProfile>> load() async {
    final text = await storage.read();
    return text == null ? const [] : await decodeImport(text);
  }

  Future<List<ProcessProxyProfile>> decodeImport(String text) =>
      Isolate.run(() => decodeProcessProxyProfiles(text));

  Future<String> exportProfiles(
    List<ProcessProxyProfile> profiles, {
    bool includeArguments = false,
  }) {
    final snapshot = List<ProcessProxyProfile>.unmodifiable(profiles);
    return Isolate.run(
      () => encodeProcessProxyProfiles(
        snapshot,
        includeArguments: includeArguments,
      ),
    );
  }

  Future<void> save(List<ProcessProxyProfile> profiles) async {
    if (_writing) throw const ProcessProxyException('profilesBusy');
    _writing = true;
    try {
      final text = await exportProfiles(profiles, includeArguments: true);
      await storage.write(text);
    } finally {
      _writing = false;
    }
  }
}
