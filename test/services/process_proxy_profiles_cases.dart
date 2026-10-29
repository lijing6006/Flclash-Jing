import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../lib/services/process_proxy/policy.dart';
import '../../lib/services/process_proxy/profile_storage.dart';
import '../../lib/services/process_proxy/profiles.dart';

void _check(bool condition) {
  if (!condition) throw StateError('Assertion failed');
}

void _fails(void Function() action, String code) {
  try {
    action();
  } on ProcessProxyException catch (error) {
    _check(error.code == code);
    return;
  }
  throw StateError('Expected $code');
}

Future<void> _failsAsync(Future<void> Function() action, String code) async {
  try {
    await action();
  } on ProcessProxyException catch (error) {
    _check(error.code == code);
    return;
  }
  throw StateError('Expected $code');
}

const _request = ProcessProxyLaunchRequest(
  backendPath: r'C:\Tools\ProxyLane64.exe',
  executable: r'C:\Program Files\Browser\browser.exe',
  workingDirectory: r'C:\Work',
  arguments: ['--token', 'private-token', 'a b', '&whoami', ''],
  bypassRules: 'internal.example\n10.0.0.0/8',
  remoteDns: true,
  includeChildren: false,
  bypassPrivateNetworks: false,
  trustedBackend: true,
  prepareQuic: true,
  decryptHttps: true,
  decryptQuic: true,
);

ProcessProxyProfile _profile({String id = 'one', String name = 'Work'}) =>
    ProcessProxyProfile(id: id, name: name, request: _request);

Map<String, dynamic> _document() =>
    jsonDecode(encodeProcessProxyProfiles([_profile()], includeArguments: true))
        as Map<String, dynamic>;

Map<String, dynamic> _fields(Map<String, dynamic> document) =>
    ((document['profiles'] as List).first as Map<String, dynamic>)['request']
        as Map<String, dynamic>;

class _Storage implements ProcessProxyProfileStorage {
  String? text;
  int writes = 0;
  bool failWrite = false;
  Completer<void>? pending;
  Completer<void>? started;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> write(String value) async {
    writes++;
    started?.complete();
    if (pending case final wait?) await wait.future;
    if (failWrite) throw const ProcessProxyException('profilesStorage');
    text = value;
  }
}

Future<void> _withFiles(
  Future<void> Function(Directory root, FileProcessProxyProfileStorage storage)
  action,
) async {
  final root = await Directory.systemTemp.createTemp('flclash-profile-test-');
  try {
    await action(
      root,
      FileProcessProxyProfileStorage(directory: () async => root),
    );
  } finally {
    await root.delete(recursive: true);
  }
}

File _profileFile(Directory root) => File(
  '${root.path}${Platform.pathSeparator}process-proxy'
  '${Platform.pathSeparator}profiles.json',
);

final Map<String, FutureOr<void> Function()> processProxyProfilesCases = {
  'round trip preserves accepted launch values and working directory': () {
    final decoded = decodeProcessProxyProfiles(jsonEncode(_document())).single;
    _check(decoded.name == 'Work' && decoded.id == 'one');
    _check(
      jsonEncode(decoded.request.toJson()) == jsonEncode(_request.toJson()),
    );
  },
  'profile construction removes every sensitive consent': () {
    final request = _profile().request;
    _check(!request.trustedBackend && !request.prepareQuic);
    _check(!request.decryptHttps && !request.decryptQuic);
  },
  'default export omits all arguments including positional secrets': () {
    final text = encodeProcessProxyProfiles([_profile()]);
    _check(!text.contains('private-token') && !text.contains('--token'));
    _check(decodeProcessProxyProfiles(text).single.request.arguments.isEmpty);
  },
  'explicit argument export preserves exact token boundaries': () {
    final text = encodeProcessProxyProfiles([
      _profile(),
    ], includeArguments: true);
    _check(text.contains('private-token'));
    final args = decodeProcessProxyProfiles(text).single.request.arguments;
    _check(args[2] == 'a b' && args[3] == '&whoami' && args.last.isEmpty);
  },
  'export never contains backend consent or proxy credentials fields': () {
    final fields = _fields(_document());
    for (final key in [
      'trustedBackend',
      'prepareQuic',
      'decryptHttps',
      'decryptQuic',
      'username',
      'password',
      'port',
    ]) {
      _check(!fields.containsKey(key));
    }
  },
  'profile arguments are copied and immutable': () {
    final arguments = ['original'];
    final profile = ProcessProxyProfile(
      id: 'immutable',
      name: 'Immutable',
      request: ProcessProxyLaunchRequest(
        backendPath: _request.backendPath,
        executable: _request.executable,
        arguments: arguments,
      ),
    );
    arguments.add('later');
    _check(profile.request.arguments.length == 1);
    try {
      profile.request.arguments.add('unsafe');
    } on UnsupportedError {
      return;
    }
    throw StateError('Profile arguments were mutable');
  },
  'legacy version one profile may omit optional working directory': () {
    final doc = _document();
    _fields(doc).remove('workingDirectory');
    _check(
      decodeProcessProxyProfiles(jsonEncode(doc))
          .single
          .request
          .workingDirectory
          .isEmpty,
    );
  },
  'unknown top level fields are rejected': () {
    final doc = _document()..['command'] = 'start';
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'profilesInvalid',
    );
  },
  'unknown request fields cannot smuggle permissions or credentials': () {
    for (final key in [
      'trustedBackend',
      'prepareQuic',
      'password',
      'decryptHttps',
    ]) {
      final doc = _document();
      _fields(doc)[key] = true;
      _fails(
        () => decodeProcessProxyProfiles(jsonEncode(doc)),
        'profilesInvalid',
      );
    }
  },
  'missing required request fields are rejected rather than defaulted': () {
    final doc = _document();
    _fields(doc).remove('blockUdp');
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'profilesInvalid',
    );
  },
  'wrong field types are rejected without coercion': () {
    for (final change in <String, Object?>{
      'blockUdp': 'false',
      'arguments': [1],
      'backendPath': null,
      'workingDirectory': 3,
    }.entries) {
      final doc = _document();
      _fields(doc)[change.key] = change.value;
      _fails(
        () => decodeProcessProxyProfiles(jsonEncode(doc)),
        'profilesInvalid',
      );
    }
  },
  'unsupported formats and noninteger versions are rejected': () {
    for (final change in <String, Object>{
      'format': 'other',
      'version': 1.0,
    }.entries) {
      final doc = _document()..[change.key] = change.value;
      _fails(
        () => decodeProcessProxyProfiles(jsonEncode(doc)),
        'profilesInvalid',
      );
    }
    final doc = _document()..['version'] = 2;
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'profilesInvalid',
    );
  },
  'executable restrictions apply before import': () {
    final doc = _document();
    _fields(doc)['executable'] = r'\\server\run.cmd';
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'invalidExecutable',
    );
  },
  'working directory restrictions apply before import': () {
    final doc = _document();
    _fields(doc)['workingDirectory'] = r'C:\Work\..\Secret';
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'invalidWorkingDirectory',
    );
  },
  'backend file name restrictions apply before import': () {
    final doc = _document();
    _fields(doc)['backendPath'] = r'C:\Tools\Other.exe';
    _fails(() => decodeProcessProxyProfiles(jsonEncode(doc)), 'backendName');
  },
  'argument count and NUL restrictions apply before import': () {
    for (final args in [
      List.filled(129, 'a'),
      ['bad\x00argument'],
    ]) {
      final doc = _document();
      _fields(doc)['arguments'] = args;
      _fails(
        () => decodeProcessProxyProfiles(jsonEncode(doc)),
        'invalidArguments',
      );
    }
  },
  'bypass input is validated before import': () {
    final doc = _document();
    _fields(doc)['bypassRules'] = '*';
    _fails(
      () => decodeProcessProxyProfiles(jsonEncode(doc)),
      'invalidBypassRule',
    );
  },
  'duplicate profile names are rejected case insensitively': () {
    _fails(
      () => mergeProcessProxyProfiles(
        [_profile()],
        [_profile(id: 'two', name: 'work')],
      ),
      'profilesConflict',
    );
  },
  'duplicate IDs cannot overwrite existing profiles': () {
    _fails(
      () => mergeProcessProxyProfiles([_profile()], [_profile(name: 'Other')]),
      'profilesConflict',
    );
  },
  'merge retains existing profiles and does not mutate the input': () {
    final original = [_profile()];
    final merged = mergeProcessProxyProfiles(original, [
      _profile(id: 'two', name: 'Other'),
    ]);
    _check(original.length == 1 && merged.length == 2);
    _check(merged.first.id == original.first.id);
  },
  'invalid profile names and IDs are rejected': () {
    for (final name in ['', ' padded ', 'bad\nname', 'x' * 65]) {
      _fails(() => _profile(name: name), 'profilesInvalid');
    }
    _fails(() => _profile(id: '../bad'), 'profilesInvalid');
  },
  'duplicate JSON keys are rejected even when unicode escaped': () {
    final text = jsonEncode(_document());
    _fails(
      () => decodeProcessProxyProfiles(
        text.replaceFirst('"version":1', r'"version":1,"\u0076ersion":1'),
      ),
      'profilesInvalid',
    );
  },
  'duplicate nested request keys are rejected': () {
    final text = jsonEncode(_document());
    _fails(
      () => decodeProcessProxyProfiles(
        text.replaceFirst(
          '"blockUdp":true',
          '"blockUdp":false,"blockUdp":true',
        ),
      ),
      'profilesInvalid',
    );
  },
  'escaped quotes and structural characters inside arguments are preserved':
      () {
        final doc = _document();
        _fields(doc)['arguments'] = [r'{"quoted":[]}\\', 'line\nbreak'];
        final profile = decodeProcessProxyProfiles(jsonEncode(doc)).single;
        _check(profile.request.arguments.last == 'line\nbreak');
      },
  'excessive JSON nesting is rejected before decoding': () {
    _fails(
      () => decodeProcessProxyProfiles('${'[' * 20}0${']' * 20}'),
      'profilesInvalid',
    );
  },
  'UTF8 byte limit applies before decoding': () {
    _fails(
      () =>
          decodeProcessProxyProfiles('x' * (processProxyProfilesMaxBytes + 1)),
      'profilesTooLarge',
    );
    _fails(() => decodeProcessProxyProfiles('界' * 90000), 'profilesTooLarge');
  },
  'profile count limit applies on encode and decode': () {
    final profiles = List.generate(
      33,
      (i) => _profile(id: 'id$i', name: 'Name$i'),
    );
    _fails(() => encodeProcessProxyProfiles(profiles), 'profilesLimit');
    final doc = _document();
    doc['profiles'] = List.filled(33, (doc['profiles'] as List).single);
    _fails(() => decodeProcessProxyProfiles(jsonEncode(doc)), 'profilesLimit');
  },
  'empty storage loads without writing': () async {
    final storage = _Storage();
    _check((await ProcessProxyProfilesRepository(storage).load()).isEmpty);
    _check(storage.writes == 0);
  },
  'repository storage preserves arguments but never sensitive consent':
      () async {
        final storage = _Storage();
        final repository = ProcessProxyProfilesRepository(storage);
        await repository.save([_profile()]);
        final saved = (await repository.load()).single.request;
        _check(
          saved.arguments[1] == 'private-token' &&
              !saved.trustedBackend &&
              !saved.prepareQuic,
        );
      },
  'invalid import leaves current storage unchanged': () async {
    final storage = _Storage()..text = encodeProcessProxyProfiles([_profile()]);
    final previous = storage.text;
    _fails(
      () => decodeProcessProxyProfiles('{"format":"invalid"}'),
      'profilesInvalid',
    );
    _check(storage.text == previous && storage.writes == 0);
  },
  'invalid collection cannot overwrite current storage': () async {
    final storage = _Storage()..text = encodeProcessProxyProfiles([_profile()]);
    final previous = storage.text;
    final repository = ProcessProxyProfilesRepository(storage);
    await _failsAsync(
      () => repository.save([_profile(), _profile()]),
      'profilesConflict',
    );
    _check(storage.text == previous && storage.writes == 0);
    await repository.save([]);
    _check(storage.writes == 1);
  },
  'write failure retains old data and leaves repository retryable': () async {
    final storage = _Storage()
      ..text = encodeProcessProxyProfiles([_profile()])
      ..failWrite = true;
    final previous = storage.text;
    final repository = ProcessProxyProfilesRepository(storage);
    await _failsAsync(() => repository.save([]), 'profilesStorage');
    _check(storage.text == previous);
    storage.failWrite = false;
    await repository.save([]);
    _check((await repository.load()).isEmpty);
  },
  'overlapping writes are rejected rather than racing the pending file':
      () async {
        final storage = _Storage()
          ..pending = Completer<void>()
          ..started = Completer<void>();
        final repository = ProcessProxyProfilesRepository(storage);
        final first = repository.save([_profile()]);
        await storage.started!.future;
        await _failsAsync(() => repository.save([]), 'profilesBusy');
        storage.pending!.complete();
        await first;
        _check(storage.writes == 1);
      },
  'file storage does not create profiles while reading an empty location': () =>
      _withFiles((root, storage) async {
        _check(await storage.read() == null);
        _check(!await _profileFile(root).parent.exists());
      }),
  'file replacement keeps the previous plaintext backup and removes pending':
      () => _withFiles((root, storage) async {
        final first = encodeProcessProxyProfiles([
          _profile(),
        ], includeArguments: true);
        final second = encodeProcessProxyProfiles([]);
        await storage.write(first);
        await storage.write(second);
        final file = _profileFile(root);
        _check(await storage.read() == second);
        _check(await File('${file.path}.backup').readAsString() == first);
        _check(!await File('${file.path}.pending').exists());
      }),
  'file read rejects oversize bytes without parsing': () =>
      _withFiles((root, storage) async {
        final file = _profileFile(root);
        await file.parent.create();
        await file.writeAsString('x' * (processProxyProfilesMaxBytes + 1));
        await _failsAsync(() async {
          await storage.read();
        }, 'profilesTooLarge');
      }),
  'oversize write preserves old file and creates no pending file': () =>
      _withFiles((root, storage) async {
        final first = encodeProcessProxyProfiles([_profile()]);
        await storage.write(first);
        await _failsAsync(
          () => storage.write('x' * (processProxyProfilesMaxBytes + 1)),
          'profilesTooLarge',
        );
        _check(await storage.read() == first);
        _check(!await File('${_profileFile(root).path}.pending').exists());
      }),
  'invalid UTF8 file is rejected': () => _withFiles((root, storage) async {
    final file = _profileFile(root);
    await file.parent.create();
    await file.writeAsBytes([0xff, 0xfe]);
    await _failsAsync(() async {
      await storage.read();
    }, 'profilesInvalid');
  }),
  'directory masquerading as profile file is rejected without changes': () =>
      _withFiles((root, storage) async {
        final path = _profileFile(root).path;
        await Directory(path).create(recursive: true);
        await _failsAsync(
          () => storage.write(encodeProcessProxyProfiles([])),
          'profilesStorage',
        );
        _check(await Directory(path).exists());
      }),
  if (!Platform.isWindows)
    'symbolic profile file cannot redirect reads or writes': () =>
        _withFiles((root, storage) async {
          final file = _profileFile(root);
          await file.parent.create();
          final sentinel = File('${root.path}/sentinel.json');
          await sentinel.writeAsString('untouched');
          await Link(file.path).create(sentinel.path);
          await _failsAsync(() async {
            await storage.read();
          }, 'profilesStorage');
          await _failsAsync(
            () => storage.write(encodeProcessProxyProfiles([])),
            'profilesStorage',
          );
          _check(await sentinel.readAsString() == 'untouched');
        }),
  if (!Platform.isWindows)
    'symbolic profile directory cannot redirect reads or writes': () =>
        _withFiles((root, storage) async {
          final redirected = await Directory('${root.path}/redirected')
              .create();
          await Link(_profileFile(root).parent.path).create(redirected.path);
          await _failsAsync(() async {
            await storage.read();
          }, 'profilesStorage');
          await _failsAsync(
            () => storage.write(encodeProcessProxyProfiles([])),
            'profilesStorage',
          );
          _check(await redirected.list().isEmpty);
        }),
  if (!Platform.isWindows)
    'symbolic backup cannot replace an unrelated file': () =>
        _withFiles((root, storage) async {
          final first = encodeProcessProxyProfiles([_profile()]);
          await storage.write(first);
          final sentinel = File('${root.path}/sentinel.json');
          await sentinel.writeAsString('untouched');
          await Link('${_profileFile(root).path}.backup').create(sentinel.path);
          await _failsAsync(
            () => storage.write(encodeProcessProxyProfiles([])),
            'profilesStorage',
          );
          _check(await sentinel.readAsString() == 'untouched');
          _check(await storage.read() == first);
        }),
};
