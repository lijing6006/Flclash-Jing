# Flclash-Jing native ProxyLane bridge / 原生桥接

**Experimental Windows source. Not compiled or injection-tested in this Linux workspace.**

The companion owns the same `IGlobalProxy` runtime that proxies its explicitly launched root process and descendants. It does not inspect an unrelated external ProxyLane GUI instance. All UI data comes from that runtime's actual callbacks, `GetTrafficTotals` and `IProxyTlsControl::QueryProtocol`. No fake traffic or success replies.

## Build / 构建

Use MSVC x64 (Windows 10+). Keep the official source checkout at exactly `c95248ac8cc790efe0ebaa37383b1008e42c78ce` (v1.3.5):

```powershell
git clone https://github.com/threatexpert/ProxyLane.git ProxyLane-source
git -C ProxyLane-source checkout c95248ac8cc790efe0ebaa37383b1008e42c78ce
cmake -S windows/proxylane_bridge -B build/proxylane-bridge -A x64 -DPROXYLANE_SOURCE_DIR="$PWD/ProxyLane-source"
cmake --build build/proxylane-bridge --config Release
ctest --test-dir build/proxylane-bridge -C Release --output-on-failure
```

This target includes upstream ABI headers and its MIT-licensed nlohmann JSON header at build time. It does not compile, vendor or redistribute the Hook implementation or backend binaries. CMake checks the source pin and rejects modified tracked ABI/header files. Distributing a compiled companion must retain upstream notices in `UPSTREAM-LICENSE` and `NLOHMANN-LICENSE`; actual backend distribution requires its complete third-party notices and a separate license review.

The parent must copy `FlClashProxyBridge.exe` **beside** the user's complete, version-matched backend in an isolated per-user session directory. The Hook's optional module loader resolves `ProxyLaneMitm64.dll` relative to the **host executable**, not the Hook DLL. `configure.backend_directory` must match the companion's directory. The copied runtime components stay locked against replacement while the broker runs.

## Security boundaries / 安全边界

- The companion requires pipe stdin/stdout; FlClash supplies private inherited anonymous pipes, never a TCP listener, shell or remotely accessible control endpoint. Child targets do not inherit these handles.
- `hello` returns a cryptographically random per-session token over that pipe. Later requests require the token and increasing IDs. Frames are bounded to 64 KiB in and less than 1 MiB out; nesting, duplicates, field names, query types and integer limits are validated.
- Proxy endpoint host is always `127.0.0.1`; actual port comes from FlClash. The parent checks current core intent and proxy handshake before launch, and the broker rechecks local reachability. No system proxy, TUN, driver, elevation or security-product changes.
- Only a newly created **x64 root executable** is accepted. Existing-PID attachment, packaged/UWP roots and native ARM64 roots are deliberately not implemented. Normal child-process propagation uses the backend and is constrained to descendants of known process identities; process IDs alone are not trusted.
- The broker uses the public audited `AttachToI` API only for the exact suspended process it just created. A failed startup terminates only that newly created owned process. An anonymous startup job is assigned atomically through `PROC_THREAD_ATTRIBUTE_JOB_LIST`; until the initial thread resumes and the job limit is cleared, broker failure cleans up that new process instead of stranding it suspended. Stop, EOF and shutdown do not terminate running user applications. They may break their proxied connections; this is not a guaranteed kill switch.
- HTTPS/QUIC decryption, monitoring and recording start off. A monitoring request with decryption first requires an already initialized and trusted current-user CA. It never implicitly initializes or installs trust. Certificate actions require explicit confirmation and `scope: current-user`. Upstream certificate verification remains on.
- Recording and replay paths require explicit local-directory selection. Capture can contain credentials and personal data. A recording stop also stops monitoring and closes the recording; it is not a pause that silently resumes on the next plain monitor start.
- Upstream rules match hostname:port when a hostname is present, otherwise literal-IP:port. Private-IP rules do not override a hostname. Corporate split-DNS domains must be listed explicitly. Local DNS is default, private-DNS redirection is always off.

## Wire contract / 协议

Request: `{"v":1,"id":1,"op":"hello","args":{}}`.
Reply: `{"v":1,"id":1,"ok":true,"result":{"session_token":"...","pid":123,"capabilities":{...}}}`.
Subsequent requests add `"token":"..."`. Error replies have `ok:false,error:{code,message}`. `result` is always an object.

The authoritative allowlist and argument validation are in `protocol.hpp`. Supported operations:

| Operation | Required / notable args | Upstream source |
|---|---|---|
| `configure` | backend_directory, port, proxy_type; optional username/password, children, block_udp, remote_dns, bypass | ProxyModule.h / ProxySettingsInfo |
| `launch` | executable, arguments, confirm:true | CreateProcessW then audited AttachToI |
| `status`, `logs` | logs: after, limit<=128 | callbacks / GetTrafficTotals |
| `monitor.start`, `monitor.stop` | start: confirm:true, decrypt_https, decrypt_quic | MitmBridge.cpp monitor_start/monitor_stop |
| `capture.options` | settings (validated MITM limits), confirm:true | options.rs / mitm_options |
| `recording.start`, `recording.stop` | start: directory, capacity_mib, reserve_mib, decrypt flags, confirm:true | mitm_options recording + monitor_start |
| `replay.open`, `replay.close` | open: directory, confirm:true; no index rebuild | lib.rs recording_open/recording_close |
| `query` | allowlisted read-only type and bounded parameters | protocol.rs / recording_reader.rs |
| `ca.query`, `ca.initialize`, `ca.trust`, `ca.remove` | writes: scope:current-user, confirm:true | IProxyTlsControl::ManageCA |
| `stop`, `shutdown` | confirm:true | DisableProxy; no target kill |

Read-only queries include `stats`, `poll`, `cache_status`, `cache_read`, `cache_decode`, `dns_read`, `doh_read`, `recording_status`, `recording_page`, `recording_detail`, `monitor_status`, `monitor_stop_status`. Generic query cannot invoke mutations, load arbitrary modules, supply arbitrary file paths, weaken TLS verification or rebuild recording indexes. Each backend query is invoked once with a bounded buffer; an oversized reply fails without repeating a potentially mutating operation.

## Verified here / 已验证

The portable validator tests use real production parser and policy code:

```bash
g++ -std=c++17 -Wall -Wextra -Werror -I/path/to/ProxyLane-source/third_party windows/proxylane_bridge/tests/protocol_test.cpp -o /tmp/bridge-protocol-test
/tmp/bridge-protocol-test
```

Windows compilation, actual owned-process hook startup, child propagation, CA trust prompts, QUIC and recording/replay must be verified on an isolated Windows test account before publishing binaries. No injection, CA installation or capture was executed in this environment.
