import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/record_detail.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/process_proxy/payload.dart';
import 'package:fl_clash/views/process_proxy/record_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../services/process_proxy_record_detail_cases.dart';

const _session = ProcessProxySession(
  id: 'test',
  executable: r'C:\Apps\Example.exe',
  backendPid: 1,
  backendExecutable: r'C:\Bridge.exe',
  status: 'backendRunning',
  nativeBridge: true,
);

class _Service extends ProcessProxyService {
  final requests = <String>[];
  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    requests.add(operation);
    throw StateError('Detail view must not query a backend');
  }
}

ProcessProxyRecordInput _input(
  Map<String, dynamic> record, {
  String run = 'run-1',
}) => ProcessProxyRecordInput(record: record, runId: run, cacheId: 7);
Future<({ValueNotifier<ProcessProxyRecordInput> input, _Service service})>
_pump(
  WidgetTester tester,
  Map<String, dynamic> record, {
  Future<ProcessProxyRecordDetail> Function(ProcessProxyRecordInput)? parse,
  bool settle = true,
}) async {
  const size = Size(1200, 2200);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  final service = _Service();
  addTearDown(service.dispose);
  final input = ValueNotifier(_input(record));
  addTearDown(input.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: ValueListenableBuilder(
          valueListenable: input,
          builder: (context, value, _) => ProcessProxyRecordDetailView(
            service: service,
            session: _session,
            input: value,
            parse: parse ?? (i) async => parseProcessProxyRecordDetail(i),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return (input: input, service: service);
}

void main() {
  testWidgets(
    'semantic page only parses a snapshot and preserves duplicate headers',
    (tester) async {
      final result = await _pump(tester, detailFixture());
      expect(result.service.requests, isEmpty);
      expect(
        find.textContaining('x-repeat: one\nx-repeat: two'),
        findsOneWidget,
      );
      expect(find.text('checksum: abc'), findsOneWidget);
      expect(find.text('103'), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(result.service.requests, isEmpty);
    },
  );
  testWidgets('encrypted QUIC never claims plaintext or starts decryption', (
    tester,
  ) async {
    final result = await _pump(tester, datagramFixture(protocol: 'quic'));
    expect(
      find.text(currentAppLocalizations.processProxyEncryptedPayload),
      findsOneWidget,
    );
    expect(result.service.requests, isEmpty);
  });
  testWidgets('zero-byte packet stays metadata only', (tester) async {
    final result = await _pump(tester, datagramFixture());
    await tester.tap(
      find.text(currentAppLocalizations.processProxyPacketMetadata(2, 3, 0)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProcessProxyPayloadView), findsNothing);
    expect(result.service.requests, isEmpty);
  });
  testWidgets(
    'packet navigation binds range direction and identity without reading',
    (tester) async {
      final result = await _pump(tester, datagramFixture());
      await tester.tap(
        find.text(currentAppLocalizations.processProxyPacketMetadata(1, 0, 5)),
      );
      await tester.pumpAndSettle();
      final payload = tester.widget<ProcessProxyPayloadView>(
        find.byType(ProcessProxyPayloadView),
      );
      expect(payload.runId, 'run-1');
      expect(payload.cacheId, 7);
      expect(payload.initialOffset, 0);
      expect(payload.readLength, 5);
      expect(payload.initialClient, isFalse);
      expect(payload.boundedRange, isTrue);
      expect(result.service.requests, isEmpty);
      globalState.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.byType(ProcessProxyPayloadView), findsNothing);
      expect(result.service.requests, isEmpty);
    },
  );
  testWidgets('returning from packet preview does not refresh or capture', (
    tester,
  ) async {
    final result = await _pump(tester, datagramFixture());
    final row = find.text(
      currentAppLocalizations.processProxyPacketMetadata(1, 0, 3),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(row);
      await tester.pumpAndSettle();
      globalState.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
    }
    expect(result.service.requests, isEmpty);
  });
  testWidgets('late local parse cannot replace newer selected record', (
    tester,
  ) async {
    final first = Completer<ProcessProxyRecordDetail>();
    final result = await _pump(
      tester,
      detailFixture(),
      parse: (input) => input.runId == 'run-1'
          ? first.future
          : Future.value(parseProcessProxyRecordDetail(input)),
      settle: false,
    );
    result.input.value = _input(
      datagramFixture(protocol: 'quic'),
      run: 'run-2',
    );
    await tester.pumpAndSettle();
    first.complete(parseProcessProxyRecordDetail(_input(detailFixture())));
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.processProxyEncryptedPayload),
      findsOneWidget,
    );
    expect(find.textContaining('x-repeat: one'), findsNothing);
    expect(result.service.requests, isEmpty);
  });
  testWidgets('unmount during compute cannot update removed state', (
    tester,
  ) async {
    final pending = Completer<ProcessProxyRecordDetail>();
    await _pump(
      tester,
      detailFixture(),
      parse: (_) => pending.future,
      settle: false,
    );
    await tester.pumpWidget(const SizedBox());
    pending.complete(parseProcessProxyRecordDetail(_input(detailFixture())));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('malformed snapshot exposes no unsafe detail or read action', (
    tester,
  ) async {
    final record = detailFixture()..['cache_id'] = 999;
    final result = await _pump(tester, record);
    expect(
      find.text(currentAppLocalizations.processProxyErrorBridge),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.processProxyPayloadViewer),
      findsNothing,
    );
    expect(result.service.requests, isEmpty);
  });
}
