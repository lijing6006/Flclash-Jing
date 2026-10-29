# 源码包 / Source archive

交付ZIP来自明确Git提交的受版本控制文件，不含`.git`、工具缓存、依赖安装目录、`.env`、用户配置、会话数据、真实录制或ProxyLane二进制。源码包另外排除上游既有的`windows/EnableLoopback.exe`（预编译辅助工具），不修改Git仓库中的上游文件。归档清单记录所有省略项与子模块锁定版本。

Git子模块不会被普通源码ZIP展开。已知CA asset与Core源码来自官方锁定子模块，归档使用者须自行取得（或改用授权后的Git仓库克隆）：

```sh
git clone --no-checkout https://github.com/chen08209/Clash.Meta.git core/Clash.Meta
git -C core/Clash.Meta checkout c5062921054902b25215a6a933e72ccd714c9bfa
```

其后遵循上游Flutter 3.47.6/Go/Rust工具链说明。Windows正式打包需要独立审查、构建或取得上游辅助工具；本源码包不是完整Windows安装包。ProxyLane源码接口pin及companion构建见`windows/proxylane_bridge/README.md`，后端仍由使用者单独提供。

The source archive is not a Windows installer or a complete offline dependency bundle. It preserves GPL and bridge/upstream notices, excludes prebuilt executables, and declares the pinned submodule rather than silently fetching or embedding it. The public repository's CI and Windows runtime validation remain separate from these local source checks.
