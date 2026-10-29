import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/switch.dart';
import 'package:fl_clash/views/process_proxy/advanced.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _session = ProcessProxySession(
  id: 'test-session',
  executable: r'C:\Apps\Example.exe',
  backendPid: 100,
  backendExecutable: r'C:\Tools\FlClashProxyBridge.exe',
  targetPid: 101,
  nativeBridge: true,
  status: 'backendRunning',
);

class _BridgeService extends ProcessProxyService {
  final calls = <({String operation, Map<String, dynamic> arguments})>[];
  bool fail = false;
  String runId = 'run-1';
  bool rows = false;

  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    calls.add((operation: operation, arguments: arguments));
    if (fail) {
      throw const ProcessProxyException(
        'bridgeOperationFailed',
        'private-detail',
      );
    }
    return {
      'source': 'test-backend-response',
      'operation': operation,
      'next': 7,
      'run_id': runId,
      'preparation_id': '7',
      'count': 2,
      if (rows && arguments['type'] == 'poll')
        'records': [
          {
            'type': 'stream',
            'protocol': 'tcp',
            'connection': {'pid': 42},
            'stream': {
              'cache': {'id': 991},
            },
          },
        ],
    };
  }
}

Future<_BridgeService> _pump(WidgetTester tester) async {
  const size = Size(1200, 1800);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  final service = _BridgeService();
  addTearDown(service.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: ProcessProxyAdvancedView(
          service: service,
          session: _session,
          formatResponse: (response) async =>
              (text: jsonEncode(response), truncated: false),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

Future<void> _tab(WidgetTester tester, String title) async {
  await tester.tap(find.widgetWithText(Tab, title));
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is InputDecorator && widget.decoration.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

void main() {
  testWidgets('mount only reads status and renders the backend response', (
    tester,
  ) async {
    final service = await _pump(tester);
    expect(service.calls.map((call) => call.operation), ['status']);
    expect(find.textContaining('test-backend-response'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.processProxyExperimentalHint),
      findsOneWidget,
    );
  });

  testWidgets(
    'monitor start requires confirmation and defaults decryption off',
    (tester) async {
      final service = await _pump(tester);
      final l = currentAppLocalizations;
      await _tab(tester, l.traffic);
      await tester.tap(
        find.widgetWithText(OutlinedButton, l.processProxyStartMonitor),
      );
      await tester.pumpAndSettle();
      expect(service.calls.length, 1);
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
      expect(service.calls.length, 1);
      await tester.tap(
        find.widgetWithText(OutlinedButton, l.processProxyStartMonitor),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.confirm));
      await tester.pumpAndSettle();
      expect(service.calls.last.operation, 'monitor.start');
      expect(service.calls.last.arguments, {
        'decrypt_https': false,
        'decrypt_quic': false,
        'confirm': true,
      });
    },
  );

  testWidgets('CA trust is explicit and limited to current user', (
    tester,
  ) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.processProxyCertificates);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyTrustCa),
    );
    await tester.pumpAndSettle();
    expect(service.calls.length, 1);
    expect(find.textContaining(l.processProxyCaWarning), findsWidgets);
    await tester.tap(find.text(l.confirm));
    await tester.pumpAndSettle();
    expect(service.calls.last.operation, 'ca.trust');
    expect(service.calls.last.arguments, {
      'scope': 'current-user',
      'confirm': true,
    });
  });

  testWidgets('recording does not inherit monitoring decryption consent', (
    tester,
  ) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.traffic);
    await tester.tap(find.byType(CommonSwitch).first);
    await tester.pumpAndSettle();
    await _tab(tester, l.processProxyRecording);
    await tester.enterText(
      _field('${l.processProxyRecording} · ${l.processProxyDirectory}'),
      r'C:\Private\Recordings',
    );
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyStartRecording),
    );
    await tester.pumpAndSettle();
    expect(service.calls.length, 1);
    await tester.tap(find.text(l.confirm));
    await tester.pumpAndSettle();
    expect(service.calls.last.operation, 'recording.start');
    expect(service.calls.last.arguments['decrypt_https'], false);
    expect(service.calls.last.arguments['decrypt_quic'], false);
    expect(service.calls.last.arguments['directory'], r'C:\Private\Recordings');
  });

  testWidgets('detail input cannot use mutation operations', (tester) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.processProxyRecording);
    await tester.enterText(
      _field(l.processProxyReadQuery),
      '{"type":"ca.trust"}',
    );
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyReadDetails),
    );
    await tester.pumpAndSettle();
    expect(service.calls.length, 1);
    expect(find.text(l.processProxyJsonObjectRequired), findsOneWidget);
  });

  testWidgets('manual polling advances the cursor without a timer', (
    tester,
  ) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.traffic);
    final read = find.widgetWithText(OutlinedButton, l.processProxyReadNext);
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(service.calls.last.arguments['after'], 0);
    await tester.pump(const Duration(minutes: 1));
    expect(service.calls.length, 2);
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(service.calls.last.arguments['after'], 7);
  });

  testWidgets('a changed run identity resets the live cursor', (tester) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.traffic);
    final read = find.widgetWithText(OutlinedButton, l.processProxyReadNext);
    await tester.tap(read);
    await tester.pumpAndSettle();
    service.runId = 'run-2';
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(service.calls.last.arguments['after'], 7);
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(service.calls.last.arguments['after'], 0);
  });

  testWidgets(
    'reconnect snapshot requires separate confirmation and cancel clears it',
    (tester) async {
      final service = await _pump(tester);
      final l = currentAppLocalizations;
      await tester.tap(
        find.widgetWithText(OutlinedButton, l.processProxyReconnect),
      );
      await tester.pumpAndSettle();
      expect(service.calls.last.operation, 'connections.prepare_reconnect');
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
      expect(service.calls.last.operation, 'connections.cancel_reconnect');
      expect(
        service.calls.where((c) => c.operation == 'connections.reconnect'),
        isEmpty,
      );
    },
  );

  testWidgets(
    'reconnect confirms exact snapshot and does not report completion',
    (tester) async {
      final service = await _pump(tester);
      final l = currentAppLocalizations;
      await tester.tap(
        find.widgetWithText(OutlinedButton, l.processProxyReconnect),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.confirm));
      await tester.pumpAndSettle();
      expect(service.calls.last.operation, 'connections.reconnect');
      expect(service.calls.last.arguments, {
        'preparation_id': '7',
        'confirm': true,
      });
    },
  );

  testWidgets('monitor restart removes links for the previous run cache IDs', (
    tester,
  ) async {
    final service = await _pump(tester);
    service.rows = true;
    final l = currentAppLocalizations;
    await _tab(tester, l.traffic);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyReadNext),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('#991'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyStartMonitor),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.confirm));
    await tester.pumpAndSettle();
    expect(find.textContaining('#991'), findsNothing);
  });

  testWidgets('shutdown cancellation never stops the backend', (tester) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.processProxyStopSession),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.cancel));
    await tester.pumpAndSettle();
    expect(service.calls.where((c) => c.operation == 'shutdown'), isEmpty);
  });

  testWidgets('index recovery cancellation never writes the recording', (
    tester,
  ) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    await _tab(tester, l.processProxyRecording);
    final button = find.widgetWithText(
      OutlinedButton,
      l.processProxyRebuildIndex,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.cancel));
    await tester.pumpAndSettle();
    expect(
      service.calls.where((c) => c.operation == 'replay.rebuild_index'),
      isEmpty,
    );
  });

  testWidgets('bridge failures hide diagnostics and allow retry', (
    tester,
  ) async {
    final service = await _pump(tester);
    final l = currentAppLocalizations;
    service.fail = true;
    await tester.tap(find.widgetWithText(OutlinedButton, l.processProxyStatus));
    await tester.pumpAndSettle();
    expect(find.text(l.processProxyErrorBridge), findsOneWidget);
    expect(find.textContaining('private-detail'), findsNothing);
    service.fail = false;
    await tester.tap(find.widgetWithText(OutlinedButton, l.processProxyStatus));
    await tester.pumpAndSettle();
    expect(find.text(l.processProxyErrorBridge), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
