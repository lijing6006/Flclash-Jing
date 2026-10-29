import 'dart:io';

import '../test/services/process_proxy_record_detail_cases.dart';

void main() {
  for (final entry in processProxyRecordDetailCases.entries) {
    entry.value();
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln(
    '${processProxyRecordDetailCases.length} record-detail checks passed.',
  );
}
