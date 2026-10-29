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


Native source now also includes named profiles with previewed, non-overwriting JSON imports and argument-free exports by default; a read-only App Paths/Start Menu EXE catalog preserving shortcut arguments and working directories; bounded directional payload Raw/Hex and DNS/DoH previews; and separately confirmed index recovery and same-session TCP reconnect snapshots. QUIC compatibility preparation must be selected before the new target starts and lasts until that process exits. It does not start capture or alter browser profile files. Reconnect may interrupt direct-bypass connections too and does not guarantee application recovery. Offline replay never resends network requests.

Saved profiles and their local backup contain plaintext paths and arguments. Exported paths/rules may still be private even when arguments are omitted. Isolated runtime directories are not recursively removed automatically; compatibility-session INI credentials are removed on normal backend exit on a best-effort basis. Crashes or file locks may leave a copy for the user to clean up. None of these source additions has been Windows-runtime validated yet.

Offline recording browsing now has native protocol/text filters, bounded manual pages, stable recording identities, real details and payload navigation. Recording startup verifies the echoed directory/quotas and actual active status, not merely an enabled option. Plain monitoring must explicitly confirm recording disabled before it can start. Stop/disk operations have a 120-second request budget and EOF cleanup another 120 seconds while output is drained; exhausting the final budget can still leave an incomplete recording. Uncertain mutations are never retried automatically. Existing TLS bridges and trusted CA certificates are not removed by stopping monitoring.
