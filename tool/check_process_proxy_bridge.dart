import 'dart:io';

import '../test/services/process_proxy_bridge_cases.dart';

Future<void> main() async {
  for (final entry in processProxyBridgeCases.entries) {
    await entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('${processProxyBridgeCases.length} bridge checks passed.');
}
