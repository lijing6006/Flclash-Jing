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
- QUIC browser compatibility preparation is a separate pre-launch opt-in (`prepare_quic:true, confirm_quic:true`) requiring SOCKS5 and enabled UDP. It does not initialize/trust a CA, decrypt or capture traffic. It may adjust a compatible Chromium target’s additional local/enterprise-CA restriction; that process-local compatibility change lasts until the target exits, including after monitoring stops. It cannot be enabled retroactively for a running target.
- HTTPS/QUIC decryption, monitoring and recording start off. A monitoring request with decryption first requires an already initialized and trusted current-user CA. It never implicitly initializes or installs trust. Certificate actions require explicit confirmation and `scope: current-user`. Upstream certificate verification remains on.
- Recording and replay paths require explicit local-directory selection. Rebuilding a recording index is a separate confirmed metadata write, permitted only with monitoring stopped and the existing offline view closed. It is never an automatic retry of a failed read. Capture can contain credentials and personal data. A recording stop also stops monitoring and closes the recording; it is not a pause that silently resumes on the next plain monitor start.
- Upstream rules match hostname:port when a hostname is present, otherwise literal-IP:port. Private-IP rules do not override a hostname. Corporate split-DNS domains must be listed explicitly. Local DNS is default, private-DNS redirection is always off.

## Wire contract / 协议

Request: `{"v":1,"id":1,"op":"hello","args":{}}`.
Reply: `{"v":1,"id":1,"ok":true,"result":{"session_token":"...","pid":123,"capabilities":{...}}}`.
Subsequent requests add `"token":"..."`. Error replies have `ok:false,error:{code,message}`. `result` is always an object.

The authoritative allowlist and argument validation are in `protocol.hpp`. Supported operations:

| Operation | Required / notable args | Upstream source |
|---|---|---|
| `configure` | backend_directory, port, proxy_type; optional username/password, children, block_udp, remote_dns, bypass, include_targets, child_filter/mode, prepare_quic + confirm_quic | ProxyModule.h / ProxySettingsInfo |
| `launch` | executable, arguments, optional working_directory, confirm:true | CreateProcessW then audited AttachToI |
| `status`, `logs` | logs: after, limit<=128 | callbacks / GetTrafficTotals |
| `monitor.start`, `monitor.stop` | start: confirm:true, decrypt_https, decrypt_quic | MitmBridge.cpp monitor_start/monitor_stop |
| `capture.options` | settings (validated MITM limits), confirm:true | options.rs / mitm_options |
| `recording.start`, `recording.stop` | start: directory, capacity_mib, reserve_mib, decrypt flags, confirm:true | mitm_options recording + monitor_start |
| `replay.open`, `replay.close` | open: directory, confirm:true; read-only index use | lib.rs recording_open/recording_close |
| `replay.rebuild_index` | directory, confirm:true; stopped monitor, closed offline view | recording_reader.rs explicit index recovery |
| `connections.prepare_reconnect` | empty; returns preparation_id:string, count, expires_in_ms | GetPTMInstance(0)->PrepareReconnect |
| `connections.reconnect`, `connections.cancel_reconnect` | preparation_id:string; reconnect also confirm:true | CompleteReconnect; owned TCP snapshot only |
| `query` | allowlisted read-only type and bounded parameters | protocol.rs / recording_reader.rs |
| `ca.query`, `ca.initialize`, `ca.trust`, `ca.remove` | writes: scope:current-user, confirm:true | IProxyTlsControl::ManageCA |
| `stop`, `shutdown` | confirm:true | DisableProxy; no target kill |

Read-only queries include `stats`, `poll`, `cache_status`, `cache_read`, `cache_decode`, `dns_read`, `doh_read`, `recording_status`, `recording_page`, `recording_detail`, `monitor_status`, `monitor_stop_status`. Generic query cannot invoke mutations, load arbitrary modules, supply arbitrary file paths, weaken TLS verification or rebuild recording indexes. Each backend query is invoked once with a bounded buffer; an oversized reply fails without repeating a potentially mutating operation.

## 启动前 QUIC 与工作目录 / Pre-launch QUIC and working directory

`prepare_quic` 默认关闭。只有用户单独同意后，才发送 `prepare_quic:true, confirm_quic:true`，且必须使用 SOCKS5 并关闭“阻止 UDP”。准备仅设置首次注入时的兼容策略，不开启监视、解密、录制或任何证书动作。状态字段 `quic_preparation_requested` 表示已请求准备，不证明目标应用兼容修改成功。QUIC 解密仍须用户在高级页单独开启，并先明确完成当前用户 CA 初始化与信任。

未准备的会话请求 QUIC 解密会返回 `quic_preparation_required`，需用户自行创建新会话；不重新注入、重启或结束旧目标。已经准备的目标可能保留兼容修改直到退出，停止监视不撤回。上游证据和其他剩余能力见 [UPSTREAM_CONTRACTS.md](UPSTREAM_CONTRACTS.md)。

当前路径字段采用 **240 个 UTF-8 字节**的保守上限（不是 240 个中文字或 UTF-16 单元），拒绝而不截断。上游注入入口仍使用 `GetModuleFileNameA` 和 `MAX_PATH` 获取 Hook 路径；非当前 Windows ANSI 代码页可表示的后端路径仍需真实 Windows 验证，不能仅提高 UTF-8 帧上限就宣称长路径兼容。

`launch.working_directory` 可省略或为空，此时使用目标 EXE 所在目录；非空值须为现有普通本地目录，拒绝 UNC、设备路径和重解析目录/祖先。盘符根目录仅能作为工作目录，不能作为后端/录制路径。它由 `CreateProcessW` 的工作目录参数传入，不拼入命令或启动 shell。官方兼容 CLI 没有工作目录参数，调用方应拒绝非空自定义目录而非忽略。

The preparation flag never implies successful compatibility or active decryption. The backend still performs its own compatibility checks. A supplied working directory is passed directly to `CreateProcessW`; no command shell is involved.

## 索引恢复与连接重建 / Index recovery and TCP reconnection

`replay.rebuild_index{directory,confirm:true}` 是用户选定目录中的索引写操作，不是普通读取的自动降级。必须先停止监视并关闭现有离线视图；成功返回 `run_id`，并打开恢复后的离线视图。上游锁定录制目录、从已有元数据构建临时索引后替换，不重写原始请求/载荷。处理大型目录可能耗时，超时不证明操作未发生，不能自动重试；异常终止可能留下临时索引文件。

TCP 重建使用两阶段、一次性确认：

1. `connections.prepare_reconnect{}` → `{preparation_id:"1",count:3,expires_in_ms:60000,scope:"session_tcp",automatic_reconnect:false}`。该步骤只选择现有连接，不断开。
2. UI 展示数量与风险后，`connections.reconnect{preparation_id:"1",confirm:true}` → `{scheduled:true,selected_count:3,completed:false,scope:"session_tcp",automatic_reconnect:false}`。响应仅表示已请求上游维护线程断开，不宣称应用已重新连接。
3. 用户取消时发送 `connections.cancel_reconnect{preparation_id:"1"}`。取消、停止后端、新准备或 60 秒期限使旧确认失效。过期快照不会自动断开任何连接。

受影响的是**该运行时已经选中的 TCP 连接，包括 bypass 直连**，不含 UDP、其他 ProxyLane 实例或准备之后的新连接。审计使用持有进程树的 PID 与创建时间，在准备前后及提交前枚举确认；异常身份使操作失败。断开可能中断上传/登录会话，应用是否自动重连由应用决定。监视/解密开关不会自动提交重连，任意 PID/任务 ID 输入均不被协议接受。

Index recovery is an explicit metadata write. Reconnect confirmation applies only to the snapshot of TCP tasks in this broker's owned runtime, including direct bypass routes, and expires after 60 seconds. It schedules disconnection; it does not restart applications or guarantee reconnection. No operation is retried automatically after an uncertain result.

## 目标与子进程规则 / Target and child filters

`configure.include_targets` 为可选 host:port/IP:port 通配符数组，校验与 `bypass` 相同，各至多 512 条。决策顺序：先检查 bypass；命中则直连，不会被 include 覆盖。未命中 bypass 时，若 include 非空，仅命中的目标走本地 FlClash，其余直连（不是阻断）。空 include 保持原先默认代理语义。主机名优先于 IP 的上游语义不变，企业 split-DNS 域名仍需显式 bypass。兼容 CLI 的单一 target-mode 不能忠实表达 include+bypass 组合，因此含 include 的配置必须使用原生桥接。

`configure.child_filter_mode` 为 `exclude`（默认）或 `include`，`child_filter` 为至多 128 条、每条至多 240 个 UTF-8 字节的编译后模式。例如：

```json
{"include_targets":["*.example.com:*"],"bypass":["10.*:*"],
 "child_filter_mode":"exclude","child_filter":["*\\helper*.exe","C:\\Tools\\*"]}
```

桥接只接收本地盘符绝对路径 glob 或 `*\basenameglob`；裸文件名须由界面编译为后一形式。禁止 UNC、设备路径、分号、多规则管道分隔符、控制字符、`.`/`..` 路径段。空规则列表在两种模式下都表示不额外限制，与上游一致。模式只作用于新子进程，不改变用户明确选中的根程序。

只有已属于本会话的父子 PID+创建时间核验通过，才读取子进程真实完整路径进行匹配，再登记允许的子进程。启用过滤时，无法可靠读取路径会拒绝该子进程，不用截断/猜测的路径放行。被排除的子程序不会加载代理 Hook，因此其后代也不会自动继承；include 模式需包含必要的中间启动器。规则不扩大到其它根进程或既有进程。

Target includes never override bypass. Child filtering preserves process ownership checks and matches the actual image path, not a claimed/truncated callback path. Both use upstream `PathMatchSpecW` semantics. Portable tests cover validation and routing decisions; `bridge_windows_matcher_test` contains real Windows matcher checks but has not run in this Linux workspace.

## Verified here / 已验证

The portable validator tests use real production parser and policy code:

```bash
g++ -std=c++17 -Wall -Wextra -Werror -I/path/to/ProxyLane-source/third_party windows/proxylane_bridge/tests/protocol_test.cpp -o /tmp/bridge-protocol-test
/tmp/bridge-protocol-test
```

Windows compilation, actual owned-process hook startup, child propagation, CA trust prompts, QUIC and recording/replay must be verified on an isolated Windows test account before publishing binaries. No injection, CA installation or capture was executed in this environment.
