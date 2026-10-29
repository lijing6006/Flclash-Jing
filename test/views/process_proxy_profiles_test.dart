import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/services/process_proxy/policy.dart';
import 'package:fl_clash/services/process_proxy/profiles.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy/profiles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _request = ProcessProxyLaunchRequest(
  backendPath: r'C:\Tools\ProxyLane64.exe',
  executable: r'C:\Apps\Example.exe',
  workingDirectory: r'C:\Work',
  arguments: ['--token', 'private-token'],
  proxyOnlyRules: '*.example.com',
  childRules: 'launcher.exe',
  childRuleInclude: true,
  trustedBackend: true,
  prepareQuic: true,
  decryptHttps: true,
);

ProcessProxyProfile _profile(String name) =>
    ProcessProxyProfile(id: name.toLowerCase(), name: name, request: _request);

class _UnusedStorage implements ProcessProxyProfileStorage {
  @override
  Future<String?> read() => throw StateError('Unexpected storage access');

  @override
  Future<void> write(String text) =>
      throw StateError('Unexpected storage access');
}

class _Repository extends ProcessProxyProfilesRepository {
  List<ProcessProxyProfile> profiles = [];
  int writes = 0;
  bool failLoad = false;
  bool failSave = false;
  Completer<void>? pendingSave;

  _Repository() : super(_UnusedStorage());

  @override
  Future<List<ProcessProxyProfile>> load() async {
    if (failLoad) throw const ProcessProxyException('profilesStorage');
    return profiles;
  }

  @override
  Future<void> save(List<ProcessProxyProfile> values) async {
    encodeProcessProxyProfiles(values);
    if (pendingSave case final pending?) await pending.future;
    if (failSave) throw const ProcessProxyException('profilesStorage');
    profiles = List.unmodifiable(values);
    writes++;
  }

  @override
  Future<List<ProcessProxyProfile>> decodeImport(String text) async =>
      decodeProcessProxyProfiles(text);

  @override
  Future<String> exportProfiles(
    List<ProcessProxyProfile> profiles, {
    bool includeArguments = false,
  }) async =>
      encodeProcessProxyProfiles(profiles, includeArguments: includeArguments);
}

class _Harness {
  final repository = _Repository();
  final exported = <String>[];
  String? importText;
  Completer<String?>? pendingImport;
  ProcessProxyLaunchRequest? selected;
}

Future<void> _pump(WidgetTester tester, _Harness harness) async {
  const size = Size(1200, 1800);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async {
                  harness.selected =
                      await BaseNavigator.push<ProcessProxyLaunchRequest>(
                        context,
                        ProcessProxyProfilesView(
                          currentRequest: _request,
                          repository: harness.repository,
                          importText: () async {
                            final pending = harness.pendingImport;
                            if (pending != null) return pending.future;
                            return harness.importText;
                          },
                          exportText: (text) async =>
                              harness.exported.add(text),
                        ),
                      );
                },
                child: const Text('Open profiles'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open profiles'));
  await tester.pumpAndSettle();
}

Future<void> _import(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(
      OutlinedButton,
      currentAppLocalizations.processProxyProfilesImport,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text(currentAppLocalizations.confirm));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile naming holds controls without fake work progress', (
    tester,
  ) async {
    final harness = _Harness();
    await _pump(tester, harness);
    final save = find.byKey(const ValueKey('process-proxy-save-profile'));
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(harness.repository.writes, 0);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
  });

  testWidgets(
    'profile storage still shows progress during real asynchronous work',
    (tester) async {
      final harness = _Harness();
      final pending = Completer<void>();
      harness.repository.pendingSave = pending;
      await _pump(tester, harness);
      await tester.tap(
        find.byKey(const ValueKey('process-proxy-save-profile')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.enterText(find.byType(TextFormField), 'Saved');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(harness.repository.writes, 0);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(harness.repository.writes, 1);
    },
  );

  testWidgets('empty state does not write and export arguments default off', (
    tester,
  ) async {
    final harness = _Harness();
    await _pump(tester, harness);
    expect(
      find.text(currentAppLocalizations.processProxyProfilesEmpty),
      findsOneWidget,
    );
    expect(
      tester.widget<CommonSwitch>(find.byType(CommonSwitch)).value,
      isFalse,
    );
    expect(harness.repository.writes, 0);
    expect(harness.exported, isEmpty);
  });

  testWidgets('canceling import preview leaves current profiles untouched', (
    tester,
  ) async {
    final harness = _Harness();
    harness.repository.profiles = [_profile('Original')];
    harness.importText = encodeProcessProxyProfiles([_profile('Imported')]);
    await _pump(tester, harness);
    await _import(tester);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('Imported'), findsOneWidget);
    expect(harness.repository.writes, 0);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(harness.repository.profiles.single.name, 'Original');
    expect(harness.repository.writes, 0);
  });

  testWidgets('confirmed import merges without applying or launching', (
    tester,
  ) async {
    final harness = _Harness();
    harness.repository.profiles = [_profile('Original')];
    harness.importText = encodeProcessProxyProfiles([_profile('Imported')]);
    await _pump(tester, harness);
    await _import(tester);
    await _confirm(tester);
    expect(harness.repository.profiles.map((profile) => profile.name), [
      'Original',
      'Imported',
    ]);
    expect(harness.repository.writes, 1);
    expect(harness.selected, isNull);
    expect(find.text('Imported'), findsOneWidget);
  });

  testWidgets('invalid import never writes and remains retryable', (
    tester,
  ) async {
    final harness = _Harness()..importText = '{"unexpected":true}';
    harness.repository.profiles = [_profile('Original')];
    await _pump(tester, harness);
    await _import(tester);
    expect(
      find.text(currentAppLocalizations.processProxyProfilesInvalid),
      findsOneWidget,
    );
    expect(harness.repository.writes, 0);
    expect(harness.repository.profiles.single.name, 'Original');
    harness.importText = encodeProcessProxyProfiles([_profile('Imported')]);
    await _import(tester);
    await _confirm(tester);
    expect(harness.repository.writes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conflicting import cannot overwrite a profile', (tester) async {
    final harness = _Harness();
    harness.repository.profiles = [_profile('Original')];
    harness.importText = encodeProcessProxyProfiles([_profile('Original')]);
    await _pump(tester, harness);
    await _import(tester);
    expect(
      find.text(currentAppLocalizations.processProxyProfilesConflict),
      findsOneWidget,
    );
    expect(harness.repository.writes, 0);
  });

  testWidgets('load requires confirmation and returns an untrusted form only', (
    tester,
  ) async {
    final harness = _Harness();
    harness.repository.profiles = [_profile('Original')];
    await _pump(tester, harness);
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(harness.selected, isNull);
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(harness.selected!.executable, _request.executable);
    expect(harness.selected!.workingDirectory, _request.workingDirectory);
    expect(harness.selected!.proxyOnlyRules, _request.proxyOnlyRules);
    expect(harness.selected!.childRules, _request.childRules);
    expect(harness.selected!.childRuleInclude, isTrue);
    expect(harness.selected!.trustedBackend, isFalse);
    expect(harness.selected!.prepareQuic, isFalse);
    expect(harness.selected!.decryptHttps, isFalse);
    expect(harness.repository.writes, 0);
    expect(find.text('Open profiles'), findsOneWidget);
  });

  testWidgets('export needs confirmation and omits arguments unless opted in', (
    tester,
  ) async {
    final harness = _Harness();
    harness.repository.profiles = [_profile('Original')];
    await _pump(tester, harness);
    final export = find.widgetWithText(
      OutlinedButton,
      currentAppLocalizations.processProxyProfilesExport,
    );
    await tester.tap(export);
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(harness.exported, isEmpty);
    await _confirm(tester);
    expect(harness.exported.single, isNot(contains('private-token')));
    await tester.tap(find.byType(CommonSwitch));
    await tester.pumpAndSettle();
    await tester.tap(export);
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(harness.exported.last, contains('private-token'));
    expect(harness.repository.writes, 0);
  });

  testWidgets('failed initial load blocks changes until retry succeeds', (
    tester,
  ) async {
    final harness = _Harness();
    harness.repository.failLoad = true;
    await _pump(tester, harness);
    expect(
      find.text(currentAppLocalizations.processProxyProfilesStorage),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('process-proxy-save-profile')),
          )
          .onPressed,
      isNull,
    );
    harness.repository.failLoad = false;
    await tester.tap(find.text(currentAppLocalizations.retry));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('process-proxy-save-profile')),
          )
          .onPressed,
      isNotNull,
    );
    expect(harness.repository.writes, 0);
  });

  testWidgets('saving the current form clears sensitive consent', (
    tester,
  ) async {
    final harness = _Harness();
    await _pump(tester, harness);
    await tester.tap(find.byKey(const ValueKey('process-proxy-save-profile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Saved');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(harness.repository.writes, 1);
    final request = harness.repository.profiles.single.request;
    expect(request.trustedBackend, isFalse);
    expect(request.prepareQuic, isFalse);
    expect(request.decryptHttps, isFalse);
    expect(request.arguments, _request.arguments);
  });

  testWidgets('finishing file selection after disposal does not update state', (
    tester,
  ) async {
    final pending = Completer<String?>();
    final harness = _Harness()..pendingImport = pending;
    await _pump(tester, harness);
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyProfilesImport,
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(encodeProcessProxyProfiles([_profile('Imported')]));
    await tester.pump();
    expect(harness.repository.writes, 0);
    expect(tester.takeException(), isNull);
  });
}
