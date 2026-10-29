# Flclash-Jing architecture and audit

Development work, not a Windows-validated release. Baselines: official FlClash v0.9.2 (`7fd417fb9a9a277c6a9339a8ac87f907df7c25f7`, GPL-3.0), official ProxyLane v1.3.5 (`c95248ac8cc790efe0ebaa37383b1008e42c78ce`, top-level MIT). Preserve upstream notices. ProxyLane includes additional third-party notices; no Hook implementation or compiled backend is redistributed here.

The native menu checks existing core lifecycle, running time and safe mode, derives the actual configured loopback listener, probes its proxy protocol, and starts only the explicitly selected new executable and optionally its children. It never changes system proxy/TUN, attaches to arbitrary existing processes, kills applications, installs a CA, or enables capture by default. A running-process search is selection for relaunch, not proof of attachment. Existing browser singletons can reuse an unproxied instance.

Each session stages known files from the user's official backend installation into a separate per-user directory, without copying its existing INI or captures. Local proxy credentials, if enabled, are sensitive session configuration. Decryption, QUIC decryption, monitoring and recording default off.

The public CLI only supports `--auto --profile <name> --run <exe> [-- <args...>]`. Traffic and recording APIs are in-process C++ interfaces, not an existing web service. The implemented experimental native advanced UI communicates over authenticated child stdio with the same runtime owner; loading another DLL instance would not inspect that session. Private inherited pipes have no network control listener. The bridge constrains identities to its own newly launched root and verified descendants.

Upstream target rules use shell wildcard matching on hostname:port, or ip:port only when no hostname is available. IPv4 CIDR can be expanded within a strict limit; unsupported expressions must fail validation. Private-IP bypass is not a universal resolved-address policy: add corporate domains explicitly. Default local DNS preserves split DNS; private-resolver redirection is always disabled. UDP is blocked by default for TCP fallback, not a guaranteed kill switch. Protected applications and elevation boundaries are not bypassed.

Linux cannot validate Windows process injection or CA behavior. Flutter dependency bootstrap was blocked by the security reviewer after it attempted a cloud-metadata request to 169.254.169.254. That operation was not retried or bypassed. Offline checks and Windows-required acceptance steps are reported separately.

Target allowlists are optional and subordinate to bypass rules; nonmatching traffic goes direct, not blocked. Child path filters apply only after descendant ownership validation, use the child’s queried full image path, and never filter the explicit root. An excluded child is not injected, so its descendants cannot automatically inherit this session. Empty filters retain unrestricted descendants.
