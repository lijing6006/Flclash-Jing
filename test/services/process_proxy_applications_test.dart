import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_application_cases.dart';

void main() {
  for (final entry in processProxyApplicationCases.entries) {
    test(entry.key, entry.value);
  }
}
