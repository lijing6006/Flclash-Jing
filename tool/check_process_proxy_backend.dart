import 'dart:io';

import '../test/services/process_proxy_backend_cases.dart';

Future<void> main() async {
  for (final entry in processProxyBackendCases.entries) {
    await entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('${processProxyBackendCases.length} backend checks passed.');
}
