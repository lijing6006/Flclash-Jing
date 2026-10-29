import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/services/process_proxy.dart';

String processProxyErrorMessage(Object error, AppLocalizations l) {
  if (error is! ProcessProxyException) return l.processProxyErrorGeneric;
  return switch (error.code) {
    'coreNotRunning' => l.processProxyCoreRequired,
    'safeMode' => l.processProxySafeMode,
    'directMode' => l.processProxyDirectMode,
    'globalProxyEnabled' => l.processProxyTakeoverOff,
    'noListener' => l.processProxyNoPort,
    'pathTooLong' => l.processProxyErrorPathLength,
    'invalidArguments' => l.processProxyInvalidArguments,
    'invalidWorkingDirectory' => l.processProxyErrorWorkingDirectory,
    'invalidChildRule' => l.processProxyErrorChildRule,
    'nativeBridgeRequired' => l.processProxyErrorNativeRequired,
    'quicNeedsSocks' => l.processProxyErrorQuicSocks,
    'invalidQuery' => l.processProxyJsonObjectRequired,
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
    'bridgeFrameTooLarge' => l.processProxyErrorResponseLarge,
    'bridgeOperationFailed' => _bridgeErrorMessage(error.detail, l),
    final code when code.startsWith('bridge') => l.processProxyErrorBridge,
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

String _bridgeErrorMessage(String? code, AppLocalizations l) {
  return switch (code) {
    'response_too_large' ||
    'request_too_large' => l.processProxyErrorResponseLarge,
    'certificate_required' => l.processProxyErrorCaRequired,
    'monitor_active' => l.processProxyErrorMonitoringActive,
    'recording_directory' || 'invalid_path' => l.processProxyErrorDirectory,
    'target_architecture' => l.processProxyErrorArchitecture,
    'backend_version' => l.processProxyErrorBackendVersion,
    'backend_abi' ||
    'backend_load' ||
    'advanced_module_unavailable' => l.processProxyErrorComponents,
    'invalid_executable' ||
    'invalid_target' ||
    'target_start' => l.processProxyErrorExecutable,
    'target_hook' => l.processProxyErrorHook,
    'proxy_not_running' ||
    'listener_unavailable' ||
    'proxy_start' => l.processProxyErrorListener,
    'quic_requires_udp' => l.processProxyErrorQuic,
    'quic_preparation_required' => l.processProxyErrorQuicPrepare,
    'invalid_arguments' => l.processProxyInvalidArguments,
    'invalid_request' => l.processProxyJsonObjectRequired,
    _ => l.processProxyErrorBridge,
  };
}
