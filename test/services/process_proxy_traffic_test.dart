import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_traffic_cases.dart';

void main() {
  for (final entry in processProxyTrafficCases.entries) {
    test(entry.key, entry.value);
  }
}
