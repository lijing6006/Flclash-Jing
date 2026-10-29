import 'dart:io';

import '../test/services/process_proxy_recording_cases.dart';

void main() {
  for (final entry in processProxyRecordingCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln(
    '${processProxyRecordingCases.length} recording checks passed.',
  );
}
