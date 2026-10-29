import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/switch.dart';
import 'package:fl_clash/views/process_proxy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _settings = ProcessProxyLaunchRequest(
  backendPath: r'C:\ProxyLane\ProxyLane64.exe',
  executable: r'C:\Apps\Example.exe',
  arguments: ['--profile', 'Work'],
  workingDirectory: r'C:\Work',
  proxyOnlyRules: '*.example.com',
  childRules: 'launcher.exe',
  childRuleInclude: true,
  trustedBackend: true,
  prepareQuic: true,
  decryptHttps: true,
);

class _VerifiedSetupAction extends SetupAction {
  bool applied = true;

  @override
  void build() {}

  @override
  Future<bool> inputsApplied() async => applied;
}

class _FakeService extends ProcessProxyService {
  int launches = 0;
  Future<ProcessProxyRuntime> Function()? lastRuntime;
  ProcessProxyLaunchRequest? saved;
  bool failSearch = false;
  Completer<List<ProcessProxyCandidate>>? pendingSearch;

  @override
  Future<ProcessProxyLaunchRequest?> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(ProcessProxyLaunchRequest request) async {
    saved = request;
  }

  @override
  Future<List<ProcessProxyCandidate>> searchProcesses(String query) async {
    if (failSearch) throw const ProcessProxyException('windowsQueryFailed');
    if (pendingSearch case final pending?) return pending.future;
    return const [
      ProcessProxyCandidate(
        pid: 42,
        name: 'Browser.exe',
        executable: r'C:\Apps\Browser.exe',
      ),
    ];
  }

  @override
  Future<List<ProcessProxyApplication>> searchApplications(
    String query,
  ) async => const [
    ProcessProxyApplication(
      name: 'Shortcut App',
      executable: r'C:\Apps\Shortcut.exe',
      arguments: ['--work', 'Profile A'],
      workingDirectory: r'C:\Work',
      source: 'start-menu',
    ),
  ];

  @override
  Future<void> launch({
    required ProcessProxyLaunchRequest request,
    required Future<ProcessProxyRuntime> Function() runtime,
  }) async {
    lastRuntime = runtime;
    final endpoint = (await runtime()).endpoint;
    if (endpoint.port > 0) launches++;
  }
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _FakeService service, {
  bool running = true,
  bool safeMode = false,
  bool systemProxy = false,
  bool applied = true,
  bool suspended = false,
  bool direct = false,
}) async {
  const size = Size(1200, 4200);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      safeModeProvider.overrideWithValue(safeMode),
      suspendProvider.overrideWithValue(suspended),
      setupActionProvider.overrideWith(_VerifiedSetupAction.new),
      coreStatusProvider.overrideWithBuild(
        (_, _) => running ? CoreStatus.connected : CoreStatus.disconnected,
      ),
      runTimeProvider.overrideWithBuild((_, _) => running ? 1 : null),
      networkSettingProvider.overrideWithBuild(
        (_, _) => NetworkProps(systemProxy: systemProxy),
      ),
      patchClashConfigProvider.overrideWithBuild(
        (_, _) => PatchClashConfig(
          mixedPort: 17891,
          mode: direct ? Mode.direct : Mode.rule,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  (container.read(
    setupActionProvider.notifier,
  ) as _VerifiedSetupAction).applied = applied;
  container.read(viewSizeProvider.notifier).value = size;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: ProcessProxyView(serviceFactory: () => service, isWindows: true),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _trustBackend(WidgetTester tester) async {
  await tester.tap(find.byType(CommonSwitch).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('restores fields but never restores sensitive consent', (
    tester,
  ) async {
    final service = _FakeService();
    await _pump(tester, service);
    final target = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );
    expect(target.controller!.text, _settings.executable);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(3))
          .controller!
          .text,
      _settings.workingDirectory,
    );
    expect(
      tester.widget<CommonSwitch>(find.byType(CommonSwitch).first).value,
      isFalse,
    );
    expect(
      tester.widget<CommonSwitch>(find.byType(CommonSwitch).last).value,
      isFalse,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.textContaining('SOCKS5 · 127.0.0.1:17891'), findsOneWidget);
    expect(service.launches, 0);
  });

  testWidgets(
    'destination and child filters restore and save without launching',
    (tester) async {
      final service = _FakeService();
      await _pump(tester, service);
      final fields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        fields.any(
          (field) => field.controller?.text == _settings.proxyOnlyRules,
        ),
        isTrue,
      );
      expect(
        fields.any((field) => field.controller?.text == _settings.childRules),
        isTrue,
      );
      expect(
        tester.widget<CommonSwitch>(find.byType(CommonSwitch).at(2)).value,
        isTrue,
      );
      await tester.tap(
        find.widgetWithText(TextButton, currentAppLocalizations.save),
      );
      await tester.pumpAndSettle();
      expect(service.saved!.proxyOnlyRules, _settings.proxyOnlyRules);
      expect(service.saved!.childRules, _settings.childRules);
      expect(service.saved!.childRuleInclude, isTrue);
      expect(service.saved!.trustedBackend, isFalse);
      expect(service.launches, 0);
    },
  );

  for (final scenario in ['stopped', 'safe', 'global', 'suspended', 'direct']) {
    testWidgets('$scenario state prevents a launch after trust', (
      tester,
    ) async {
      final service = _FakeService();
      await _pump(
        tester,
        service,
        running: scenario != 'stopped',
        safeMode: scenario == 'safe',
        systemProxy: scenario == 'global',
        suspended: scenario == 'suspended',
        direct: scenario == 'direct',
      );
      await _trustBackend(tester);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(service.launches, 0);
    });
  }

  testWidgets('process search selects a new-launch path without attaching', (
    tester,
  ) async {
    final service = _FakeService();
    await _pump(tester, service);
    await tester.tap(
      find.byTooltip(currentAppLocalizations.processProxySearch),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browser.exe · PID 42'));
    await tester.pump();
    final target = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );
    expect(target.controller!.text, r'C:\Apps\Browser.exe');
    expect(service.launches, 0);
  });

  testWidgets(
    'installed app selection preserves arguments and cwd without launch',
    (tester) async {
      final service = _FakeService();
      await _pump(tester, service);
      await tester.tap(
        find.text(currentAppLocalizations.processProxyApplications),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shortcut App'));
      await tester.pumpAndSettle();
      final fields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      );
      expect(
        fields.any(
          (field) => field.controller?.text == r'C:\Apps\Shortcut.exe',
        ),
        isTrue,
      );
      expect(
        fields.any((field) => field.controller?.text == r'C:\Work'),
        isTrue,
      );
      expect(
        fields.any(
          (field) => field.controller?.text == '["--work","Profile A"]',
        ),
        isTrue,
      );
      expect(service.launches, 0);
    },
  );

  testWidgets('malformed argument JSON is rejected before saving', (
    tester,
  ) async {
    final service = _FakeService();
    await _pump(tester, service);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '{"not":"an array"}',
    );
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();
    expect(service.saved, isNull);
    expect(
      find.textContaining(currentAppLocalizations.processProxyInvalidArguments),
      findsOneWidget,
    );
  });

  testWidgets('canceling launch does not start a backend', (tester) async {
    final service = _FakeService();
    await _pump(tester, service);
    await _trustBackend(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(service.launches, 0);
    expect(
      find.text(
        currentAppLocalizations.processProxyConfirmLaunch(_settings.executable),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'QUIC preparation needs separate consent and resets for a new target',
    (tester) async {
      final service = _FakeService();
      await _pump(tester, service);
      final l = currentAppLocalizations;
      await tester.tap(find.byType(CommonSwitch).last);
      await tester.pumpAndSettle();
      expect(service.launches, 0);
      expect(
        tester.widget<CommonSwitch>(find.byType(CommonSwitch).last).value,
        isFalse,
      );
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CommonSwitch>(find.byType(CommonSwitch).last).value,
        isFalse,
      );
      await tester.tap(find.byType(CommonSwitch).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.confirm));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CommonSwitch>(find.byType(CommonSwitch).last).value,
        isTrue,
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        r'C:\Apps\Different.exe',
      );
      await tester.pump();
      expect(
        tester.widget<CommonSwitch>(find.byType(CommonSwitch).last).value,
        isFalse,
      );
      expect(service.launches, 0);
    },
  );

  testWidgets(
    'confirmed launch verifies applied inputs and survives navigation',
    (tester) async {
      final service = _FakeService();
      await _pump(tester, service);
      await _trustBackend(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          TextButton,
          currentAppLocalizations.processProxyLaunch,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.launches, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      final snapshot = await service.lastRuntime!();
      expect(snapshot.running, isTrue);
      expect(snapshot.mixedPort, 17891);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unapplied core inputs reject the confirmed launch', (
    tester,
  ) async {
    final service = _FakeService();
    await _pump(tester, service, applied: false);
    await _trustBackend(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(
        TextButton,
        currentAppLocalizations.processProxyLaunch,
      ),
    );
    await tester.pumpAndSettle();
    expect(service.launches, 0);
    expect(
      find.textContaining(currentAppLocalizations.processProxyErrorCoreChanged),
      findsOneWidget,
    );
  });

  testWidgets('a search failure clears progress and stays retryable', (
    tester,
  ) async {
    final service = _FakeService()..failSearch = true;
    await _pump(tester, service);
    await tester.tap(
      find.byTooltip(currentAppLocalizations.processProxySearch),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      find.textContaining(
        currentAppLocalizations.processProxyErrorProcessQuery,
      ),
      findsOneWidget,
    );
    service.failSearch = false;
    await tester.tap(
      find.byTooltip(currentAppLocalizations.processProxySearch),
    );
    await tester.pumpAndSettle();
    expect(find.text('Browser.exe · PID 42'), findsOneWidget);
  });

  testWidgets('finishing a search after disposal never updates the page', (
    tester,
  ) async {
    final pending = Completer<List<ProcessProxyCandidate>>();
    final service = _FakeService()..pendingSearch = pending;
    await _pump(tester, service);
    await tester.tap(
      find.byTooltip(currentAppLocalizations.processProxySearch),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete([]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
