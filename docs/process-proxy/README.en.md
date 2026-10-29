# Flclash-Jing

An experimental Windows-first FlClash v0.9.2 integration of ProxyLane v1.3.5. A native Process Proxy sidebar page selects a new application and its children, using the current configured local listener and routing rules without enabling system proxy or TUN.

**Not a validated Windows release.** Local portable checks do not establish Flutter compilation, Windows injection correctness or traffic routing. Localization generation is still required. See [validation](VALIDATION.md), [capabilities](CAPABILITIES.md) and [architecture](ARCHITECTURE.en.md).

The repository provides native configuration/process search, strict core/listener/safe-mode gates, validated bypass rules, isolated external-backend sessions, and an experimental stdio companion/native advanced workspace. The companion owns the same runtime that launches the target; it has no network control listener. Decryption, QUIC decryption, monitoring and recording start off; current-user CA changes require separate explicit confirmation.

The user supplies official matching ProxyLane files; binaries and Hook implementation are not redistributed. Compatibility launch without the companion is not full native feature migration. Native bridge target-architecture limits are declared in its capabilities.

Build prerequisites follow upstream Flutter 3.47.6. Run `flutter pub get`, `dart run intl_utils:generate`, `flutter analyze --no-fatal-infos`, and focused `flutter test` suites. See `windows/proxylane_bridge/README.md` for the separate Windows companion build. The development environment's dependency bootstrap was blocked after an unwanted cloud-metadata request; it was not retried or bypassed.

IP bypass applies to upstream's IP representation only when no hostname is available. Add corporate domains explicitly; local DNS is the default and private DNS is never redirected to a public resolver. Existing browser singletons can reuse an unproxied instance. Current FlClash rules still determine DIRECT/proxy selection. No anti-cheat/security-product workarounds, no automatic certificate installation, and no claim of fail-closed protection. macOS is out of scope.

GPL-3.0, preserving upstream FlClash notices. ProxyLane's MIT and third-party notices remain separate. [Original upstream README](UPSTREAM_README.en.md).

## Optional bundled companion

The Windows root CMake configuration accepts `FLCLASH_BUILD_PROCESS_PROXY_BRIDGE=ON` and `PROXYLANE_SOURCE_DIR=<audited checkout>`. It is OFF until Windows validation is complete. Alternatively build the standalone companion and place `FlClashProxyBridge.exe` next to the FlClash application executable, retaining the bridge's upstream license notice. The launcher copies it into each isolated runtime directory before use. Never copy a build-output directory from an unrelated application.
