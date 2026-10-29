import 'dart:convert';
import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/traffic.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/process_proxy/payload.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _session = ProcessProxySession(
  id: 'test',
  executable: r'C:\Apps\test.exe',
  backendPid: 1,
  backendExecutable: r'C:\Bridge.exe',
  status: 'backendRunning',
  nativeBridge: true,
);

class _Service extends ProcessProxyService {
  final requests = <Map<String, dynamic>>[];
  bool fail = false;
  String body = 'response body';
  Map<String, dynamic> responsePatch = {};
  Map<String, dynamic> payloadPatch = {};
  Completer<Map<String, dynamic>>? pending;
  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    expect(operation, 'query');
    requests.add(arguments);
    if (pending case final waiting?) return waiting.future;
    if (fail) {
      throw const ProcessProxyException(
        'bridgeOperationFailed',
        'SECRET_DETAIL',
      );
    }
    return {
      'run_id': arguments['run_id'],
      'payload': {
        'data_base64': base64Encode(utf8.encode(body)),
        'direction': arguments['direction'],
        'offset': arguments['offset'] ?? 0,
        'decoded': false,
        'decoded_bytes': 13,
        'cache': {
          'id': arguments['cache_id'],
          'finished': true,
          'pending_chunks': 0,
          'request_bytes': 13,
        },
        ...payloadPatch,
      },
      ...responsePatch,
    };
  }
}

Future<_Service> _pump(WidgetTester tester, {bool bounded = false}) async {
  const size = Size(1200, 1800);
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
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: ProcessProxyPayloadView(
          service: service,
          session: _session,
          runId: 'run-1',
          cacheId: 7,
          initialOffset: bounded ? 50 : 0,
          readLength: bounded ? 5 : 16384,
          initialClient: !bounded,
          boundedRange: bounded,
          format: (r) async => formatProcessProxyPayload(r),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  testWidgets('payload view never starts capture or reads on mount', (
    tester,
  ) async {
    final service = await _pump(tester);
    expect(service.requests, isEmpty);
  });
  testWidgets(
    'explicit Raw read uses same run cache direction and bounded length',
    (tester) async {
      final service = await _pump(tester);
      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          currentAppLocalizations.processProxyPayloadRead,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.requests.single, {
        'type': 'cache_read',
        'run_id': 'run-1',
        'cache_id': 7,
        'direction': 'client',
        'offset': 0,
        'length': 16384,
      });
      expect(find.text('response body'), findsOneWidget);
    },
  );
  testWidgets(
    'DNS requests full bounded datagram while display remains bounded',
    (tester) async {
      final service = await _pump(tester);
      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          currentAppLocalizations.processProxyPayloadDns,
        ),
      );
      await tester.pumpAndSettle();
      expect(service.requests.single['length'], 65535);
    },
  );
  testWidgets('invalid cache input never sends a request', (tester) async {
    final service = await _pump(tester);
    await tester.enterText(find.byType(TextFormField).at(1), '-7');
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    expect(service.requests, isEmpty);
  });
  testWidgets('leaving during a read never updates disposed widgets', (
    tester,
  ) async {
    final service = await _pump(tester);
    service.pending = Completer<Map<String, dynamic>>();
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    service.pending!.complete({
      'payload': {'data_base64': '', 'offset': 0},
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('payload failure clears old preview and hides raw error detail', (
    tester,
  ) async {
    final service = await _pump(tester);
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    service.fail = true;
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('response body'), findsNothing);
    expect(find.textContaining('SECRET_DETAIL'), findsNothing);
  });

  testWidgets('datagram prefix locks its direction byte range and actions', (
    tester,
  ) async {
    final service = await _pump(tester, bounded: true);
    service.body = 'abc';
    expect(service.requests, isEmpty);
    for (final field in tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    )) {
      expect(field.enabled, isFalse);
    }
    expect(
      find.text(currentAppLocalizations.processProxyPayloadDecode),
      findsNothing,
    );
    expect(
      find.text(currentAppLocalizations.processProxyPayloadDns),
      findsNothing,
    );
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    expect(service.requests.single, {
      'type': 'cache_read',
      'run_id': 'run-1',
      'cache_id': 7,
      'direction': 'server',
      'offset': 50,
      'length': 5,
    });
    expect(find.text('abc'), findsOneWidget);
  });

  testWidgets('payload response from a different run is never displayed', (
    tester,
  ) async {
    final service = await _pump(tester);
    service.responsePatch = {'run_id': 'other-run'};
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('response body'), findsNothing);
    expect(
      find.text(currentAppLocalizations.processProxyErrorBridge),
      findsOneWidget,
    );
  });

  testWidgets(
    'payload response with a different byte offset is never displayed',
    (tester) async {
      final service = await _pump(tester);
      service.payloadPatch = {'offset': 100};
      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          currentAppLocalizations.processProxyPayloadRead,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('response body'), findsNothing);
    },
  );

  testWidgets('a datagram reply cannot expand the selected prefix', (
    tester,
  ) async {
    await _pump(tester, bounded: true);
    await tester.tap(
      find.widgetWithText(
        OutlinedButton,
        currentAppLocalizations.processProxyPayloadRead,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('response body'), findsNothing);
    expect(
      find.text(currentAppLocalizations.processProxyErrorBridge),
      findsOneWidget,
    );
  });

  testWidgets('repeated packet reads are ignored until the first finishes', (
    tester,
  ) async {
    final service = await _pump(tester, bounded: true);
    service.pending = Completer<Map<String, dynamic>>();
    final read = find.widgetWithText(
      OutlinedButton,
      currentAppLocalizations.processProxyPayloadRead,
    );
    await tester.tap(read);
    await tester.tap(read);
    await tester.pump();
    expect(service.requests.length, 1);
    service.pending!.complete({
      'run_id': 'run-1',
      'payload': {
        'direction': 'server',
        'offset': 50,
        'data_base64': 'YWJj',
        'cache': {'id': 7, 'finished': true},
      },
    });
    await tester.pumpAndSettle();
    expect(find.text('abc'), findsOneWidget);
  });
}
