import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_runtime_cases.dart';

void main() {
  for (final entry in processProxyRuntimeCases.entries) {
    test(entry.key, entry.value);
  }
}
