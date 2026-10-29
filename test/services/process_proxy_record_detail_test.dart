import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_record_detail_cases.dart';

void main() {
  for (final entry in processProxyRecordDetailCases.entries) {
    test(entry.key, entry.value);
  }
}
