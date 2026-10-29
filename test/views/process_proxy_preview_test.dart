import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

class _PreviewSetup extends SetupAction {
  @override
  void build() {}
  @override
  Future<bool> inputsApplied() async => true;
}

class _PreviewService extends ProcessProxyService {
  int mutations = 0;
  @override
  Future<ProcessProxyLaunchRequest?> loadSettings() async =>
      const ProcessProxyLaunchRequest(
        backendPath: r'C:\ProxyLane\ProxyLane64.exe',
        executable: r'C:\Apps\Example.exe',
        arguments: ['--profile', 'Example'],
        bypassRules: '*.corp.example\n10.0.0.0/8',
      );
  @override
  Future<void> saveSettings(ProcessProxyLaunchRequest request) async {
    mutations++;
    throw StateError('Mock preview does not save settings');
  }

  @override
  Future<void> launch({
    required ProcessProxyLaunchRequest request,
    required Future<ProcessProxyRuntime> Function() runtime,
    required ProcessProxyRuntimeObserver observeRuntime,
  }) async {
    mutations++;
    throw StateError('Mock preview does not launch processes');
  }

  @override
  Future<Map<String, dynamic>> bridgeRequest(
    String sessionId,
    String operation, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    mutations++;
    throw StateError('Mock preview does not use a backend');
  }
}

void main() {
  final output = Platform.environment['PROCESS_PROXY_PREVIEW_DIR'];
  setUpAll(() async {
    if (output == null) return;
    final fontPath =
        Platform.environment['PROCESS_PROXY_PREVIEW_FONT'] ??
        '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc';
    final font = File(fontPath);
    if (!await font.exists()) {
      throw StateError(
        'Set PROCESS_PROXY_PREVIEW_FONT to a local Chinese font; no font is downloaded.',
      );
    }
    final loader = FontLoader('MockPreviewChinese');
    loader.addFont(font.readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });
  for (final size in [const Size(1200, 900), const Size(460, 1000)]) {
    for (final brightness in Brightness.values) {
      final name =
          'mock-process-proxy-${size.width.toInt()}-${brightness.name}';
      testWidgets(name, (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer(
          overrides: [
            safeModeProvider.overrideWithValue(false),
            suspendProvider.overrideWithValue(false),
            setupActionProvider.overrideWith(_PreviewSetup.new),
            coreStatusProvider.overrideWithBuild(
              (_, _) => CoreStatus.connected,
            ),
            runTimeProvider.overrideWithBuild((_, _) => 1),
            networkSettingProvider.overrideWithBuild(
              (_, _) => const NetworkProps(systemProxy: false),
            ),
            patchClashConfigProvider.overrideWithBuild(
              (_, _) => const PatchClashConfig(mixedPort: 17891),
            ),
          ],
        );
        addTearDown(container.dispose);
        globalState.container = container;
        container.read(viewSizeProvider.notifier).value = size;
        final service = _PreviewService();
        final key = GlobalKey();
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff6750a4),
            brightness: brightness,
          ),
          fontFamily: output == null ? null : 'MockPreviewChinese',
        ).withAppShapes.withAppSurfaces.withAppTypography;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              locale: const Locale('zh', 'CN'),
              theme: theme,
              darkTheme: theme,
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              child: RepaintBoundary(
                key: key,
                child: Material(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('模拟界面 · 无真实流量 / MOCK UI · NO LIVE TRAFFIC'),
                      ),
                      Expanded(
                        child: ProcessProxyView(
                          serviceFactory: () => service,
                          isWindows: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(service.mutations, 0);
        expect(find.text('进程代理'), findsOneWidget);
        if (output != null) {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final picture = await boundary.toImage(pixelRatio: 1);
            try {
              final data = await picture.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final directory = await Directory(output).create(recursive: true);
              await File(
                '${directory.path}/$name.png',
              ).writeAsBytes(data!.buffer.asUint8List());
            } finally {
              picture.dispose();
            }
          });
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
