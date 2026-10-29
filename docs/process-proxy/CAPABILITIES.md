# 能力矩阵 / Capability matrix

`源代码已实现` ≠ `Windows 实测通过`。所有 Windows runtime 行均待平台验收。

| ProxyLane 能力 | Flclash-Jing 对应 | 边界 / Status |
|---|---|---|
| 单程序启动、子进程代理 | 原生启动表单 + 同会话 stdio broker；无broker时兼容CLI | 已有源码；native 初期 x64 目标，兼容CLI支持上游32/64位 |
| 应用/进程选择 | 当前会话运行进程搜索、路径选择 | 只读 App Paths/开始菜单 EXE 索引，保留参数与cwd；不自动附着现有进程，不支持UWP/脚本 |
| SOCKS5/HTTP、本地端口与认证 | 当前 FlClash 配置 + 协议探测 | 不是固定7890；认证不写入原安装配置 |
| 目标/私网直连 | 原生规则输入、IPv4 CIDR有限展开、域名 | 上游域名优先；不安全表达明确拒绝 |
| DNS、TCP/UDP、子进程开关 | 原生设置 | 默认本地DNS/UDP阻断；私有DNS不重定向 |
| HTTPS/QUIC 解密 | 原生高级页 + 同进程API bridge | 默认关闭；QUIC需启动前单独确认准备，监视解密再要求可信CA；未运行Windows验证 |
| CA 状态/初始化/信任/移除 | 原生高级页、current-user限定、单独确认 | 不随启动自动操作 |
| 流量会话、详情、缓存 | 原生高级页真实query结果 | 真实缓存正文/流数据 Raw/Hex 与DNS/DoH预览、运行/缓存ID、失效/截断状态；HTTP重建头/UDP包边界丰富详情仍需细化 |
| 录制/停止/离线回放 | 同会话原生高级页 + allowlist命令 | 目录由用户指定；启动需确认；不自动上传 |
| 录制索引恢复 | 独立确认的rebuild命令 | 仅停止监视/关闭回放后；写索引，不重发请求 |
| 既有TCP连接重建 | 本会话快照→计数确认→一次性操作 | 含直连绕过连接，可能中断上传；不保证应用重连，UDP不受影响 |
| 目标include/子进程路径过滤 | 原生目的地白名单 + 子路径include/exclude | bypass始终优先；未命中目标直连非阻断；排除子进程也切断其后代自动继承，根进程不受过滤 |
| 跳过上游证书校验 | 不暴露危险选项 | 保持验证开启，不能通过通用query绕过 |
| 运行日志、状态 | 原生高级页 status/logs | 真实后端响应，不推测成功 |
| 多配置管理/导入/导出 | 原生多配置、严格版本化JSON导入/导出 + 独立会话 | 32条/256KiB上限；导入预览确认不启动；导出默认移除所有参数；不兼容上游原生INI分享格式 |
| 加密上游GONC TLS-PSK | 本地FlClash模式明确不兼容 | 不向普通本地监听发送PSK握手，不私自绕过节点改走远端 |
| 全功能原生界面迁移 | 进行中 | 不能把原生窗口交接算完成 |

The full upstream feature surface is **not yet completely migrated**. This matrix distinguishes implemented source, disabled-by-default features, compatibility paths and genuine remaining gaps. No Windows runtime row has been signed off.
