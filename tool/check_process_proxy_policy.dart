import 'dart:io';

import '../test/services/process_proxy_policy_cases.dart';

void main() {
  for (final entry in processProxyPolicyCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('${processProxyPolicyCases.length} policy checks passed.');
}
