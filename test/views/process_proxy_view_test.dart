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
  trustedBackend: true,
  decryptHttps: true,
);

class _FakeService extends ProcessProxyService {
  int launches = 0;
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
    if (failSearch) throw const ProcessProxyException('searchFailed');
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
  Future<void> launch({
    required ProcessProxyLaunchRequest request,
    required Future<ProcessProxyRuntime> Function() runtime,
  }) async {
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
}) async {
  const size = Size(1200, 3200);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      safeModeProvider.overrideWithValue(safeMode),
      coreStatusProvider.overrideWithBuild(
        (_, _) => running ? CoreStatus.connected : CoreStatus.disconnected,
      ),
      runTimeProvider.overrideWithBuild((_, _) => running ? 1 : null),
      networkSettingProvider.overrideWithBuild(
        (_, _) => NetworkProps(systemProxy: systemProxy),
      ),
      patchClashConfigProvider.overrideWithBuild(
        (_, _) => const PatchClashConfig(mixedPort: 17891),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
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
      tester.widget<CommonSwitch>(find.byType(CommonSwitch).first).value,
      isFalse,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.textContaining('SOCKS5 · 127.0.0.1:17891'), findsOneWidget);
    expect(service.launches, 0);
  });

  for (final scenario in ['stopped', 'safe', 'global']) {
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
    expect(find.textContaining('searchFailed'), findsOneWidget);
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
