import 'dart:convert';

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
  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    expect(operation, 'query');
    requests.add(arguments);
    if (fail)
      throw const ProcessProxyException(
        'bridgeOperationFailed',
        'SECRET_DETAIL',
      );
    return {
      'run_id': 'run-1',
      'payload': {
        'data_base64': base64Encode(utf8.encode('response body')),
        'direction': 'client',
        'offset': 0,
        'decoded': false,
        'decoded_bytes': 13,
        'cache': {'finished': true, 'pending_chunks': 0, 'request_bytes': 13},
      },
    };
  }
}

Future<_Service> _pump(WidgetTester tester) async {
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
}
