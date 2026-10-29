import 'dart:io';

import '../test/services/process_proxy_runtime_cases.dart';

void main() {
  for (final entry in processProxyRuntimeCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln(
    '${processProxyRuntimeCases.length} runtime lease checks passed.',
  );
}
