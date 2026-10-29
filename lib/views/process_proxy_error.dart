import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/services/process_proxy.dart';

String processProxyErrorMessage(Object error, AppLocalizations l) {
  if (error is! ProcessProxyException) return l.processProxyErrorGeneric;
  return switch (error.code) {
    'coreNotRunning' => l.processProxyCoreRequired,
    'safeMode' => l.processProxySafeMode,
    'globalProxyEnabled' => l.processProxyTakeoverOff,
    'noListener' => l.processProxyNoPort,
    'invalidArguments' => l.processProxyInvalidArguments,
    'backendNotTrusted' => l.processProxyErrorTrust,
    'backendName' ||
    'backendVersionMismatch' => l.processProxyErrorBackendVersion,
    'invalidExecutable' || 'missingExecutable' => l.processProxyErrorExecutable,
    'missingBackendComponent' ||
    'missingAdvancedModule' => l.processProxyErrorComponents,
    'invalidSettings' => l.processProxyErrorSettings,
    'launchBusy' => l.processProxyErrorBusy,
    'serviceDisposed' || 'sessionUnavailable' => l.processProxyErrorSession,
    'windowsOnly' || 'windowsUnavailable' => l.processProxyErrorWindows,
    'coreConfigurationChanged' => l.processProxyErrorCoreChanged,
    'invalidAuthentication' ||
    'listenerAuthenticationFailed' => l.processProxyErrorAuthentication,
    'listenerHandshakeFailed' ||
    'listenerUnavailable' => l.processProxyErrorListener,
    'windowsQueryFailed' ||
    'windowsQueryTimeout' ||
    'responseTooLarge' => l.processProxyErrorProcessQuery,
    'invalidBypassRule' => l.processProxyErrorRule(_ruleDetail(error.detail)),
    'unsupportedCidr' => l.processProxyErrorCidr(_ruleDetail(error.detail)),
    'tooManyRules' => l.processProxyErrorRuleLimit,
    'quicNeedsUdp' => l.processProxyErrorQuic,
    _ => l.processProxyErrorGeneric,
  };
}

String processProxyExitMessage(int? code, AppLocalizations l) {
  return switch (code) {
    0 => l.processProxyExited,
    4 => l.processProxyErrorListener,
    5 => l.processProxyErrorExecutable,
    7 => l.processProxyErrorHook,
    8 => l.processProxyErrorComponents,
    9 => l.processProxyErrorSession,
    _ => l.processProxyErrorGeneric,
  };
}

String _ruleDetail(String? detail) {
  final safe = (detail ?? '')
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
      .trim();
  return safe.length > 160 ? '${safe.substring(0, 160)}…' : safe;
}
