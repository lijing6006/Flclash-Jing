import 'dart:io';

import '../test/services/process_proxy_profiles_cases.dart';

Future<void> main() async {
  for (final entry in processProxyProfilesCases.entries) {
    await entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('${processProxyProfilesCases.length} profile checks passed.');
}
