# 进一步迁移依据 / Remaining migration contracts

审计对象：ProxyLane v1.3.5，`c95248ac8cc790efe0ebaa37383b1008e42c78ce`。下列行号均相对于该只读上游版本。这里只核对代码契约，**不表示 Windows 编译、目标流量或解密验收通过**。

## 可直接复用现有桥接协议的界面功能

| 能力 | 精确契约与证据 | 当前边界 |
|---|---|---|
| 双向 Raw / Hex | `ProtocolViewModel.cpp:220–285,431–435`：`cache_decode` / `cache_read` 返回 `payload.data_base64`；显示字节是重建 headers + CRLF + body | 桥接已有读命令；界面必须区别已解码正文、压缩原字节和截断前缀，不称作原始 HTTP/2 wire |
| 缓存状态 | `ProtocolViewModel.cpp:318–330`：`cache_status{run_id,cache_id}` → `cache` 的 `evicted/finished/pending_chunks/reason` | 失效、仍写入、不可用必须显示，不能当作空正文成功 |
| DNS / DoH | `ProtocolViewModel.cpp:234–252,332–349`：`dns_read` / `doh_read` 返回 payload 与顶层 `text/decode_error` | 桥接已有；DNS 单报文最多 65535 字节 |
| TCP/UDP/QUIC Stream | `ProtocolViewModel.cpp:359–409`：双向 `cache_read`；UDP 包边界来自 `stream.datagrams` | 不得把 UDP 多个报文伪装成一个报文；加密 TLS 未解密时仍标记 encrypted |
| 离线详情 | `Page4Protocol.cpp:657`、`recording_reader.rs:174–224`：先 `recording_detail{run_id,cache_id 或 connection_id,preview_bytes}`，再读对应缓存 | `connection_id` 是字符串；离线 `run_id` 以 `recording:` 开头；过期 run 必须拒绝 |
| 过滤/分页 | `Page4Protocol.cpp:119–121,787–788`：`recording_page{offset,filter,protocol,limit}` | protocol: 0 全部、1 HTTP、2 TCP、3 UDP、4 TLS、5 DNS、6 QUIC；桥接每页至多 64 条 |
| 录制质量/配额 | `RecordingSettings.h:7–24,50–58`、`Page4.cpp:718–741`：`recording_status` 包括 `enabled/ended/stopped/reason/quality` | 开始录制每次显式同意；配额/预留范围 16–1048576 MiB；质量不完整/分析延迟不可隐去 |

源路径：前三个 C++ 文件在 `src/ProxyLane/`；`recording_reader.rs` 在 `src/ProxyLaneProtocol/src/`。payload 读请求还需 `direction:client|server`；`cache_read` 用 `offset,length`，`cache_decode` 用 `preview_bytes`。当前桥接把预览限制为 64 KiB、输出限制在 1 MiB 以下；超限明确失败，不重复可能变更状态的操作。

**“回放”是离线浏览，不是网络重发。** `src/ProxyLaneMitm/src/lib.rs:356–370` 只打开本地录制 reader 并分派查询；本项目不发送录制请求到原服务器。

## 需独立显式动作或产品边界的功能

- **QUIC 首次注入准备：** `src/ProxyLaneHook/BrowserQuicPolicy.h:9`、`HookWinsock.cpp:491`、`PRCPipeServer.cpp:427–430` 表明策略在首次注入时读取。`BrowserQuicPolicy.cpp:204–216` 的 locator 不初始化采集运行时；`QuicBridge.cpp:36` 另行检查解密是否开启。准备不需要事先创建或信任 CA；真正监视解密才在 `MitmBridge.cpp:151–165` 调用 CA 准备检查。`README.md:106` 要求修改选项后完全重启目标，并明确兼容调整保留到退出。桥接仅为新会话提供显式准备，绝不回溯修改旧进程。
- **QUIC兼容调整的持久性：** `BrowserQuicPolicy.cpp:59–60,134–165,204–220,255–274` 仅在已注入的当前目标中安装内存 detour，保留模块至进程退出；没有调用浏览器 profile/磁盘文件/注册表写入。`plm_quic_locate_image`（`src/ProxyLaneMitm/src/lib.rs:455–462`）只分析传入的内存镜像。该审计不意味着浏览器正常运行自身不会写入用户数据；它仅说明兼容策略本身没有持久化设置动作。没有停止监视时的 detach；必须退出目标才能移除进程内调整。
- **损坏录制索引恢复：** `Page4Protocol.cpp:500–509,787` 在用户再次确认后使用 `recording_open{path,rebuild_index:true}`。`recording_reader.rs:66–105` 取得录制锁，写临时索引并原子替换；不改原始载荷。桥接 `replay.open` 固定 `rebuild_index:false`；独立 `replay.rebuild_index{directory,confirm:true}` 仅在监视停止、离线视图关闭时调用该恢复一次，成功后打开恢复视图，generic query 仍不能写索引。
- **既有连接重建：** `Page4.cpp:582–604` 使用本运行时 `GetPTMInstance(0)->PrepareReconnect()` 获取受影响连接数，经确认后 `CompleteReconnect(true)`。上游 `ProxyTaskMgr.cpp:172–191,204–209` 的 snapshot 标记落在本运行时已有 TCP 对象上（含 bypass 直连，decrypt 参数目前被忽略），提交后由维护线程断开，应用自行重连。桥接提供 `connections.prepare_reconnect`、一次性字符串 preparation_id 与 60 秒有效期、显式确认的 `connections.reconnect` 和取消操作。准备前后与提交前核对本树 PID+创建时间，拒绝外部身份；监视开关不会自动提交。不存在 UDP 重连或实际应用重连成功保证。
- **目标/子进程规则：** `Page1.cpp:627–679` 支持目标 bypass/include 两种模式；`Page3.cpp:2882–2914` 支持子程序路径 include/exclude。桥接现提供 `include_targets` 与始终优先的 bypass，以及 child_filter include/exclude；空子规则不限制。子路径以已验证进程句柄重新查询，无法读取时拒绝，不能用全局 attach 补齐。裸文件名由界面显式规范化为 `*\\basenameglob`；上游示例为 `*chrome.exe`、`C:\\Windows\\System32\\*`（locales/zh-CN.json:140）。排除中间子程序也切断它的自动后代代理链。
- **跳过上游证书校验：** `Page4.cpp:248–264` 存在该危险选项。本桥接维持证书校验开启，不通过 generic query 接受 `skip_upstream_verify`；若产品未来允许，须另行安全设计，不能混在普通解密开关里。

## GONC TLS-PSK 不是目标流量解密

`src/ProxyLane/Page1.cpp:744–799` 将 `ProxyInfo.reserved=1`、UTF-8 `strTransportPsk`（1–255 字节）配置为加密**代理入口**；`src/ProxyLaneHook/ProxyTransportPolicy.h:21–26` 允许 SOCKS5/HTTP10/HTTP11。TCP 在 `PRCTcpPeer.cpp:156–166` 增加 secure layer；UDP 的 `PRCUdpPeer.cpp:163–172` 仅支持 SOCKS5。`README.md:82–88` 描述与远端 gonc `:s5s` 服务的 TLS-PSK 配对，HTTP 需要对方启用相应服务。英文 README 的 “only SOCKS5” 已落后于该版本代码/中文说明，不能据此删减上游能力。

本产品要求流量进入当前 FlClash 节点对应的本地普通 mixed/SOCKS/HTTP 端口。向该端口发送 gonc TLS-PSK 握手会协议不匹配；改成远端 gonc 入口则绕过指定 FlClash 通道。当前不显示可用的 PSK 开关，也不把它算作已迁移。保留该能力需要另行定义真正支持 TLS-PSK 的本地终结器/节点接入，不能只加文本框假装兼容。

## 工作目录与命令行

`src/ProxyLane/AutomationOptions.cpp:63–130` 的 CLI 仅支持 `--auto/--profile/--run/--bootstrap-event/--`，没有 cwd 字段。原生 app picker 通过 `InstalledApplications.cpp:319` 读取快捷方式工作目录。桥接的 `launch.working_directory` 保留此信息；兼容 CLI 对非空自定义目录应显式拒绝。

## English summary

The existing read-only protocol can drive genuine directional Raw/Hex, payload/cache status, DNS/DoH, offline detail and filtered pages. Do not conflate reconstructed plaintext with original wire bytes, or offline replay with network retransmission. QUIC compatibility preparation is a separate first-injection, process-lifetime opt-in; capture/decryption and CA trust remain independent. Index recovery writes metadata and needs its own explicit confirmation. GONC encrypts the proxy-server transport and is not compatible with the required ordinary local FlClash listener. Every Windows-specific behavior remains unverified in this workspace.

## 停止不等于卸载 Hook / Stop is not unhook

固定版本 `GlobalProxy.cpp:113–126`、`PRCTcpServer.cpp:153–157` 的 DisableProxy 关闭broker的PRC/监听/任务，不卸载目标内的Hook。`ProxyModule.cpp:187–191,230–240` 与 `ProxyModule.h:363–366` 显示DLL被固定，显式unhook属于目标内部且需静止状态，本桥接不调用它。

因此停止/核心失效后，新的被拦截TCP及未缓存UDP可能因broker缺失返回HOOK_FAILED/SOCKET_ERROR，而非恢复直连（`HookWinsock.cpp:1422–1429,1860–1861,1048–1057,1723–1732`）。这仍不是全局fail-closed：loopback bypass保持；remote-DNS缺失管道时可回到系统DNS（`:652–675,1005–1010`）；新子进程在管道失败时可跳过注入并继续执行（`:2475–2476,2508`）；缓存UDP还可能指向旧PRC端点（`:1819–1843`）。不自动杀/重启目标，不承诺DNS或所有后代不泄漏。需要干净状态时，由用户保存工作并手动关闭/重新启动所选应用。

Stopping the broker does not restore a pristine target process. Hooks can remain, new intercepted connections can fail, and loopback/DNS/new-child behavior is not a universal kill switch. Save work and manually relaunch the selected application when a clean process is needed. These are source-reviewed semantics, not Windows runtime validation.
