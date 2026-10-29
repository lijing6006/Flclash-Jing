import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_policy_cases.dart';

void main() {
  for (final entry in processProxyPolicyCases.entries) {
    test(entry.key, entry.value);
  }
}
