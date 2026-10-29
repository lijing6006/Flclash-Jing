import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_backend_cases.dart';

void main() {
  for (final entry in processProxyBackendCases.entries) {
    test(entry.key, entry.value);
  }
}
