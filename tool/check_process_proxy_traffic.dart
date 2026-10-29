import 'dart:io';

import '../test/services/process_proxy_traffic_cases.dart';

void main() {
  for (final entry in processProxyTrafficCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('${processProxyTrafficCases.length} traffic checks passed.');
}
