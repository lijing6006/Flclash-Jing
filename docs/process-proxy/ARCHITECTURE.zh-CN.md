# Flclash-Jing：进程代理集成审阅

状态：开发中，不是 Windows 实测通过的发行版。2026-10-28。

## 固定的上游基线

- FlClash 官方 `chen08209/FlClash`，v0.9.2，`7fd417fb9a9a277c6a9339a8ac87f907df7c25f7`，GPL-3.0。
- ProxyLane 官方 `threatexpert/ProxyLane`，v1.3.5，`c95248ac8cc790efe0ebaa37383b1008e42c78ce`，顶层 MIT。实时 git 标签比搜索引擎缓存更新。
- ProxyLane 第三方包含 Detours、nlohmann/json（MIT）、TLS/Rust notices，以及 AsyncSocketEx 自带署名与商业通知文本；不把顶层 MIT 当作所有第三方的唯一许可。本项目不分发其预编译后端或复制其 Hook 实现。用户选择合法取得的官方完整安装。
- FlClash 的原始 GPL 许可证、署名、源代码保留。新增集成采用相同 GPL 许可。仓库公开不代表微软平台代码已经实测。

## 信任与数据流

原生菜单 → 现有 core 生命周期/运行时间/安全模式门禁 → 配置中真实 mixed/SOCKS/HTTP 端口 → 回环代理握手确认 → 隔离的后端会话 → 用户明确选择的新程序及其子进程。

不更改系统代理/TUN，不自动附着正在运行的进程，不结束已有应用，不自动安装根证书。搜索进程仅用于选择程序路径。浏览器单实例复用可能把新启动请求交给旧的未代理实例，必须由用户自行退出原实例后重试。

每次启动把用户所选安装中的已知组件复制到个人应用数据目录的独立会话目录，不覆盖源安装的 ProxyLane.ini。解密、QUIC 解密、录制和监视均默认关闭；不复制原安装的配置或捕获数据。会话配置可能含用户已设置的本地代理认证，必须按个人敏感配置保管。

## 实际协议与限制

现有自动化 CLI 为 `--auto --profile <name> --run <exe> [-- <args...>]`。没有 JSON Web 服务；`QueryProtocol` 是进程内 C++ 接口，不可伪装成现成网络 API。完整原生高级界面需由同一个 runtime owner 的 companion 承载，而不是加载另一份 DLL 后展示不相关统计。

目标规则实际使用 `PathMatchSpec(hostname:port)`，没有 hostname 时才匹配 `ip:port`。不原生支持 CIDR。适配器可以有限展开 IPv4 CIDR；不能安全表达的输入必须拒绝，而不是静默忽略。IP/私网排除不能保证匹配已携带域名的连接；公司域名应单独列入直连规则。本地 DNS 为默认；远程 DNS 是可选项，私有 DNS 重定向始终关闭，绝不强制改到公共 DNS。

默认阻断 UDP，提示 QUIC 应回退 TCP；不是完整泄漏防护或杀开关保证。上游 API Hook 不保证兼容受保护进程、提权边界、所有网络栈或反作弊应用；不得禁用安全软件或规避系统保护。

## 验证边界

不在此 Linux 执行 Windows 注入/证书/代理系统变更。Flutter SDK 引导的依赖安装被安全审查拒绝：调用触发对云元数据地址 `169.254.169.254` 的请求，可能暴露实例凭据。没有重试该网络操作或绕过。可继续使用已下载的离线工具进行格式/可移植测试；完整 Flutter 和 Windows 构建/运行验收单独记录。

## 原生 companion 的实现状态

`windows/proxylane_bridge` 使用固定上游ABI头文件，承载真正的同一个IGlobalProxy实例及其启动的新x64根进程。stdio仅接受继承匿名管道、随机会话token、单调请求ID和严格命令/字段白名单；不开放网络控制端口。Dart客户端支持分帧、超时、消息大小/并发限制，不自动重试状态不确定的启动操作。后端启动期间临时job用于回收尚未正常开始的自有目标；稳定运行后不以job结束正常应用。

高级页从该实例取得实际状态、日志、监视/录制/回放/CA响应。证书初始化、当前用户信任与移除分别确认，不以解密开关代替信任授权。未编译/运行Windows代码，不能声称完整迁移已验收。原生bridge缺失时兼容CLI会话不能进入原生高级页；明确标记而不伪造功能。

根Windows CMake可显式设置 `FLCLASH_BUILD_PROCESS_PROXY_BRIDGE=ON` 与 `PROXYLANE_SOURCE_DIR`；默认关闭直到Windows验收。亦可单独构建companion并将EXE和许可证放在FlClash程序旁。构建时只读取固定上游源代码，不打包其Hook二进制。
