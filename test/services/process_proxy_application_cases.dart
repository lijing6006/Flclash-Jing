// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';

import '../../lib/services/process_proxy/applications.dart';
import '../../lib/services/process_proxy/policy.dart';

void _check(bool condition) {
  if (!condition) throw StateError('Assertion failed');
}

Map<String, Object> _app({
  String name = 'Browser',
  String executable = r'C:\Apps\browser.exe',
  List<String> arguments = const [],
  String directory = '',
  String source = 'app-paths',
}) => {
  'Name': name,
  'ExecutablePath': executable,
  'Arguments': arguments,
  'WorkingDirectory': directory,
  'Source': source,
};

final Map<String, void Function()> processProxyApplicationCases = {
  'catalog preserves shortcut arguments and working directory exactly': () {
    final app = parseApplicationCandidates(
      jsonEncode([
        _app(
          arguments: ['--profile', 'My Work'],
          directory: r'C:\Profiles\Work',
          source: 'start-menu',
        ),
      ]),
      '',
    ).single;
    _check(
      app.arguments[1] == 'My Work' &&
          app.workingDirectory == r'C:\Profiles\Work',
    );
  },
  'catalog deduplicates same launch across sources case insensitively': () {
    final apps = parseApplicationCandidates(
      jsonEncode([
        _app(),
        _app(executable: r'c:\apps\BROWSER.exe', source: 'start-menu'),
      ]),
      '',
    );
    _check(apps.length == 1);
  },
  'catalog preserves distinct argument values and working directories': () {
    final apps = parseApplicationCandidates(
      jsonEncode([
        _app(arguments: ['Work']),
        _app(arguments: ['work']),
        _app(directory: r'C:\Profile'),
      ]),
      '',
    );
    _check(apps.length == 3);
  },
  'catalog rejects scripts UNC UWP and unknown sources': () {
    final apps = parseApplicationCandidates(
      jsonEncode([
        _app(executable: r'C:\test.cmd'),
        _app(executable: r'\\server\tool.exe'),
        _app(executable: 'Package!App'),
        _app(source: 'untrusted'),
      ]),
      '',
    );
    _check(apps.isEmpty);
  },
  'catalog rejects invalid working directories and control labels': () {
    final apps = parseApplicationCandidates(
      jsonEncode([_app(directory: '../other'), _app(name: 'Bad\nname')]),
      '',
    );
    _check(apps.isEmpty);
  },
  'catalog search is literal and never part of shell source': () {
    final rows = jsonEncode([_app(name: r'Browser $(whoami)')]);
    _check(parseApplicationCandidates(rows, r'$(whoami)').length == 1);
    _check(parseApplicationCandidates(rows, 'not-present').isEmpty);
  },
  'catalog bounds result count and malformed arguments': () {
    final apps = parseApplicationCandidates(
      jsonEncode([
        for (var i = 0; i < 300; i++)
          _app(name: '$i', executable: 'C:\\Apps\\$i.exe'),
      ]),
      '',
    );
    _check(apps.length == 200);
    _check(
      parseApplicationCandidates(
        jsonEncode([
          _app(arguments: ['a\x00b']),
        ]),
        '',
      ).isEmpty,
    );
  },
  'catalog rejects oversized source before decoding': () {
    try {
      parseApplicationCandidates('x' * (4 * 1024 * 1024 + 1), '');
      throw StateError('Expected bound');
    } on ProcessProxyException catch (error) {
      _check(error.code == 'responseTooLarge');
    }
  },
  'catalog query never saves shortcuts or invokes their target': () {
    _check(!processProxyApplicationQuery.contains('.Save('));
    _check(!processProxyApplicationQuery.contains('Start-Process'));
    _check(processProxyApplicationQuery.contains('ReparsePoint'));
    _check(processProxyApplicationQuery.contains('OpenSubKey'));
  },
};
