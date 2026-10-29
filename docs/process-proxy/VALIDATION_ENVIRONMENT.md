# 验证环境说明 / Validation environment

## Flutter安全引导（2026-10-28）

最初Flutter引导触发云元数据地址请求，被审查拒绝，未向该地址重试。后来只读定位官方Flutter 3.47.6源码：

- `packages/flutter_tools/lib/src/base/bot_detector.dart:27–80`：没有明确CI标志时回落Azure检测。
- `:91,106`：Azure检测地址为`169.254.169.254/metadata/instance`。
- 同一函数`:45–50`支持`BOT=true`/`CI`并在调用AzureDetector前短路。
- `base/config.dart:195–207`官方支持`XDG_CONFIG_HOME`；它优先于HOME。

依据此新证据，经父任务审查，采用正常官方CI模式并将新配置/缓存限定在可写工作区。没有更换网络路由、代理、认证或访问元数据。第一次新尝试成功构建工具，但因遗留XDG位置不可写而停止；随后将XDG限定工作区，主项目`pub get`成功。

```bash
export BOT=true CI=true
export HOME=/workspace/scratch/08615a56c60e/toolchains/offline-home
export XDG_CONFIG_HOME="$HOME/.config"
export PUB_CACHE=/workspace/scratch/08615a56c60e/toolchains/pub-cache
export PATH=/workspace/scratch/08615a56c60e/toolchains/flutter/bin:$PATH
flutter --suppress-analytics pub get
```

本地生成与focused Flutter测试时，临时将两个`build_assets`改为false，避免构建/装载Go与Rust原生组件；shell EXIT trap恢复原始pubspec，生产配置始终保留true。不会启动FlClash应用或真实ProxyLane。官方Core子模块只拉取锁定commit `c5062921054902b25215a6a933e72ccd714c9bfa`以提供仓库声明的CA asset，未运行其代码。

Logs are kept outside the public source tree under `flclash-validation/`: `flutter-pub-get.log`, `flutter-pub-get-scoped.log`, `localization.log`, `analyze.log`, and `flutter-focused-tests.log`. Final pass/fail results belong to [VALIDATION.md](VALIDATION.md), not inferred from tool startup.

## Native compile-only cross-check

An independent read-only review acquired official Debian 13 MinGW GCC14 packages via the signed InRelease → package SHA256 chain, extracted only into the workspace. The production bridge at `fe0882a` passed x64 Win32 syntax checking and emitted a COFF relocatable object; no link or PE execution occurred. `_M_X64` was explicitly defined only to identify the x64 cross-target; this does **not** establish MSVC ABI compatibility, a Windows application build, or injection/certificate/recording behavior. Native source hashes and compiler logs remain in `toolchains/mingw-debian13/` outside the source archive.
