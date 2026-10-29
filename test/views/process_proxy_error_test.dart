import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    l = await AppLocalizations.load(const Locale('en'));
  });

  test('unknown exceptions never expose diagnostic text', () {
    const marker = 'credential-must-not-appear';
    expect(
      processProxyErrorMessage(Exception(marker), l),
      l.processProxyErrorGeneric,
    );
    expect(
      processProxyErrorMessage(
        const ProcessProxyException('unknown', marker),
        l,
      ),
      isNot(contains(marker)),
    );
  });

  test('authentication and launch errors never expose detail', () {
    for (final code in [
      'invalidAuthentication',
      'listenerAuthenticationFailed',
      'launchFailed',
      'backendVersionMismatch',
      'windowsQueryFailed',
    ]) {
      final message = processProxyErrorMessage(
        ProcessProxyException(code, 'do-not-show-secret'),
        l,
      );
      expect(message, isNot(contains('do-not-show-secret')));
      expect(message, isNot(contains(code)));
    }
  });

  test('only rule errors include sanitized bounded input', () {
    final message = processProxyErrorMessage(
      ProcessProxyException('invalidBypassRule', '\x00bad\n${'x' * 200}'),
      l,
    );
    expect(message, contains('bad '));
    expect(message, isNot(contains('\x00')));
    expect(message, isNot(contains('\n')));
    expect(message, isNot(contains('x' * 200)));
  });

  test('core and safe-mode errors give a direct recovery instruction', () {
    expect(
      processProxyErrorMessage(
        const ProcessProxyException('coreNotRunning'),
        l,
      ),
      l.processProxyCoreRequired,
    );
    expect(
      processProxyErrorMessage(const ProcessProxyException('safeMode'), l),
      l.processProxySafeMode,
    );
    expect(
      processProxyErrorMessage(
        const ProcessProxyException('globalProxyEnabled'),
        l,
      ),
      l.processProxyTakeoverOff,
    );
  });

  test('allowlisted bridge codes get useful instructions without raw text', () {
    expect(
      processProxyErrorMessage(
        const ProcessProxyException(
          'bridgeOperationFailed',
          'certificate_required',
        ),
        l,
      ),
      l.processProxyErrorCaRequired,
    );
    expect(
      processProxyErrorMessage(
        const ProcessProxyException(
          'bridgeOperationFailed',
          'target_architecture',
        ),
        l,
      ),
      l.processProxyErrorArchitecture,
    );
    expect(
      processProxyErrorMessage(
        const ProcessProxyException(
          'bridgeOperationFailed',
          'response_too_large',
        ),
        l,
      ),
      l.processProxyErrorResponseLarge,
    );
    expect(
      processProxyErrorMessage(
        const ProcessProxyException('bridgeOperationFailed', 'raw-secret'),
        l,
      ),
      l.processProxyErrorBridge,
    );
  });

  test('hook incompatibility never recommends weakening security', () {
    expect(processProxyExitMessage(7, l), l.processProxyErrorHook);
    expect(processProxyExitMessage(999, l), l.processProxyErrorGeneric);
    expect(processProxyExitMessage(null, l), l.processProxyErrorGeneric);
  });

  test('working directory and QUIC preparation errors have safe guidance', () {
    for (final entry in {
      'invalidWorkingDirectory': l.processProxyErrorWorkingDirectory,
      'nativeBridgeRequired': l.processProxyErrorNativeRequired,
      'quicNeedsSocks': l.processProxyErrorQuicSocks,
    }.entries) {
      expect(
        processProxyErrorMessage(
          ProcessProxyException(entry.key, 'private'),
          l,
        ),
        entry.value,
      );
    }
    expect(
      processProxyErrorMessage(
        const ProcessProxyException(
          'bridgeOperationFailed',
          'quic_preparation_required',
        ),
        l,
      ),
      l.processProxyErrorQuicPrepare,
    );
  });
}
