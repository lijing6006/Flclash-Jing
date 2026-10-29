// ignore_for_file: avoid_relative_lib_imports

import '../../lib/services/process_proxy/policy.dart';
import '../../lib/services/process_proxy/runtime_lease.dart';

void _check(bool value) {
  if (!value) throw StateError('Assertion failed');
}

ProcessProxyRuntime _runtime({
  bool running = true,
  bool safe = false,
  bool system = false,
  bool tun = false,
  bool direct = false,
  int port = 12345,
  String password = '',
}) => ProcessProxyRuntime(
  running: running,
  safeMode: safe,
  systemProxy: system,
  tunEnabled: tun,
  directMode: direct,
  mixedPort: port,
  socksPort: 0,
  httpPort: 0,
  password: password,
);

final Map<String, void Function()> processProxyRuntimeCases = {
  'unchanged live endpoint keeps the lease valid': () {
    var invalidations = 0;
    final lease = ProcessProxyRuntimeLease(_runtime(), () => invalidations++);
    lease.observe(_runtime());
    lease.requireCurrent(_runtime());
    _check(lease.valid && invalidations == 0);
  },
  for (final entry in {
    'core stopped': _runtime(running: false),
    'safe mode': _runtime(safe: true),
    'system proxy': _runtime(system: true),
    'TUN': _runtime(tun: true),
    'direct mode': _runtime(direct: true),
    'listener port': _runtime(port: 23456),
    'credentials': _runtime(password: 'changed'),
    'listener removed': _runtime(port: 0),
    'provider unavailable': null,
  }.entries)
    '${entry.key} invalidates once without silently restoring on same-port restart':
        () {
          var invalidations = 0;
          final lease = ProcessProxyRuntimeLease(
            _runtime(),
            () => invalidations++,
          );
          lease.observe(entry.value);
          lease.observe(_runtime());
          lease.observe(entry.value);
          _check(!lease.valid && invalidations == 1);
          try {
            lease.requireCurrent(_runtime());
            throw StateError('Expected invalidation');
          } on ProcessProxyException catch (error) {
            _check(error.code == 'coreConfigurationChanged');
          }
        },
  'disposed lease never issues another stop callback': () {
    var invalidations = 0;
    final lease = ProcessProxyRuntimeLease(_runtime(), () => invalidations++);
    lease.dispose();
    lease.observe(_runtime(running: false));
    _check(!lease.valid && invalidations == 0);
  },
  'invalid initial runtime cannot create a live lease': () {
    try {
      ProcessProxyRuntimeLease(_runtime(running: false), () {});
      throw StateError('Expected core gate');
    } on ProcessProxyException catch (error) {
      _check(error.code == 'coreNotRunning');
    }
  },
};
