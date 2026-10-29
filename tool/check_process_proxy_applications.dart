import 'dart:io';

import '../test/services/process_proxy_application_cases.dart';

void main() {
  for (final entry in processProxyApplicationCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln(
    '${processProxyApplicationCases.length} application checks passed.',
  );
}
