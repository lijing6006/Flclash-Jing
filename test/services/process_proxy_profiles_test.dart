import 'package:flutter_test/flutter_test.dart';

import 'process_proxy_profiles_cases.dart';

void main() {
  for (final entry in processProxyProfilesCases.entries) {
    test(entry.key, entry.value);
  }
}
