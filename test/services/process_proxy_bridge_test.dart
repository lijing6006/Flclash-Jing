import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_bridge_cases.dart';

void main() {
  for (final entry in processProxyBridgeCases.entries) {
    test(entry.key, entry.value);
  }
}
