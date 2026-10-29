import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/recording_browser.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/process_proxy/recording_browser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../services/process_proxy_recording_cases.dart';

ProcessProxySession _session(String id) => ProcessProxySession(
  id: id,
  executable: r'C:\Apps\Example.exe',
  backendPid: 1,
  backendExecutable: r'C:\Bridge.exe',
  status: 'backendRunning',
  nativeBridge: true,
);

class _Service extends ProcessProxyService {
  final calls = <({String session, Map<String, dynamic> query})>[];
  String runId = 'recording:100';
  bool stalled = false;
  bool connectionOnly = false;
  bool fail = false;
  Completer<Map<String, dynamic>>? pending;

  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    expect(operation, 'query');
    calls.add((session: sessionId, query: arguments));
    if (pending case final wait?) {
      pending = null;
      return wait.future;
    }
    if (fail)
      throw const ProcessProxyException(
        'bridgeOperationFailed',
        'SECRET_DIAGNOSTIC',
      );
    if (arguments['type'] == 'recording_detail') {
      return recordingFixtureRow(
        cacheId: arguments['cache_id'] as int? ?? 7,
        type: connectionOnly ? 'connection' : 'exchange',
      );
    }
    expect(arguments['type'], 'recording_page');
    final offset = arguments['offset'] as int;
    return recordingFixturePage(
      offset: offset,
      runId: sessionId == 'second' ? 'recording:200' : runId,
      records: stalled
          ? []
          : [
              recordingFixtureRow(
                cacheId: offset + 7,
                type: connectionOnly ? 'connection' : 'exchange',
              ),
            ],
    );
  }
}

Future<ValueNotifier<ProcessProxySession>> _pump(
  WidgetTester tester,
  _Service service,
) async {
  const size = Size(1200, 2200);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  addTearDown(service.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  final session = ValueNotifier(_session('first'));
  addTearDown(session.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: ValueListenableBuilder(
          valueListenable: session,
          builder: (context, value, _) => ProcessProxyRecordingBrowser(
            service: service,
            session: value,
            parsePage: (response) async =>
                parseProcessProxyRecordingPage(response),
            formatDetail: (input) async =>
                formatProcessProxyRecordingDetail(input),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return session;
}

Finder _button(String text) => find.widgetWithText(OutlinedButton, text);

void main() {
  testWidgets('mount reads one offline page and shows actual warning count', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    expect(service.calls.single.query, {
      'type': 'recording_page',
      'offset': 0,
      'limit': 16,
      'filter': '',
      'protocol': 0,
    });
    expect(
      find.text(currentAppLocalizations.processProxyRecordingWarnings(1)),
      findsOneWidget,
    );
    await tester.pump(const Duration(minutes: 1));
    expect(service.calls.length, 1);
  });

  testWidgets(
    'short pages use record offsets and exact previous-page history',
    (tester) async {
      final service = _Service();
      await _pump(tester, service);
      final l = currentAppLocalizations;
      await tester.tap(_button(l.processProxyRecordingNext));
      await tester.pumpAndSettle();
      expect(service.calls.last.query['offset'], 1);
      await tester.tap(_button(l.processProxyRecordingNext));
      await tester.pumpAndSettle();
      expect(service.calls.last.query['offset'], 2);
      expect(
        tester
            .widget<OutlinedButton>(_button(l.processProxyRecordingNext))
            .onPressed,
        isNull,
      );
      await tester.tap(_button(l.processProxyRecordingPrevious));
      await tester.pumpAndSettle();
      expect(service.calls.last.query['offset'], 1);
      await tester.tap(_button(l.processProxyRecordingPrevious));
      await tester.pumpAndSettle();
      expect(service.calls.last.query['offset'], 0);
    },
  );

  testWidgets('empty page before reported total stops without polling', (
    tester,
  ) async {
    final service = _Service()..stalled = true;
    await _pump(tester, service);
    final l = currentAppLocalizations;
    expect(find.text(l.processProxyRecordingStalled), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(_button(l.processProxyRecordingNext))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(minutes: 1));
    expect(service.calls.length, 1);
  });

  testWidgets('changing filter clears old rows and waits for manual refresh', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    await tester.enterText(find.byType(TextFormField), 'worker');
    await tester.pump();
    expect(find.text('h2 · GET · /work'), findsNothing);
    expect(service.calls.length, 1);
    await tester.tap(_button(currentAppLocalizations.processProxyRefresh));
    await tester.pumpAndSettle();
    expect(service.calls.last.query['filter'], 'worker');
    expect(service.calls.last.query['offset'], 0);
  });

  testWidgets(
    'detail request binds cache ID and recording identity before payload navigation',
    (tester) async {
      final service = _Service();
      await _pump(tester, service);
      await tester.tap(find.text('h2 · GET · /work'));
      await tester.pumpAndSettle();
      expect(service.calls.last.query, {
        'type': 'recording_detail',
        'run_id': 'recording:100',
        'cache_id': 7,
        'preview_bytes': 16384,
      });
      expect(
        find.text(currentAppLocalizations.processProxyPayloadViewer),
        findsOneWidget,
      );
    },
  );

  testWidgets('connection-only detail has no invented payload action', (
    tester,
  ) async {
    final service = _Service()..connectionOnly = true;
    await _pump(tester, service);
    await tester.tap(find.text('h2 · GET · /work'));
    await tester.pumpAndSettle();
    expect(service.calls.last.query['connection_id'], 'conn-1');
    expect(service.calls.last.query.containsKey('cache_id'), isFalse);
    expect(
      find.text(currentAppLocalizations.processProxyRecordingNoPayload),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.processProxyPayloadViewer),
      findsNothing,
    );
  });

  testWidgets('replacing a recording while paging clears stale rows', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    service.runId = 'recording:replaced';
    await tester.tap(
      _button(currentAppLocalizations.processProxyRecordingNext),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.processProxyRecordingChanged),
      findsOneWidget,
    );
    expect(find.text('h2 · GET · /work'), findsNothing);
    await tester.tap(_button(currentAppLocalizations.processProxyRefresh));
    await tester.pumpAndSettle();
    expect(service.calls.last.query['offset'], 0);
    expect(find.text('h2 · GET · /work'), findsOneWidget);
  });

  testWidgets('back to page zero rejects a newly opened recording', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    await tester.tap(
      _button(currentAppLocalizations.processProxyRecordingNext),
    );
    await tester.pumpAndSettle();
    service.runId = 'recording:replaced';
    await tester.tap(
      _button(currentAppLocalizations.processProxyRecordingPrevious),
    );
    await tester.pumpAndSettle();
    expect(service.calls.last.query['offset'], 0);
    expect(
      find.text(currentAppLocalizations.processProxyRecordingChanged),
      findsOneWidget,
    );
    expect(find.text('h2 · GET · /work'), findsNothing);
  });

  testWidgets('repeated refresh is ignored while a read is pending', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    final pending = Completer<Map<String, dynamic>>();
    service.pending = pending;
    final refresh = _button(currentAppLocalizations.processProxyRefresh);
    await tester.tap(refresh);
    await tester.tap(refresh);
    await tester.pump();
    expect(service.calls.length, 2);
    expect(tester.widget<OutlinedButton>(refresh).onPressed, isNull);
    pending.complete(recordingFixturePage());
    await tester.pumpAndSettle();
    expect(tester.widget<OutlinedButton>(refresh).onPressed, isNotNull);
  });

  testWidgets(
    'late detail from an old session cannot bind to the new recording',
    (tester) async {
      final service = _Service();
      final session = await _pump(tester, service);
      final pending = Completer<Map<String, dynamic>>();
      service.pending = pending;
      await tester.tap(find.text('h2 · GET · /work'));
      await tester.pump();
      session.value = _session('second');
      await tester.pumpAndSettle();
      pending.complete(recordingFixtureRow()..['marker'] = 'STALE_DETAIL');
      await tester.pumpAndSettle();
      expect(service.calls.last.session, 'second');
      expect(find.textContaining('recording:200'), findsOneWidget);
      expect(find.textContaining('STALE_DETAIL'), findsNothing);
      expect(
        find.text(currentAppLocalizations.processProxyPayloadViewer),
        findsNothing,
      );
    },
  );

  testWidgets('disposal during a page request cannot update the removed view', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    final pending = Completer<Map<String, dynamic>>();
    service.pending = pending;
    await tester.tap(
      _button(currentAppLocalizations.processProxyRecordingNext),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(recordingFixturePage(offset: 1));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('backend failure is redacted and manual refresh remains usable', (
    tester,
  ) async {
    final service = _Service();
    await _pump(tester, service);
    service.fail = true;
    await tester.tap(_button(currentAppLocalizations.processProxyRefresh));
    await tester.pumpAndSettle();
    expect(find.textContaining('SECRET_DIAGNOSTIC'), findsNothing);
    expect(
      find.text(currentAppLocalizations.processProxyErrorBridge),
      findsOneWidget,
    );
    service.fail = false;
    await tester.tap(_button(currentAppLocalizations.processProxyRefresh));
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.processProxyErrorBridge),
      findsNothing,
    );
  });
}
