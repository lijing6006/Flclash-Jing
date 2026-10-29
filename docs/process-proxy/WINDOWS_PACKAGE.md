# Windows 应用包 / Windows application package

## 下载与启动

[Releases](https://github.com/lijing6006/Flclash-Jing/releases) 中的
**Windows x64 preview** 是实验性便携包。只有完整 Windows 构建与产物检查成功后才发布；
以前的 Process proxy validation 绿灯不代表已经生成主程序。

下载名称含 **windows-x64-preview** 的 ZIP，完整解压到可写目录后运行
**FlClash.exe**。必须保留同目录 DLL、Core、Helper、companion 和 data 文件夹；
单独下载/复制一个 EXE 不能运行 Flutter 桌面程序。另一个 source ZIP 是源码，不是应用。
本包未签名，不是安装器，不会因解压安装服务或证书。不要为了运行而关闭安全软件。
上游应用可能使用相同配置/服务标识；请先备份现有配置，不要并行运行两个版本。

包内含完整 Flutter release 主程序、源码构建的 Go Core、Rust Helper/native library、
MSVC runtime，以及源码构建的 FlClashProxyBridge.exe。
CI 不启动主应用、Core、Helper 或 bridge，不执行注入/截流、证书或系统网络配置。
因此编译成功仍**不等于真实 Windows 进程流量验收**。

## 仍需外部后端

进程代理需要用户自行取得并明确选择官方 **ProxyLane v1.3.5** 完整安装。
当前适配器要求 ProxyLane.exe、ProxyLane64.exe、ProxyLaneHook32.dll 和
ProxyLaneHook64.dll；高级监视/解密/录制/回放还需 ProxyLaneMitm64.dll。
本发行包**不包含上述后端**，不会静默下载/执行安装器。
GONC SecureTransport 与普通 FlClash 本地代理监听不兼容，不会改接其他远端代理。

上游顶层 MIT 不足以替代逐文件审阅：固定版本 Hook/asynsocket/CBase64Coding.cpp
含 GPL-2.0-or-later 与旧 WFC 源码出售限制文字，AsyncSocketEx 亦有额外条款。
这些嵌入来源的兼容性/再分发许可尚未解决；不是断言上游违法。
所有后端均存在源码构建定义，但 C++ 部分依赖旧 v141_xp/MFC/Windows 7.1A SDK；
“可编译”不等于“已解决再分发许可”。这里不编译分发这些 Hook 源。
仅 companion 使用已审阅 ABI 头与 nlohmann JSON，保留 GPL 与两个第三方声明。

继承的可选 **EnableLoopback.exe** 没有可确认的邻接源码/再分发许可，本次二进制包将其排除；
源码仓库不修改该上游文件；CMake 在它缺失时允许跳过这一个可选复制规则，保证不含该文件的源码包仍可构建。UWP loopback 辅助按钮在本包不可用，选定 Win32 EXE
的进程代理不依赖它。不要把缺少该辅助工具误认为进程代理后端缺失。

HTTPS/QUIC 解密、监视、录制仍默认关闭；QUIC 准备和证书创建/信任/删除分别确认。
停止会话不保证卸载目标内 Hook 或恢复直连；保存工作后手动重启目标才能获得干净进程。

## 构建与复核

唯一发布流程为 .github/workflows/windows-package.yaml；仅 main 构建成功后发布
不可变 commit/run-ID 的 prerelease，不写回源码、不改现有 tag、不覆盖旧资产。
构建 job 只读；单独的发布 job 只有 contents:write，使用 GitHub 的短期内建 token，
没有发布/部署私钥。上游 Telegram、Homebrew、Fdroid 流程继续禁用。

工具链与上游一致：Flutter 3.47.6、Go 1.27.1、Rust 1.99.0、Windows 2022 x64/MSVC。
保留两个 build_assets:true。锁定 pubspec.lock 并初始化精确 Core 子模块，
执行 flutter analyze、flutter build windows --release --dart-define=APP_ENV=pre；
companion 依据固定 ProxyLane c95248ac8cc790efe0ebaa37383b1008e42c78ce 接口源码构建。
不会替换/修改系统或应用信任仓库，Core 内原有公共根证书资源只是打包资源。

tool/package_windows.py 验证主 EXE/Core/Helper/bridge/Flutter 引擎的 x64 PE 标记，
校验 Rust DLL、AOT/assets/MSVC runtime 均存在，拒绝后端 INI/Hook/MITM/私钥/录制；
生成逐文件 SHA256 manifest，重新读取 ZIP 校验 CRC 和内容哈希。
这不是数字签名或实际应用启动测试。纯打包策略测试可用 Python unittest 执行。

同一 Release 附项目源码 ZIP（包含精确 Core 子模块源）和 dependency-source ZIP，
后者保存锁定 Go/Rust vendored 源、实际 Dart/Flutter framework 包、5 个 ABI 头与 nlohmann，
并把依赖许可/NOTICE/COPYING 收集到应用 licenses/dependencies，继承字体的 OFL/Apache/CC-BY 声明位于 licenses/fonts。SDK/engine 的固定源码版本
另记于 DEPENDENCIES.json；构建脚本、锁文件与再生成说明一同保留。
不包含个人配置、秘密或实际流量。SHA256SUMS 可校验应用、源码与 manifest。
完整能力边界仍见 [能力矩阵](CAPABILITIES.md)。

## English

Download the **windows-x64-preview ZIP**, extract it completely, and run **FlClash.exe**.
This is the real Flutter desktop application plus Go/Rust components and the compiled stdio
companion, not a bridge-only executable. DLLs and the data directory must stay beside the app.
The source ZIP is not runnable. The portable package is unsigned and experimental, not an
installer or evidence of live process-proxy acceptance testing. Back up existing FlClash settings;
upstream identities may share configuration/services, so do not run both versions concurrently.

The user-selected official ProxyLane 1.3.5 backend remains an external requirement.
Embedded upstream socket-source licensing is unresolved despite the top-level MIT license;
no Hook/MITM/backend binary is redistributed. The separately compiled companion carries its
GPL source and MIT/nlohmann notices. The inherited optional EnableLoopback utility is omitted
because redistribution provenance is unverified; its UWP helper action is unavailable.

CI builds the actual release app without running it or performing injection, certificate,
service or network changes. It checks required x64 PE components, native/runtime assets and
archive hashes, then publishes an immutable prerelease only from main. Build permissions are
read-only; only the isolated release job can write release assets. A separate dependency-source ZIP contains
resolved Go/Rust/Dart/Flutter framework sources and the audited ABI headers; dependency notices
are retained in the binary bundle. SDK/engine source revisions and regeneration instructions are recorded. No signing key or deployment
secret is used. Recording/decryption remain opt-in; stopping a session does not remove target
hooks or guarantee clean direct access. See the capability matrix for remaining limitations.
