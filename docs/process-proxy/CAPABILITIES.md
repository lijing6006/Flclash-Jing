# 能力矩阵 / Capability matrix

`源代码已实现` ≠ `Windows 实测通过`。所有 Windows runtime 行均待平台验收。

| ProxyLane 能力 | Flclash-Jing 对应 | 边界 / Status |
|---|---|---|
| 单程序启动、子进程代理 | 原生启动表单 + 同会话 stdio broker；无broker时兼容CLI | 已有源码；native 初期 x64 目标，兼容CLI支持上游32/64位 |
| 应用/进程选择 | 当前会话运行进程搜索、路径选择 | 不自动附着现有进程；安装应用目录索引尚未迁移 |
| SOCKS5/HTTP、本地端口与认证 | 当前 FlClash 配置 + 协议探测 | 不是固定7890；认证不写入原安装配置 |
| 目标/私网直连 | 原生规则输入、IPv4 CIDR有限展开、域名 | 上游域名优先；不安全表达明确拒绝 |
| DNS、TCP/UDP、子进程开关 | 原生设置 | 默认本地DNS/UDP阻断；私有DNS不重定向 |
| HTTPS/QUIC 解密 | 原生高级页 + 同进程API bridge | 默认关闭，需显式开始监视与可信CA；未运行Windows验证 |
| CA 状态/初始化/信任/移除 | 原生高级页、current-user限定、单独确认 | 不随启动自动操作 |
| 流量会话、详情、缓存 | 原生高级页真实query结果 | 无假图表；丰富协议表格/Raw/Hex交互仍需细化 |
| 录制/停止/离线回放 | 同会话原生高级页 + allowlist命令 | 目录由用户指定；启动需确认；不自动上传 |
| 运行日志、状态 | 原生高级页 status/logs | 真实后端响应，不推测成功 |
| 多配置管理/导入/导出 | 当前配置保存 + 独立会话 | 上游完整多profile管理/分享格式未迁移 |
| 加密上游GONC TLS-PSK | 上游组件保留在用户安装/兼容路径 | 本项目固定本地FlClash，不实现独立远端PSK配置 |
| 全功能原生界面迁移 | 进行中 | 不能把原生窗口交接算完成 |

The full upstream feature surface is **not yet completely migrated**. This matrix distinguishes implemented source, disabled-by-default features, compatibility paths and genuine remaining gaps. No Windows runtime row has been signed off.
