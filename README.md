# Flclash-Jing

[English](docs/process-proxy/README.en.md) · [上游 FlClash](https://github.com/chen08209/FlClash) · [上游 ProxyLane](https://github.com/threatexpert/ProxyLane)

基于 FlClash **v0.9.2** 的 Windows 优先实验性改造：在侧栏增加「进程代理」，使用当前 FlClash 本地代理监听端口，让明确选择的新启动应用及子进程使用当前节点/规则，而不用开启系统代理或 TUN。

> **开发中，尚未完成 Windows 构建与真实流量验收，不是正式可用发行版。**
> 不把「已启动后端」当作「已验证目标流量被代理」。高级原生迁移正在实现；完整状态见[能力矩阵](docs/process-proxy/CAPABILITIES.md)。

## 已实现的源代码

- 原生 FlClash 风格 Windows 菜单、进程及已安装 EXE 搜索、参数/工作目录、直连规则、子进程/DNS/UDP选项。
- 多配置命名/管理、严格JSON导入预览与默认省略参数的导出；不会因导入或选中配置自动启动程序。
- 首页已启动、核心连接、安全模式、系统代理/TUN与配置应用状态门禁；读取真实配置端口，不固定 7890。
- 本地 SOCKS5/HTTP 监听探测；用户提供的 ProxyLane v1.3.5 组件按会话隔离，不覆盖其原安装配置。
- 实验性本地 stdio companion 协议与原生高级工作区；同一后端会话承载监视、解密、录制、回放与证书操作，无网络控制端口。
- 解密、QUIC 解密、监视、录制默认关闭；QUIC首次注入准备须单独确认，证书操作必须另行确认，不自动安装、不降低上游证书校验。
- 真实缓存 Raw/Hex/DNS/DoH 预览、只读离线回放；索引恢复与同会话TCP连接重建均是独立明确动作，不伪造成功或自动重试。

## 开发与验证

先阅读[架构与安全边界](docs/process-proxy/ARCHITECTURE.zh-CN.md)和[验证记录](docs/process-proxy/VALIDATION.md)。保留上游 Flutter 3.47.6 工具链要求。

```sh
flutter pub get
dart run intl_utils:generate
flutter analyze --no-fatal-infos
flutter test test/services/process_proxy_policy_test.dart test/services/process_proxy_backend_test.dart test/services/process_proxy_bridge_test.dart
```

新增 ARB 尚需正式生成本地化代码；当前开发环境依赖引导被安全审查阻止，因此**未宣称 Flutter/Windows 编译通过**。可移植纯 Dart 检查不替代完整 Flutter 或 Windows 测试。

Windows companion 构建见 `windows/proxylane_bridge/README.md`。不分发 ProxyLane 二进制，用户需要自行取得官方完整 v1.3.5 安装；后端版本不匹配时拒绝启动。默认构建没有 companion 时只提供明确标记的兼容启动路径，不视为全功能原生集成完成。

## 重要限制

- IP/CIDR规则不等同于「解析后IP策略」：上游有域名时优先按域名匹配；公司内网域名请单独添加。默认本地 DNS，不把私有 DNS 强制重定向到公共解析器。
- 进程搜索是为新启动选择路径，不是自动接管现有进程。浏览器可能复用旧的未代理实例，需自行完全退出后重试。
- 应用遵循 FlClash 当前规则/策略组。规则模式不意味着所有目的地都强制走同一个节点；本功能不擅自改变模式或节点。
- API Hook 不是安全隔离/泄漏防护保证；不承诺兼容受保护进程、反作弊程序或提权边界。不要关闭安全软件来绕过限制。
- macOS 不在本次实现范围。Windows 专用注入能力不可以直接移植到 macOS。

## 许可证

本项目继续使用 [GPL-3.0](LICENSE)，保留 FlClash 原有版权与许可证。ProxyLane 顶层 MIT 与其第三方声明分开审阅；本仓库不包含其 Hook 实现或预编译组件。[上游原 README](docs/process-proxy/UPSTREAM_README.en.md)。
