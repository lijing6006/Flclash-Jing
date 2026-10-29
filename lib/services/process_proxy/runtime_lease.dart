import 'policy.dart';

typedef ProcessProxyRuntimeObserver =
    void Function() Function(void Function(ProcessProxyRuntime?) listener);

class ProcessProxyRuntimeLease {
  final ProcessProxyEndpoint endpoint;
  final void Function() _onInvalidated;
  bool _valid = true;
  bool _disposed = false;

  ProcessProxyRuntimeLease(
    ProcessProxyRuntime initial,
    void Function() onInvalidated,
  ) : endpoint = initial.endpoint,
      _onInvalidated = onInvalidated;

  bool get valid => _valid && !_disposed;

  void observe(ProcessProxyRuntime? current) {
    if (!valid) return;
    try {
      if (current != null && endpoint.sameAs(current.endpoint)) return;
    } on ProcessProxyException {
      // The same runtime gate that rejects new launches invalidates this lease.
    }
    _valid = false;
    _onInvalidated();
  }

  void requireCurrent(ProcessProxyRuntime current) {
    observe(current);
    if (!valid) throw const ProcessProxyException('coreConfigurationChanged');
  }

  void dispose() {
    _disposed = true;
  }
}
