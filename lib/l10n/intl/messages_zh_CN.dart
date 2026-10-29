// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(count) => "已选 ${count}";

  static String m1(name) => "已将 ${name} 添加到本地代理";

  static String m2(name) => "本地代理中已有 ${name}";

  static String m3(count, skipped) => "将添加 ${count} 项，跳过 ${skipped} 项已存在";

  static String m4(detail) => "清除数据失败：${detail}";

  static String m5(code) =>
      "Windows 拒绝运行 FlClashCore.exe（错误 ${code}）。智能应用控制、AppLocker 等应用控制策略会拦截未签名程序，请在该策略中放行 FlClash 或关闭策略后重试。";

  static String m6(name) =>
      "应用连续两次未能完成启动。为打断崩溃循环，已取消选中配置 ${name}，并跳过本次自动配置，你可以随时重新选中它。";

  static String m7(url) => "是否要通过 ${url} 创建配置？";

  static String m8(count, label) =>
      "${Intl.plural(count, other: '自定义配置不支持子规则，已丢弃 ${label} 条 SUB-RULE 规则')}";

  static String m9(message) => "内核无法解析该代理：${message}";

  static String m10(proxy, target) =>
      "${proxy} 经 ${target} 拨号，而 ${target} 又会回到 ${proxy}，形成环路";

  static String m11(name) => "名称 ${name} 已被其他代理或策略组使用";

  static String m12(path) => "策略组之间存在循环引用：${path}";

  static String m13(name) => "空组兜底只能是代理，${name} 不存在或是策略组";

  static String m14(name, message) => "${name}不是有效的正则：${message}";

  static String m15(name) => "拨号代理 ${name} 不存在";

  static String m16(names) => "以下代理集不存在：${names}";

  static String m17(names) => "以下代理或策略不存在：${names}";

  static String m18(name) => "${name} 是内置策略名，不能在此使用";

  static String m19(count) => "${count} 项存在问题，应用配置可能失败";

  static String m20(count) => "${count} 天前";

  static String m21(count) => "${count} 天前";

  static String m22(label) => "确定删除选中的${label}吗？";

  static String m23(label) => "确定删除当前${label}吗？";

  static String m24(label) => "${label}详情";

  static String m25(name) => "经 ${name} 拨号会绕回使用它的代理，连接已中止";

  static String m26(label) => "${label}不能为空";

  static String m27(label) => "${label}当前已存在";

  static String m28(count) => "${count} 项失败";

  static String m29(label, message) => "${label}：${message}";

  static String m30(name) => "${name} 已是最新版本";

  static String m31(name) => "${name} 已更新";

  static String m32(count) => "${count} 个";

  static String m33(count) => "${count} 超时";

  static String m34(action) => "已被“${action}”使用，保存后将移到这里";

  static String m35(modifiers) => "至少包含 ${modifiers} 中的一个";

  static String m36(count) => "${count} 小时前";

  static String m37(count) => "${count} 小时前";

  static String m38(target) => "${target} 是一个无效的策略";

  static String m39(proxyName) => "${proxyName} 是一个无效的代理";

  static String m40(providerName) => "${providerName} 是一个无效的代理集";

  static String m41(ruleSet) => "${ruleSet} 不是有效的规则集";

  static String m42(subRule) => "${subRule} 是一个无效的SUB_RULE";

  static String m43(count) => "${count} 项";

  static String m44(line, message) => "第 ${line} 行：${message}";

  static String m45(appName) =>
      "1. 打开 系统设置 > 隐私与安全性\n2. 选择 定位服务\n3. 在右侧列表中找到并勾选 ${appName}\n\n完成设置后，返回应用即可正常使用。感谢您的配合。";

  static String m46(label, max) => "${label}最多${max}个字符";

  static String m47(size) => "已释放 ${size}";

  static String m48(count) => "${count} 分钟前";

  static String m49(count) => "${count} 分钟前";

  static String m50(count) => "${count} 个月前";

  static String m51(count) => "${count} 个月前";

  static String m52(code) => "服务器拒绝访问（HTTP ${code}），链接可能已过期或凭据有误";

  static String m53(code) => "服务器拒绝了请求（HTTP ${code}）";

  static String m54(code) => "该地址下没有内容（HTTP ${code}），请确认链接是否正确";

  static String m55(detail) => "网络请求失败：${detail}";

  static String m56(code) => "服务器出现问题（HTTP ${code}），请稍后再试";

  static String m57(label) => "暂无${label}";

  static String m58(label, min, max) => "${label}必须在 ${min} 到 ${max} 之间";

  static String m59(label) => "${label}必须为数字";

  static String m60(label) => "${label} 必须在 1024 到 49151 之间";

  static String m61(port) => "端口 ${port}";

  static String m62(action) =>
      "对当前会话执行“${action}”？监视与录制内容可能包含凭据或隐私。关闭本页面不会停止已启用的采集。";

  static String m63(action) =>
      "确认仅为当前 Windows 用户执行“${action}”？此操作会改变本地 CA 材料或信任状态，应用可能需要重新连接；不会修改计算机级证书库。";

  static String m64(application) =>
      "启动 ${application} 的新实例？请先保存工作并自行退出已运行的同一程序。单实例应用可能复用旧的未代理进程；不会自动终止任何现有进程。";

  static String m65(rule) => "此 CIDR 无法安全转换为当前后端规则：${rule}。请使用精确 IP 或受支持的网段前缀。";

  static String m66(rule) =>
      "IP / 域名规则无效：${rule}。每行填写一个 IP、支持的 CIDR 或域名模式，不要输入 URL 或端口。";

  static String m67(error) => "操作失败：${error}";

  static String m68(count) => "后端报告的数据报数：${count}";

  static String m69(number, offset, length) =>
      "数据报 ${number}：偏移 ${offset}，${length} 字节";

  static String m70(length) => "只读前缀最多 ${length} 字节；范围和方向已锁定。";

  static String m71(count) =>
      "添加以下 ${count} 个配置？保留现有配置，名称或 ID 冲突会拒绝导入，不会启动程序。请核对下方可执行文件路径。";

  static String m72(name) => "将“${name}”加载到启动表单？不会启动任何程序，并会清除后端信任及敏感功能授权。";

  static String m73(count) =>
      "将断开本会话选中的 ${count} 条现有 TCP 连接（包含绕过直连），可能中断上传或会话。应用需自行重连，不保证成功；UDP 不受影响。是否继续？";

  static String m74(start, end, total, all) =>
      "匹配记录 ${start}–${end} / ${total}（录制总计 ${all} 条）";

  static String m75(count) => "录制警告：${count}";

  static String m76(days) => "剩余 ${days} 天";

  static String m77(date, days) => "${date} 到期，剩余 ${days} 天";

  static String m78(time) => "更新于 ${time}";

  static String m79(label, profiles) =>
      "${label} 仍被 ${profiles} 使用，删除后这些配置会异常。确定删除吗？";

  static String m80(count, label) =>
      "${Intl.plural(count, other: '${label} 个代理')}";

  static String m81(name, count) => "${name} 等 ${count} 个代理";

  static String m82(removed) =>
      "以下代理将被删除：${removed}。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？";

  static String m83(removed, added) =>
      "以下代理将被删除：${removed}。以下代理将新增：${added}。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？";

  static String m84(label) =>
      "${label} 仍被当前配置的规则、策略组、拨号代理、DNS 或 NTP 引用，删除后这些引用会失效。确定删除吗？";

  static String m85(count, label) =>
      "${Intl.plural(count, other: '${label} 个策略组')}";

  static String m86(count, label) =>
      "${Intl.plural(count, other: '${label} 条规则')}";

  static String m87(appName) => "${appName}（安全模式）";

  static String m88(count) => "${count} 秒";

  static String m89(count) => "${count} 项生效";

  static String m90(count) => "${count} 项异常";

  static String m91(count) => "${count} 项设置";

  static String m92(link) => "无法从 ${link} 中读取代理";

  static String m93(label) => "${label}只能是一项";

  static String m94(value) => "峰值 ${value}";

  static String m95(value) => "累计 ${value}";

  static String m96(transport) => "${transport} 请求头";

  static String m97(label) => "${label}必须为URL";

  static String m98(count) => "${count} 年前";

  static String m99(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "accessControl": MessageLookupByLibrary.simpleMessage("访问控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "只允许选中应用进入VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "访问控制决定哪些应用使用代理。",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "应用访问控制已关闭",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "选中应用将会被排除在VPN之外",
    ),
    "accessControlSelectedCount": m0,
    "account": MessageLookupByLibrary.simpleMessage("账号"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("测试全部延迟"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("直连模式"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("全局模式"),
    "actionMode": MessageLookupByLibrary.simpleMessage("切换模式"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("规则模式"),
    "actionStart": MessageLookupByLibrary.simpleMessage("启动/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("更新全部配置"),
    "actionView": MessageLookupByLibrary.simpleMessage("显示/隐藏"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("添加代理"),
    "addFilters": MessageLookupByLibrary.simpleMessage("添加筛选"),
    "addNodes": MessageLookupByLibrary.simpleMessage("添加节点"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("添加覆写项"),
    "addProfile": MessageLookupByLibrary.simpleMessage("添加配置"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("添加策略组"),
    "addRule": MessageLookupByLibrary.simpleMessage("添加规则"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("添加设置项"),
    "addSsid": MessageLookupByLibrary.simpleMessage("添加SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage("添加到本地代理"),
    "addedRules": MessageLookupByLibrary.simpleMessage("附加规则"),
    "addedToLocalProxies": m1,
    "additionalParameters": MessageLookupByLibrary.simpleMessage("附加参数"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("名称前缀"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("名称后缀"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV服务器地址"),
    "addressTip": MessageLookupByLibrary.simpleMessage("请输入有效的WebDAV地址"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("进阶配置"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "进阶配置包含网络、DNS、附加规则与脚本。",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("配置已加密"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 私钥"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "该配置已用 age 加密，需要 age 私钥才能解密",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage("全部被引用的代理"),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "全部被引用的代理集",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage("允许应用绕过VPN"),
    "allowLan": MessageLookupByLibrary.simpleMessage("局域网代理"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("允许的 IP"),
    "alreadyInLocalProxies": m2,
    "answers": MessageLookupByLibrary.simpleMessage("应答"),
    "app": MessageLookupByLibrary.simpleMessage("应用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("应用访问控制"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("应用图标设计"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("暂无本地代理"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("追加系统DNS"),
    "applied": MessageLookupByLibrary.simpleMessage("已应用"),
    "applyNow": MessageLookupByLibrary.simpleMessage("立即应用"),
    "authentication": MessageLookupByLibrary.simpleMessage("认证"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "认证开启后，使用本地代理端口需要账号密码。",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "认证启用时，系统代理不生效。",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("授权"),
    "authorized": MessageLookupByLibrary.simpleMessage("已授权"),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("自动关闭连接"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "自动关闭连接会在切换代理后断开已有连接。",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("自动包含"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自启动"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自动运行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("自动运行会在打开应用时启动代理。"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("自动设置系统DNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("背景模糊"),
    "backup": MessageLookupByLibrary.simpleMessage("备份"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("备份与恢复"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "该备份来自更高版本的应用，请先更新应用再恢复",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("备份成功"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基础信息"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基础策略"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("批量添加"),
    "batchImport": MessageLookupByLibrary.simpleMessage("批量导入"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage("每行一个链接"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage("每行一项，也可用逗号分隔"),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage("每行一条，键和值之间用空格分隔"),
    "batchPreviewTip": m3,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage("每行一个URL"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "忽略电池优化可保证应用在后台运行。",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("绑定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名单模式"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("阻止连接"),
    "brightness": MessageLookupByLibrary.simpleMessage("亮度"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("排除域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "排除域名仅在系统代理启用时生效。",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage("绕过私有路由地址"),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "开启绕过私有路由地址后，局域网、回环和组播地址不经过虚拟网卡。",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("缓存"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("缓存算法"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage("缓存已损坏，是否清空？"),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("缓存大小"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "请在系统设置中允许访问相机以扫描二维码，或从相册选择二维码图片。",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage("需要相机权限"),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("相机不可用"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("取消全选"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("无法保存"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "切换代理失败，已恢复上一次的选择",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("重大变更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新功能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("问题修复"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("性能优化"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("已回滚"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("校验 TLS 证书"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "关闭证书校验后，订阅和备份可能遭中间人攻击。",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("当前应用已经是最新版了"),
    "cipher": MessageLookupByLibrary.simpleMessage("加密方式"),
    "clearData": MessageLookupByLibrary.simpleMessage("清除数据"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "将删除所有配置、设置和本地数据，随后关闭应用。重新打开即可从头开始。",
    ),
    "clearDataFailed": m4,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("清除DNS缓存"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage("清除DNS缓存失败"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("清除搜索"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage("客户端指纹"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("导出剪贴板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("剪贴板导入"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "无法复制到剪贴板，所选内容可能过大",
    ),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("关闭连接"),
    "color": MessageLookupByLibrary.simpleMessage("颜色"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("配色风格"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compact": MessageLookupByLibrary.simpleMessage("紧凑"),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage("确定要清除所有数据？"),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "确定要删除当前策略组吗？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("确定要退出当前窗口吗？"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage("确定要强制崩溃核心？"),
    "congestionControl": MessageLookupByLibrary.simpleMessage("拥塞控制"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 拥塞控制"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 拥塞控制仅在 mips 栈生效。",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("已连接"),
    "connecting": MessageLookupByLibrary.simpleMessage("连接中…"),
    "connection": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("连接统计"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "实时连接、最近请求、DNS查询",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("连接"),
    "connectivity": MessageLookupByLibrary.simpleMessage("连通性："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容不能为空"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage("控制全局附加规则"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("复制环境变量"),
    "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "core": MessageLookupByLibrary.simpleMessage("内核"),
    "coreBlockedByPolicyTip": m5,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 智能应用控制拦截了未签名的 FlClashCore.exe。请打开 Windows 安全中心 → 应用和浏览器控制 → 智能应用控制设置，选择「关闭」后重新启动 FlClash。智能应用控制关闭后无法再开启，除非重装 Windows。",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心状态"),
    "country": MessageLookupByLibrary.simpleMessage("区域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("检测到崩溃"),
    "crashDetectedTip": m6,
    "crashTest": MessageLookupByLibrary.simpleMessage("崩溃测试"),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "createProfileFromUrlTip": m7,
    "creationTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage("含启动键，不可移除"),
    "custom": MessageLookupByLibrary.simpleMessage("自定义"),
    "customColor": MessageLookupByLibrary.simpleMessage("自定义颜色"),
    "customImportDroppedSubRules": m8,
    "customIssueCoreRejected": m9,
    "customIssueDialerLoop": m10,
    "customIssueDuplicateName": m11,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("名称为空"),
    "customIssueGroupLoop": m12,
    "customIssueInvalidEmptyFallback": m13,
    "customIssueInvalidFilter": m14,
    "customIssueMissingDialer": m15,
    "customIssueMissingProviders": m16,
    "customIssueMissingProxies": m17,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "未选择任何代理或代理集，内核会拒绝该策略组",
    ),
    "customIssueReservedName": m18,
    "customIssuesSummary": m19,
    "customProfile": MessageLookupByLibrary.simpleMessage("自定义"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage("自定义配置资源"),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "自定义配置资源是你自行添加的代理、规则集、筛选与图标集，供自定义配置引用。",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("可添加"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "保存更改失败，已回滚",
    ),
    "daysAgo": m20,
    "daysAgoShort": m21,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("默认选中"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "配置必须是包含 name 和 type 的 YAML 映射",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("失败"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延迟测试"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage("延迟测试超时"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteMultipTip": m22,
    "deleteTip": m23,
    "desc": MessageLookupByLibrary.simpleMessage(
      "基于ClashMeta的多平台代理客户端，简单易用，开源无广告。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目标地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目标地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目标IP ASN"),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依赖第三方api，仅供参考"),
    "developerMode": MessageLookupByLibrary.simpleMessage("开发者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("开发者模式已启用。"),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("拨号代理"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "拨号代理为连接 NTP 服务器使用的出站。",
    ),
    "dialerProxyLoopStopped": m25,
    "direct": MessageLookupByLibrary.simpleMessage("直连"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage("禁用ICMP转发"),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "禁用 ICMP 转发后由虚拟网卡直接应答 ping，ping 将不再显示真实延迟。",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage("禁用 TCP 保持活动"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("禁用UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("已关闭"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("是否放弃更改？"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "一旦你安装、复制或使用本软件，即视为你已阅读并同意本声明的全部内容。如你不同意本声明的任何条款，请立即停止使用并卸载本软件。",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("接受声明"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "我已阅读并理解此声明",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "为确认你已知悉，请阅读以下声明并勾选下方选项：",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("确认声明"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "开发者有权随版本更新修改本声明，修改后的内容随新版本发布即生效。你在更新后继续使用本软件，即视为接受修改后的声明。",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("声明变更"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "在使用 FlClash（以下简称“本软件”）前，请仔细阅读并充分理解本声明的全部内容。点击“同意”即表示你已阅读、理解并接受以下全部条款；如不同意，请点击“退出”并停止使用本软件。",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "在适用法律允许的最大范围内，开发者及所有贡献者均不对因使用或无法使用本软件而产生的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任，包括但不限于数据丢失、设备损坏、网络异常、业务中断、利润损失或因此引起的任何法律纠纷，即使已被告知发生此类损害的可能性。",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("责任限制"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "本软件以 GPL-3.0 协议开源。你可以在遵守该协议的前提下自由使用、修改和分发本软件，但须同样以 GPL-3.0 协议开源并保留原作者的版权声明。\n\n本软件包含的第三方组件（包括 Clash.Meta 内核）分别遵循其各自的开源协议。基于本软件修改或分发的版本所产生的任何问题，与原作者无关。",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage("开源协议"),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "本软件自身不提供任何代理服务器、节点、订阅、机场或网络接入服务，也不与任何此类服务的提供者存在合作、代理或担保关系。",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "本软件不会收集或上传你的订阅地址、节点信息、配置内容、访问的网站、连接记录、流量内容和日志，这些数据仅保存在你的设备本地，开发者无法获取。\n\n本软件只会在你使用相应功能时访问外部网络，例如更新订阅时访问你提供的订阅地址、检查更新时访问 GitHub。\n\n本软件在所有平台上均未集成任何数据统计或崩溃上报服务。",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage("数据收集与隐私"),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "你应自行确认使用本软件在你所在国家或地区是合法的，并对使用本软件的全部行为及其后果独立承担法律责任。\n\n你导入的订阅、节点与配置由你自行选择和判断，其来源是否合法、内容是否安全、服务是否稳定，均由你与相关提供者自行负责。",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "用户责任",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage("在此输入上述声明"),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "与声明内容不一致",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "为确认你已知悉，请在下方输入框中完整复述以下声明：",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("复述声明"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "本软件是基于 Clash.Meta（mihomo）内核的开源网络代理客户端，仅提供配置管理、规则分流与流量转发等本地工具功能。",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage("软件性质"),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "订阅链接、配置文件、规则集、脚本、外部资源及外部链接均由第三方提供，开发者无法也不会对其合法性、准确性、安全性和可用性进行审查或担保。\n\n因使用第三方内容导致的数据泄露、财产损失、账号封禁或其他任何损失，由你与第三方自行解决，开发者不承担任何责任。",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage("第三方内容"),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "本软件仅供学习交流、技术研究等非商业用途。严禁将本软件用于任何商业目的，包括但不限于付费分发、捆绑销售、作为商业服务的组成部分或以本软件名义开展经营活动；任何商业行为均与本软件及其开发者无关。\n\n严禁将本软件用于违反你所在国家或地区法律法规的活动，包括但不限于绕过依法设置的网络访问限制、传播违法信息、实施网络攻击或侵犯他人合法权益。",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("使用限制"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "本软件按“现状”和“可用”的原则提供，不附带任何明示或默示的担保，包括但不限于适销性、特定用途适用性、不侵权以及持续可用、无错误、无安全漏洞的担保。\n\n开发者不保证本软件能满足你的需求，也不保证本软件的运行不会中断或不会出现错误。",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("无担保声明"),
    "disconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("DNS缓存已清除"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "未添加时劫持所有发往 53 端口的 DNS 请求（any:53）。",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有 URL 和文件配置的 DNS，未添加的项沿用配置自身的设置。自定义配置的 DNS 在其内容中设置。",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS查询"),
    "docked": MessageLookupByLibrary.simpleMessage("固定"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("下行带宽"),
    "duration": MessageLookupByLibrary.simpleMessage("时长"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("编辑仪表盘"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("编辑全局规则"),
    "editProxy": MessageLookupByLibrary.simpleMessage("编辑代理"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("编辑策略组"),
    "editRule": MessageLookupByLibrary.simpleMessage("编辑规则"),
    "editSsid": MessageLookupByLibrary.simpleMessage("编辑SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("编辑器不可用"),
    "elapsed": MessageLookupByLibrary.simpleMessage("耗时"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("空组兜底"),
    "emptyTip": m26,
    "en": MessageLookupByLibrary.simpleMessage("英语"),
    "enabled": MessageLookupByLibrary.simpleMessage("已开启"),
    "entries": MessageLookupByLibrary.simpleMessage("个条目"),
    "error": MessageLookupByLibrary.simpleMessage("错误"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("错误详情"),
    "es": MessageLookupByLibrary.simpleMessage("西班牙语"),
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("排除目标端口"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "发往这些目标端口的流量不经过虚拟网卡。",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("排除筛选"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("排除网卡"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "从这些网卡（如 docker0）进入的流量不经过虚拟网卡。",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("排除源端口"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "源端口为这些端口的流量不经过虚拟网卡。",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("排除SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "连接到被排除 SSID 的 Wi-Fi 时，将会自动切换应用运行状态。",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("排除用户 ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "这些用户 ID 的进程产生的流量不经过虚拟网卡。",
    ),
    "existsTip": m27,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("退出全屏"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("出口节点"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("预期状态"),
    "expireTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "extend": MessageLookupByLibrary.simpleMessage("扩展"),
    "extendMode": MessageLookupByLibrary.simpleMessage("扩展模式"),
    "extendScript": MessageLookupByLibrary.simpleMessage("扩展脚本"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "外部控制器开启后，可通过 9090 端口控制内核。",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage("外部控制器密钥"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("超大"),
    "fade": MessageLookupByLibrary.simpleMessage("淡入"),
    "failedCount": m28,
    "failedItem": m29,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP过滤"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IP过滤模式"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP 过滤模式中，blacklist 排除匹配项，whitelist 仅用于匹配项，rule 按规则匹配。",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP范围"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP范围（IPv6）"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback过滤"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage("文件有修改，是否保存修改"),
    "filter": MessageLookupByLibrary.simpleMessage("筛选"),
    "filters": MessageLookupByLibrary.simpleMessage("筛选"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找进程"),
    "floating": MessageLookupByLibrary.simpleMessage("悬浮"),
    "followProfile": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字体"),
    "fontSize": MessageLookupByLibrary.simpleMessage("大小"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("强制DNS映射"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "强制 DNS 映射对通过 DNS 映射得到域名的连接也进行嗅探。",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("强制嗅探域名"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "强制嗅探域名中的域名同样会被嗅探，其余已有域名的连接不嗅探。",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要强制重启核心吗？"),
    "fr": MessageLookupByLibrary.simpleMessage("法语"),
    "general": MessageLookupByLibrary.simpleMessage("常规"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有配置的对应设置，未添加的项沿用配置自身的设置，配置未设置时使用内核默认值。",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低内存模式"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下载"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage("前往配置附加规则"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("前往配置脚本"),
    "grid": MessageLookupByLibrary.simpleMessage("网格"),
    "groupCount": m32,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("个"),
    "groupTimeoutCount": m33,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("是否缓存修改"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("按入站用户哈希"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("健康检查"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper 服务不可用，无法启用 TUN 模式，请重新安装 FlClash。",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("十六进制"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("从列表中隐藏"),
    "hideIp": MessageLookupByLibrary.simpleMessage("隐藏 IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("隐藏密码"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage("隐藏超时代理"),
    "hopInterval": MessageLookupByLibrary.simpleMessage("跳跃间隔"),
    "host": MessageLookupByLibrary.simpleMessage("主机"),
    "hostname": MessageLookupByLibrary.simpleMessage("主机名"),
    "hotkeyConflictWith": m34,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "全局快捷键在窗口隐藏时依然生效，点击操作即可录制组合键。",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("快捷键管理"),
    "hotkeyNeedsModifier": m35,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "未能注册，可能已被其他应用占用",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursAgo": m36,
    "hoursAgoShort": m37,
    "hue": MessageLookupByLibrary.simpleMessage("色相"),
    "icon": MessageLookupByLibrary.simpleMessage("图标"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("图标记录"),
    "iconSets": MessageLookupByLibrary.simpleMessage("图标集"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "暂无图标集，可在「自定义配置资源 → 图标集」中添加",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("色块"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("隐藏"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("纯图标"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("图标链接"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage("忽略电池优化"),
    "import": MessageLookupByLibrary.simpleMessage("导入"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage("此文件不是可导入的配置"),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "导入会替换此配置现有的策略组、规则和设置",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("通过文件导入"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("从链接导入"),
    "importUrl": MessageLookupByLibrary.simpleMessage("通过URL导入"),
    "inbound": MessageLookupByLibrary.simpleMessage("入站"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("包含网卡"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "只有从包含网卡进入的流量经过虚拟网卡，设置后排除网卡不再生效。",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("包含用户 ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "只有这些用户 ID 的进程产生的流量经过虚拟网卡。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("长期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "initFailed": MessageLookupByLibrary.simpleMessage("启动失败"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "FlClash 启动时出错，无法继续运行。可以复制错误详情用于反馈；如果问题反复出现，清除数据后通常可以重新启动。",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("发起方"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("发起"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage("输入策略组名称"),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("输入规则内容"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "读取应用列表权限已被拒绝，无法获取已安装的应用。请前往系统设置手动开启。",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "当前系统在授权前不会提供已安装的应用列表，授权后即可配置分应用代理。",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要读取应用列表权限",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("已安装字体"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("智能选择"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("网卡名称"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "网卡名称为出站连接使用的网卡。",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("出站网卡"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("清空"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "internet": MessageLookupByLibrary.simpleMessage("互联网"),
    "interval": MessageLookupByLibrary.simpleMessage("间隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("内网 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("无效备份文件"),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "请输入 CIDR 格式的 IP 段，如 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP 标记不能超过 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage("请输入域名或 IP 地址"),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("不是有效的图标集"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage("不是有效的订阅链接或代理分享链接"),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "请输入地址和端口，如 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "仅支持 tcp 或 udp",
    ),
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "请输入端口或范围，如 443 或 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "该二维码不包含配置文件链接",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "请输入数字或范围，如 80 或 8000-9000，多个用 / 分隔",
    ),
    "invalidRuleSet": m41,
    "invalidSubRule": m42,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP 地址"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("滥用记录"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("代理"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("命中标记"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("组织"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage("类型查询失败"),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("优"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("等级"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("普通"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("重新查询"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("风险"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("质量"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("采用来源"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("各来源"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("出站 IP 不一致"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("无法判定类型"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("限流"),
    "ipType": MessageLookupByLibrary.simpleMessage("类型"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("商业"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("机房"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("移动网络"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("住宅"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("类型未知"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP 版本"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("开启 IPv6 后才会接收 IPv6 流量。"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "开启 IPv6 后，VPN 允许 IPv6 入站。",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6超时（毫秒）"),
    "itemsCount": m43,
    "ja": MessageLookupByLibrary.simpleMessage("日语"),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP 保持活动空闲时间"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活动间隔"),
    "key": MessageLookupByLibrary.simpleMessage("键"),
    "ko": MessageLookupByLibrary.simpleMessage("韩语"),
    "label": MessageLookupByLibrary.simpleMessage("标签"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "large": MessageLookupByLibrary.simpleMessage("大"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("上次更新"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("启动未完成"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "应用上次在启动过程中意外退出。已跳过本次自动配置，你可以手动启动重试。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "lineIssueTip": m44,
    "lineWrap": MessageLookupByLibrary.simpleMessage("自动换行"),
    "link": MessageLookupByLibrary.simpleMessage("链接"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("液态玻璃"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("监听"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("监听路由标记"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "监听路由标记仅在 Linux 生效。",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("实时连接"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中…"),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localImage": MessageLookupByLibrary.simpleMessage("本地图片"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "本地网络权限被拒绝：已改用 gvisor 栈，局域网无法访问。",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("本地代理"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置权限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置权限已被拒绝，无法获取当前 Wi-Fi 名称。请前往系统设置手动开启位置权限。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "根据系统要求，获取Wi-Fi名称需要您授予位置权限。Android 上请选择“始终允许”，否则应用在后台时无法获取 Wi-Fi 名称。",
    ),
    "locationPermissionGuide": m45,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要位置权限",
    ),
    "log": MessageLookupByLibrary.simpleMessage("日志"),
    "logLevel": MessageLookupByLibrary.simpleMessage("日志等级"),
    "logcat": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("关闭日志捕获会隐藏日志入口。"),
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("日志与诊断"),
    "logsTest": MessageLookupByLibrary.simpleMessage("日志测试"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP 回环解锁"),
    "loose": MessageLookupByLibrary.simpleMessage("宽松"),
    "matchCase": MessageLookupByLibrary.simpleMessage("区分大小写"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("匹配来源IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失败次数"),
    "maxLengthTip": m46,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("常驻内存"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("应用及共享"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("堆内存空闲"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("堆内存使用中"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage("内核未运行"),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("运行时开销"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("协程栈"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "基于进程常驻内存估算，可能与系统显示的数值不同。",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "内核与应用运行在同一进程，内核部分按运行时统计估算，其余计入应用及共享内存。",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("应用与内核占用的内存"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("内存已释放"),
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("消息测试"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("这是一条消息。"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minutes": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("单色图标"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("单色"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("底栏"),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage("请求已取消"),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "无法连接到服务器，请检查网络连接或代理设置",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "无法解析服务器地址，请确认链接正确且 DNS 可用",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("网络名称"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "请求过于频繁（HTTP 429），请稍后再试",
    ),
    "networkRequestFailed": m55,
    "networkSecret": MessageLookupByLibrary.simpleMessage("网络密码"),
    "networkServerError": m56,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("网络接管"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "请求超时，请检查网络或代理后重试",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "安全连接失败，服务器证书可能无效，或连接被拦截",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("下一个匹配"),
    "no": MessageLookupByLibrary.simpleMessage("否"),
    "noData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "noInfo": MessageLookupByLibrary.simpleMessage("暂无信息"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("不再提示"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("无网络"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("无网络应用"),
    "noResolve": MessageLookupByLibrary.simpleMessage("不解析IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("不解析主机名"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("没有匹配的结果"),
    "nodes": MessageLookupByLibrary.simpleMessage("节点"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage("该外部资源不是文本文件"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "notRunning": MessageLookupByLibrary.simpleMessage("未运行"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("当前代理组无法选中"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("同步间隔（分钟）"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "开启 NTP 后从 NTP 服务器获取时间，而非系统时钟。",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("添加一个配置文件后即可开始使用"),
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("混淆"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("混淆主机"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("混淆模式"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("混淆参数"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("混淆密码"),
    "onDemand": MessageLookupByLibrary.simpleMessage("按需运行"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "按需运行会在连上排除的 Wi-Fi 时暂停代理。",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("仅统计代理流量"),
    "optional": MessageLookupByLibrary.simpleMessage("可选"),
    "options": MessageLookupByLibrary.simpleMessage("选项"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("其他贡献者"),
    "outbound": MessageLookupByLibrary.simpleMessage("出站"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("出口"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("出站 IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("覆盖目标地址"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "覆盖目标地址使用嗅探到的域名替换原目标地址发起连接。",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("覆写项"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("解析纯IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "解析纯 IP 会嗅探只有 IP 地址的连接。",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "paste": MessageLookupByLibrary.simpleMessage("粘贴"),
    "peers": MessageLookupByLibrary.simpleMessage("初始节点"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("从相册选择"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("窗口置顶"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("请绑定WebDAV"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage("请输入脚本名称"),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "请上传有效的二维码",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("插件"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("插件加密方式"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("插件主机"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("插件模式"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("插件密码"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("插件路径"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("插件用户名"),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("请输入不同的端口"),
    "portHopping": MessageLookupByLibrary.simpleMessage("端口跳跃"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("端口"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("预共享密钥"),
    "preferred": MessageLookupByLibrary.simpleMessage("首选"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前置条件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("请按下组合键"),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("上一个匹配"),
    "privateKey": MessageLookupByLibrary.simpleMessage("私钥"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("私钥密码"),
    "process": MessageLookupByLibrary.simpleMessage("进程"),
    "processProxy": MessageLookupByLibrary.simpleMessage("进程代理"),
    "processProxyAdvanced": MessageLookupByLibrary.simpleMessage("高级能力 · 实验性"),
    "processProxyAdvancedHelp": MessageLookupByLibrary.simpleMessage(
      "HTTPS/QUIC 解密、CA 信任、监视、录制和回放尚未全部迁移到 FlClash 原生界面。默认全部关闭；修改解密选项不会安装证书或启动监视。",
    ),
    "processProxyApplications": MessageLookupByLibrary.simpleMessage("已安装应用"),
    "processProxyApplicationsHelp": MessageLookupByLibrary.simpleMessage(
      "只读搜索 App Paths 与开始菜单中的本地 EXE；保留快捷方式参数和工作目录。不会启动、附着或结束任何现有进程；不支持 UWP 或脚本。",
    ),
    "processProxyApplyCapture": MessageLookupByLibrary.simpleMessage("应用采集限制"),
    "processProxyArguments": MessageLookupByLibrary.simpleMessage(
      "启动参数（JSON 字符串数组）",
    ),
    "processProxyArgumentsHelp": MessageLookupByLibrary.simpleMessage(
      "例如：[\"--profile\", \"Work\"]。不通过 shell 执行；请勿输入密码或令牌。",
    ),
    "processProxyBackend": MessageLookupByLibrary.simpleMessage("ProxyLane 后端"),
    "processProxyBackendHelp": MessageLookupByLibrary.simpleMessage(
      "选择可信的完整 ProxyLane v1.3.5 安装。FlClash 使用隔离会话副本，不覆盖原有配置。",
    ),
    "processProxyBackendPath": MessageLookupByLibrary.simpleMessage(
      "官方 ProxyLane64.exe 路径",
    ),
    "processProxyBackendRunning": MessageLookupByLibrary.simpleMessage(
      "后端运行中，请核验流量",
    ),
    "processProxyBlockUdp": MessageLookupByLibrary.simpleMessage(
      "阻止 UDP（QUIC 在支持时回退 TCP）",
    ),
    "processProxyBypass": MessageLookupByLibrary.simpleMessage(
      "排除 IP、CIDR 和域名（每行一项）",
    ),
    "processProxyBypassHelp": MessageLookupByLibrary.simpleMessage(
      "排除目标将直连。请明确添加内网域名；仅当后端获得目标 IP 时 IP 规则才生效，域名匹配优先。",
    ),
    "processProxyCaWarning": MessageLookupByLibrary.simpleMessage(
      "不会自动安装证书。信任本地 CA 后，该 CA 可为当前用户的被代理 TLS 连接签发受信任证书。仅检查你有权检查的程序和流量。",
    ),
    "processProxyCacheId": MessageLookupByLibrary.simpleMessage("缓存 ID"),
    "processProxyCaptureOptions": MessageLookupByLibrary.simpleMessage(
      "采集限制（JSON 对象）",
    ),
    "processProxyCapturePrivacy": MessageLookupByLibrary.simpleMessage(
      "解密和录制默认关闭，仅检查您有权检查的应用流量。录制保存在您选择的本地目录，请按需保护和删除。停止监视会关闭采集和新连接解密，但已有 TLS 桥接可能持续到连接结束或您明确重连。已信任的 CA 须单独移除。重连可能中断传输，绝不会自动执行。",
    ),
    "processProxyCertificates": MessageLookupByLibrary.simpleMessage("证书"),
    "processProxyChildRuleInclude": MessageLookupByLibrary.simpleMessage(
      "仅注入匹配规则的子进程",
    ),
    "processProxyChildRules": MessageLookupByLibrary.simpleMessage(
      "子进程路径 / 名称规则",
    ),
    "processProxyChildRulesHelp": MessageLookupByLibrary.simpleMessage(
      "每行一个本机完整路径、通配模式或 EXE 文件名，最多 128 条。仅在开启子进程代理时生效；默认排除匹配子进程，开启下方开关则仅包含匹配项。留空表示所有子进程，不影响根进程。被排除的子进程不会注入，其后代也不会自动继承代理；请包含中间启动器。",
    ),
    "processProxyChildren": MessageLookupByLibrary.simpleMessage("代理子进程"),
    "processProxyClient": MessageLookupByLibrary.simpleMessage("客户端 → 服务端"),
    "processProxyCloseReplay": MessageLookupByLibrary.simpleMessage("关闭回放"),
    "processProxyConfirmAdvanced": m62,
    "processProxyConfirmCa": m63,
    "processProxyConfirmLaunch": m64,
    "processProxyCoreRequired": MessageLookupByLibrary.simpleMessage(
      "请先在首页启动 FlClash，再启动代理程序。",
    ),
    "processProxyCoreSessionEnded": MessageLookupByLibrary.simpleMessage(
      "核心状态或监听配置已变化；此进程代理会话已失效。 后端或核心停止后，注入钩子可能仍在，因此新连接可能失败。请手动重启所选应用以恢复干净状态。不会自动结束或重启应用，也不保证恢复直连或具备断网保护。",
    ),
    "processProxyDataTruncated": MessageLookupByLibrary.simpleMessage(
      "仅展示前 48 KiB。请缩小查询范围或读取其他分页获取更多数据。",
    ),
    "processProxyDatagrams": MessageLookupByLibrary.simpleMessage("数据报边界"),
    "processProxyDatagramsHelp": MessageLookupByLibrary.simpleMessage(
      "仅显示后端提供的字节偏移和长度，表示已捕获的载荷数据报，而非 IP 包或推测的边界。选择非空数据报后，再明确读取其有界前缀。",
    ),
    "processProxyDecryptHttps": MessageLookupByLibrary.simpleMessage(
      "显式开始监视后允许 HTTPS 解密",
    ),
    "processProxyDecryptQuic": MessageLookupByLibrary.simpleMessage(
      "显式开始监视后允许 QUIC 解密",
    ),
    "processProxyDirectMode": MessageLookupByLibrary.simpleMessage(
      "当前为直连模式。请先选择规则或全局模式及代理节点，再启动程序；本页不会自动修改路由模式。",
    ),
    "processProxyDirectory": MessageLookupByLibrary.simpleMessage("本地目录绝对路径"),
    "processProxyDnsHelp": MessageLookupByLibrary.simpleMessage(
      "默认关闭以保留本地及公司分流 DNS。使用本地 DNS 时查询可能对当前网络可见；不会强制重定向私有 DNS。",
    ),
    "processProxyEmptyPacket": MessageLookupByLibrary.simpleMessage(
      "零长度数据报，不读取载荷。",
    ),
    "processProxyEncryptedPayload": MessageLookupByLibrary.simpleMessage(
      "此快照为加密 TLS／QUIC 载荷，没有明文；Raw／Hex 不会对其解密。",
    ),
    "processProxyEndpoint": MessageLookupByLibrary.simpleMessage("当前本地代理端点"),
    "processProxyErrorArchitecture": MessageLookupByLibrary.simpleMessage(
      "实验性原生桥接目前仅支持 x64 根程序。请选择受支持的 x64 可执行文件；不会自动接管已有进程。",
    ),
    "processProxyErrorAuthentication": MessageLookupByLibrary.simpleMessage(
      "本地代理认证失败，请检查 FlClash 的代理用户名和密码设置。本提示不会显示凭据。",
    ),
    "processProxyErrorBackendVersion": MessageLookupByLibrary.simpleMessage(
      "请选择完整 ProxyLane v1.3.5 安装中的官方 ProxyLane64.exe；当前后端版本不受支持。",
    ),
    "processProxyErrorBridge": MessageLookupByLibrary.simpleMessage(
      "原生桥接不可用或拒绝了此操作。请核对匹配的 Windows 桥接构建与所选后端，然后重新启动会话。",
    ),
    "processProxyErrorBusy": MessageLookupByLibrary.simpleMessage(
      "已有启动任务正在进行，请等待完成后重试。",
    ),
    "processProxyErrorCaRequired": MessageLookupByLibrary.simpleMessage(
      "解密需要已初始化且经你明确同意信任的当前用户 CA。请查看“证书”页；本操作不会自动安装信任。",
    ),
    "processProxyErrorChildRule": MessageLookupByLibrary.simpleMessage(
      "子进程规则无效。每行填写本机完整路径、通配模式或 EXE 文件名；不允许 UNC、目录回溯或命令行语法。",
    ),
    "processProxyErrorCidr": m65,
    "processProxyErrorComponents": MessageLookupByLibrary.simpleMessage(
      "缺少必要的 ProxyLane 组件。请将完整官方压缩包解压到同一文件夹，再选择其中的 ProxyLane64.exe。",
    ),
    "processProxyErrorCoreChanged": MessageLookupByLibrary.simpleMessage(
      "启动过程中 FlClash 已停止或代理配置发生变化。请检查当前状态后重新启动会话。",
    ),
    "processProxyErrorDirectory": MessageLookupByLibrary.simpleMessage(
      "请使用绝对路径选择已存在的本地目录；不接受网络共享或链接。",
    ),
    "processProxyErrorExecutable": MessageLookupByLibrary.simpleMessage(
      "请选择本地存在的 .exe 文件，使用完整绝对路径；不支持快捷方式、网络路径或命令字符串。",
    ),
    "processProxyErrorGeneric": MessageLookupByLibrary.simpleMessage(
      "操作未能完成。请检查所选文件和当前核心状态后重试；可能包含敏感内容的诊断详情已隐藏。",
    ),
    "processProxyErrorHook": MessageLookupByLibrary.simpleMessage(
      "ProxyLane 无法在所选程序中初始化代理，程序可能不兼容或受到保护。请勿关闭安全防护；可改用受支持的程序。",
    ),
    "processProxyErrorListener": MessageLookupByLibrary.simpleMessage(
      "配置中的本地代理未通过协议握手。请确认 FlClash 正在运行，且 mixed、SOCKS 或 HTTP 监听已启用。",
    ),
    "processProxyErrorMonitoringActive": MessageLookupByLibrary.simpleMessage(
      "请先停止监视和录制，再修改采集限制、打开回放或变更证书信任。",
    ),
    "processProxyErrorNativeRequired": MessageLookupByLibrary.simpleMessage(
      "此选项需要 FlClashProxyBridge.exe；兼容启动器无法安全应用该选项。",
    ),
    "processProxyErrorPathLength": MessageLookupByLibrary.simpleMessage(
      "当前后端路径暂限 UTF-8 编码 240 字节，请选择更短的本地路径；中文及会话暂存路径兼容性仍需 Windows 验证。",
    ),
    "processProxyErrorProcessQuery": MessageLookupByLibrary.simpleMessage(
      "Windows 未能完成可访问进程列表查询。请重试搜索，或直接选择程序的 .exe 文件。",
    ),
    "processProxyErrorQuic": MessageLookupByLibrary.simpleMessage(
      "QUIC 解密需要 UDP，请先明确关闭“阻止 UDP”再启用此选项。",
    ),
    "processProxyErrorQuicPrepare": MessageLookupByLibrary.simpleMessage(
      "此程序启动时未预备 QUIC 检查。请自行退出程序，在重新启动前明确启用 QUIC 预备，再开启 QUIC 解密。",
    ),
    "processProxyErrorQuicSocks": MessageLookupByLibrary.simpleMessage(
      "QUIC 预备需要已运行内核的 SOCKS5 或 mixed 监听，不能仅使用 HTTP。",
    ),
    "processProxyErrorRecordingState": MessageLookupByLibrary.simpleMessage(
      "后端未确认所请求的录制状态。不要假定录制已经开始或停止。请停止此会话、检查其本地录制目录，再启动新会话后重新开启监视或录制。",
    ),
    "processProxyErrorResponseLarge": MessageLookupByLibrary.simpleMessage(
      "请求或响应超过安全大小限制。请减少记录数量、预览大小或输入长度后重试。",
    ),
    "processProxyErrorRule": m66,
    "processProxyErrorRuleLimit": MessageLookupByLibrary.simpleMessage(
      "规则列表超过限制：IP / 域名最多 512 条、子进程最多 128 条，每个列表文本最多 16 KiB。",
    ),
    "processProxyErrorSession": MessageLookupByLibrary.simpleMessage(
      "此后端会话已不可用。如需重试，请自行关闭目标程序后重新启动会话。",
    ),
    "processProxyErrorSettings": MessageLookupByLibrary.simpleMessage(
      "无法读取已保存的进程代理设置，请重新填写并保存。",
    ),
    "processProxyErrorTrust": MessageLookupByLibrary.simpleMessage(
      "请核对后端路径，并明确勾选信任此后端。",
    ),
    "processProxyErrorWindows": MessageLookupByLibrary.simpleMessage(
      "进程代理目前仅支持 Windows，并需要系统自带的本地进程查询工具。",
    ),
    "processProxyErrorWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "请使用存在的本机绝对工作目录，不支持 UNC、目录回溯或备用数据流。",
    ),
    "processProxyExited": MessageLookupByLibrary.simpleMessage("后端已退出"),
    "processProxyExperimentalHint": MessageLookupByLibrary.simpleMessage(
      "实验性：尚待 Windows 实机验证。下方只展示当前会话后端的真实响应，不使用模拟数据；仅手动刷新。",
    ),
    "processProxyFailed": m67,
    "processProxyGoncUnsupported": MessageLookupByLibrary.simpleMessage(
      "GONC TLS-PSK 加密代理入口不兼容普通本地 FlClash 监听；不会改走远端以绕过当前节点。",
    ),
    "processProxyHeaders": MessageLookupByLibrary.simpleMessage(
      "请求头／响应头（保留顺序和重复项）",
    ),
    "processProxyHeadersUnavailable": MessageLookupByLibrary.simpleMessage(
      "此快照没有可用的头部元数据。",
    ),
    "processProxyHex": MessageLookupByLibrary.simpleMessage("十六进制"),
    "processProxyInformational": MessageLookupByLibrary.simpleMessage("临时响应"),
    "processProxyInitializeCa": MessageLookupByLibrary.simpleMessage(
      "初始化 CA 材料",
    ),
    "processProxyIntro": MessageLookupByLibrary.simpleMessage(
      "仅让你启动的指定程序通过当前 FlClash 代理；保持系统代理和 TUN 关闭。",
    ),
    "processProxyInvalidArguments": MessageLookupByLibrary.simpleMessage(
      "启动参数必须是只包含字符串的 JSON 数组。",
    ),
    "processProxyJsonObjectRequired": MessageLookupByLibrary.simpleMessage(
      "请输入包含规定字段的有效 JSON 对象。",
    ),
    "processProxyLaunch": MessageLookupByLibrary.simpleMessage("启动并代理"),
    "processProxyMessageIncomplete": MessageLookupByLibrary.simpleMessage(
      "尚未确认消息完整。",
    ),
    "processProxyMonitor": MessageLookupByLibrary.simpleMessage("流量监视"),
    "processProxyNativeWorkspace": MessageLookupByLibrary.simpleMessage(
      "原生高级工作区",
    ),
    "processProxyNoData": MessageLookupByLibrary.simpleMessage(
      "尚未读取响应，请点击读取或刷新。",
    ),
    "processProxyNoPort": MessageLookupByLibrary.simpleMessage(
      "当前未启用可用的 mixed / SOCKS / HTTP 代理端口。",
    ),
    "processProxyNoProcesses": MessageLookupByLibrary.simpleMessage(
      "没有匹配且可访问的程序；也可以直接选择 .exe 文件。",
    ),
    "processProxyOffset": MessageLookupByLibrary.simpleMessage("字节偏移"),
    "processProxyOnlyRules": MessageLookupByLibrary.simpleMessage(
      "仅代理这些 IP / 域名（可选）",
    ),
    "processProxyOnlyRulesHelp": MessageLookupByLibrary.simpleMessage(
      "每行一个 IP、支持的 CIDR 或域名模式。留空表示所有目标；未匹配目标直连，绕过规则始终优先。仅当程序向后端提供 IP 时才能按 IP 匹配；内网域名请明确添加。更改于下次启动生效。",
    ),
    "processProxyOpenBackend": MessageLookupByLibrary.simpleMessage(
      "高级工作区（ProxyLane 原生窗口）",
    ),
    "processProxyOpenReplay": MessageLookupByLibrary.simpleMessage("打开录制目录"),
    "processProxyOverview": MessageLookupByLibrary.simpleMessage("概览"),
    "processProxyPacketCount": m68,
    "processProxyPacketLimit": MessageLookupByLibrary.simpleMessage(
      "每个方向仅显示前 128 条索引；可能存在更多数据报或未建立索引的数据报。",
    ),
    "processProxyPacketMetadata": m69,
    "processProxyPacketPrefix": m70,
    "processProxyPacketsUnavailable": MessageLookupByLibrary.simpleMessage(
      "后端未提供数据报索引，此处无法重建边界。",
    ),
    "processProxyPayloadDecode": MessageLookupByLibrary.simpleMessage("读取解码预览"),
    "processProxyPayloadDns": MessageLookupByLibrary.simpleMessage("解析 DNS"),
    "processProxyPayloadDoh": MessageLookupByLibrary.simpleMessage("解析 DoH"),
    "processProxyPayloadHelp": MessageLookupByLibrary.simpleMessage(
      "只读取已采集或回放数据，每次最多 64 KiB；这是正文/流数据，不是原始 HTTP/2 或 QUIC 网络帧。",
    ),
    "processProxyPayloadRead": MessageLookupByLibrary.simpleMessage("读取原始正文"),
    "processProxyPayloadUnavailable": MessageLookupByLibrary.simpleMessage(
      "正文未就绪、已被淘汰或不完整；请检查下方状态与警告。",
    ),
    "processProxyPayloadViewer": MessageLookupByLibrary.simpleMessage(
      "正文 Raw / Hex 预览",
    ),
    "processProxyPrepareQuic": MessageLookupByLibrary.simpleMessage(
      "为本次启动预备 QUIC 检查",
    ),
    "processProxyPrepareQuicHelp": MessageLookupByLibrary.simpleMessage(
      "必须在启动前单独授权，需要原生桥接、SOCKS5 且未阻止 UDP。将为该进程树预设浏览器兼容选项，持续到相关程序退出。不会开始监视、解密或安装证书。",
    ),
    "processProxyPrivate": MessageLookupByLibrary.simpleMessage("排除私有网络"),
    "processProxyProfiles": MessageLookupByLibrary.simpleMessage("启动配置"),
    "processProxyProfilesConflict": MessageLookupByLibrary.simpleMessage(
      "配置名称或 ID 重复。请重命名或移除冲突配置；未覆盖任何内容。",
    ),
    "processProxyProfilesEmpty": MessageLookupByLibrary.simpleMessage(
      "尚无启动配置。",
    ),
    "processProxyProfilesExport": MessageLookupByLibrary.simpleMessage(
      "导出启动配置",
    ),
    "processProxyProfilesExportConfirm": MessageLookupByLibrary.simpleMessage(
      "按本页“包含启动参数”选项导出明文 JSON 文件？分享前请检查路径和参数中的秘密。后端信任、代理凭据及敏感功能授权永不导出。",
    ),
    "processProxyProfilesExportHelp": MessageLookupByLibrary.simpleMessage(
      "默认导出时省略全部启动参数。路径、名称及绕过规则仍为明文。包含参数可能泄露密码或令牌，请仅保存到可信位置。",
    ),
    "processProxyProfilesHelp": MessageLookupByLibrary.simpleMessage(
      "最多在本地保存 32 个启动配置。配置及备份为明文，启动参数可能含密钥。加载仅填入表单，不启动程序，也不改变现有会话；后端信任、捕获及 QUIC 授权始终重置。",
    ),
    "processProxyProfilesImport": MessageLookupByLibrary.simpleMessage(
      "导入启动配置",
    ),
    "processProxyProfilesImportConfirm": m71,
    "processProxyProfilesIncludeArguments":
        MessageLookupByLibrary.simpleMessage("导出时包含启动参数"),
    "processProxyProfilesInvalid": MessageLookupByLibrary.simpleMessage(
      "启动配置 JSON、版本、名称或字段类型无效。现有配置未修改。",
    ),
    "processProxyProfilesLimit": MessageLookupByLibrary.simpleMessage(
      "最多允许 32 个配置，请先删除不再使用的配置。",
    ),
    "processProxyProfilesLoadConfirm": m72,
    "processProxyProfilesSaveCurrent": MessageLookupByLibrary.simpleMessage(
      "将当前表单保存为配置",
    ),
    "processProxyProfilesStorage": MessageLookupByLibrary.simpleMessage(
      "无法读取或保存本地配置文件。请检查文件权限及剩余空间后重试。",
    ),
    "processProxyProfilesTooLarge": MessageLookupByLibrary.simpleMessage(
      "配置文件不得超过 256 KiB。现有配置未修改。",
    ),
    "processProxyReadDetails": MessageLookupByLibrary.simpleMessage("读取详情"),
    "processProxyReadNext": MessageLookupByLibrary.simpleMessage("读取后续记录"),
    "processProxyReadQuery": MessageLookupByLibrary.simpleMessage(
      "只读详情查询（JSON 对象）",
    ),
    "processProxyReadQueryHelp": MessageLookupByLibrary.simpleMessage(
      "使用响应中的后端标识。支持 poll、stats、cache_read、cache_decode、dns_read、recording_page、recording_detail 等只读类型；此字段不能执行命令。",
    ),
    "processProxyRebuildIndex": MessageLookupByLibrary.simpleMessage("恢复录制索引"),
    "processProxyRebuildIndexWarning": MessageLookupByLibrary.simpleMessage(
      "只为明确选择的本地录制目录重建索引，将写入索引元数据但不重发网络请求；失败或超时不会自动重试。请确认备份，并保持监视停止。",
    ),
    "processProxyReconnect": MessageLookupByLibrary.simpleMessage(
      "重建本会话 TCP 连接",
    ),
    "processProxyReconnectConfirm": m73,
    "processProxyReconnectNone": MessageLookupByLibrary.simpleMessage(
      "本会话没有可重建的 TCP 连接。",
    ),
    "processProxyRecording": MessageLookupByLibrary.simpleMessage("录制"),
    "processProxyRecordingAll": MessageLookupByLibrary.simpleMessage("所有协议"),
    "processProxyRecordingBrowser": MessageLookupByLibrary.simpleMessage(
      "浏览离线录制",
    ),
    "processProxyRecordingBrowserHelp": MessageLookupByLibrary.simpleMessage(
      "请先在录制工作区打开本地录制目录。本页只读取该录制，不会重发已捕获请求或开始监视。设置筛选条件后点击刷新；分页使用记录偏移，不使用实时流量游标。",
    ),
    "processProxyRecordingCapacity": MessageLookupByLibrary.simpleMessage(
      "录制容量上限（MiB）",
    ),
    "processProxyRecordingChanged": MessageLookupByLibrary.simpleMessage(
      "翻页期间打开的录制已改变。旧记录已清除；请从首页刷新后再读取详情。",
    ),
    "processProxyRecordingDetails": MessageLookupByLibrary.simpleMessage(
      "录制会话详情",
    ),
    "processProxyRecordingNext": MessageLookupByLibrary.simpleMessage("下一页"),
    "processProxyRecordingNoPayload": MessageLookupByLibrary.simpleMessage(
      "此记录仅包含连接信息，没有正文缓存 ID；下方显示其元数据。",
    ),
    "processProxyRecordingPageSize": MessageLookupByLibrary.simpleMessage(
      "每页记录数",
    ),
    "processProxyRecordingPageSummary": m74,
    "processProxyRecordingPrevious": MessageLookupByLibrary.simpleMessage(
      "上一页",
    ),
    "processProxyRecordingQueryInvalid": MessageLookupByLibrary.simpleMessage(
      "筛选条件最多 256 个 UTF-8 字节且不得含控制字符；每页 1–64 条记录，记录偏移须为非负整数。",
    ),
    "processProxyRecordingReserve": MessageLookupByLibrary.simpleMessage(
      "磁盘最小保留空间（MiB）",
    ),
    "processProxyRecordingStalled": MessageLookupByLibrary.simpleMessage(
      "后端在所报总数之前返回了空页。已停止翻页，避免跳过记录或循环；请刷新或检查录制状态。",
    ),
    "processProxyRecordingWarnings": m75,
    "processProxyRefresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "processProxyRemoteDns": MessageLookupByLibrary.simpleMessage("通过代理解析公网域名"),
    "processProxyRemoveCa": MessageLookupByLibrary.simpleMessage(
      "移除当前用户 CA 信任",
    ),
    "processProxyReplay": MessageLookupByLibrary.simpleMessage("离线回放"),
    "processProxyRequested": MessageLookupByLibrary.simpleMessage("已请求启动"),
    "processProxyRules": MessageLookupByLibrary.simpleMessage("路由与排除"),
    "processProxyRunId": MessageLookupByLibrary.simpleMessage("运行 ID"),
    "processProxySafeMode": MessageLookupByLibrary.simpleMessage(
      "安全模式下禁止启动外部代理进程。",
    ),
    "processProxySearch": MessageLookupByLibrary.simpleMessage("搜索运行中的程序"),
    "processProxySearchHelp": MessageLookupByLibrary.simpleMessage(
      "选择运行进程仅填入可执行文件路径，供重新启动使用；不会接管、停止或重启该进程。",
    ),
    "processProxySearchHint": MessageLookupByLibrary.simpleMessage(
      "按名称、PID 或程序路径搜索",
    ),
    "processProxySelectFile": MessageLookupByLibrary.simpleMessage("选择可执行文件"),
    "processProxySemanticDetails": MessageLookupByLibrary.simpleMessage("协议详情"),
    "processProxySemanticHelp": MessageLookupByLibrary.simpleMessage(
      "所选运行和记录的只读快照。HTTP 字段是语义元数据，不是原始线上字节；打开此页不会读取载荷或开始采集。",
    ),
    "processProxySemanticUnavailable": MessageLookupByLibrary.simpleMessage(
      "此快照没有受支持的 HTTP 头部或数据报详情。可查看现有元数据和载荷，但不要推断应用消息边界。",
    ),
    "processProxyServer": MessageLookupByLibrary.simpleMessage("服务端 → 客户端"),
    "processProxySessionHelp": MessageLookupByLibrary.simpleMessage(
      "状态仅表示后端进程生命周期，不代表已验证程序流量。关闭页面不会结束程序。核心停止或端口变化会中断代理，请关闭目标程序后创建新会话。",
    ),
    "processProxySessionStopWarning": MessageLookupByLibrary.simpleMessage(
      "停止本会话的监视、录制和代理后端？不会结束正在运行的应用，但其代理连接可能中断。 后端或核心停止后，注入钩子可能仍在，因此新连接可能失败。请手动重启所选应用以恢复干净状态。不会自动结束或重启应用，也不保证恢复直连或具备断网保护。",
    ),
    "processProxySessions": MessageLookupByLibrary.simpleMessage("当前窗口会话"),
    "processProxyStartMonitor": MessageLookupByLibrary.simpleMessage("开始监视"),
    "processProxyStartRecording": MessageLookupByLibrary.simpleMessage("开始录制"),
    "processProxyStats": MessageLookupByLibrary.simpleMessage("流量统计"),
    "processProxyStatus": MessageLookupByLibrary.simpleMessage("后端状态"),
    "processProxyStopMonitor": MessageLookupByLibrary.simpleMessage("停止监视"),
    "processProxyStopRecording": MessageLookupByLibrary.simpleMessage(
      "停止录制和监视",
    ),
    "processProxyStopSession": MessageLookupByLibrary.simpleMessage("停止代理会话"),
    "processProxyTakeoverOff": MessageLookupByLibrary.simpleMessage(
      "请先关闭系统代理和 TUN，确保仅代理所选程序。",
    ),
    "processProxyTarget": MessageLookupByLibrary.simpleMessage("待启动程序"),
    "processProxyTargetPath": MessageLookupByLibrary.simpleMessage(
      "程序 .exe 路径",
    ),
    "processProxyTrailers": MessageLookupByLibrary.simpleMessage("尾部字段"),
    "processProxyTrust": MessageLookupByLibrary.simpleMessage(
      "我信任此后端，并授权其代理我主动启动的程序。",
    ),
    "processProxyTrustCa": MessageLookupByLibrary.simpleMessage("为当前用户信任 CA"),
    "processProxyWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "工作目录（可选）",
    ),
    "processProxyWorkingDirectoryHelp": MessageLookupByLibrary.simpleMessage(
      "填写本机绝对目录；留空时使用目标程序所在目录。指定目录需要原生桥接后端。",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("配置"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入有效间隔时间格式"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入自动更新间隔时间"),
    "profileDaysLeft": m76,
    "profileExpiresIn": m77,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已经修改，是否关闭自动更新？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置名称",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "仅作用于当前配置，未添加的项使用默认值。",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "仅作用于当前配置，并优先于网络设置中的虚拟网卡覆写项。",
    ),
    "profileUpdatedAt": m78,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入有效配置URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置排序"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "protocol": MessageLookupByLibrary.simpleMessage("协议"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("协议参数"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("协议版本"),
    "providerInUse": m79,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("仅支持远程资源"),
    "providers": MessageLookupByLibrary.simpleMessage("外部资源"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesCount": m80,
    "proxiesProfileLabel": m81,
    "proxiesRemovedTip": m82,
    "proxiesReplacedTip": m83,
    "proxyChains": MessageLookupByLibrary.simpleMessage("代理链"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("策略组"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("策略组为空"),
    "proxyGroupInUse": m84,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "启动后在这里显示策略组",
    ),
    "proxyGroupsCount": m85,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理集"),
    "proxyType": MessageLookupByLibrary.simpleMessage("代理类型"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("修剪缓存"),
    "publicKey": MessageLookupByLibrary.simpleMessage("公钥"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("纯黑"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("纯黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("二维码"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("扫描二维码获取配置文件"),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "链接过长，无法生成二维码，请改用“复制链接”。",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("快捷操作"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("快速编辑"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("最近请求"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("推荐"),
    "recordType": MessageLookupByLibrary.simpleMessage("记录类型"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir端口"),
    "redo": MessageLookupByLibrary.simpleMessage("重做"),
    "regex": MessageLookupByLibrary.simpleMessage("正则"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("释放内存"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage("释放内存失败"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("远程目标"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("远程 DNS 解析"),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "replace": MessageLookupByLibrary.simpleMessage("替换"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("全部替换"),
    "request": MessageLookupByLibrary.simpleMessage("请求"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("请求头"),
    "requests": MessageLookupByLibrary.simpleMessage("请求"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("请求与更新"),
    "required": MessageLookupByLibrary.simpleMessage("必填"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "当前页面存在更改，确定重置吗？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("确定要重置吗？"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔"),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自动更新间隔必须大于0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("资源"),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵守规则"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "遵守规则使 DNS 连接遵守规则，需配置 Proxy Server Nameserver。",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("响应码"),
    "restart": MessageLookupByLibrary.simpleMessage("重启"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要重启核心吗？"),
    "restore": MessageLookupByLibrary.simpleMessage("恢复"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("仅恢复配置文件"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("恢复策略"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("覆盖"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "result": MessageLookupByLibrary.simpleMessage("结果"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("排除路由地址"),
    "routingMark": MessageLookupByLibrary.simpleMessage("路由标记"),
    "ru": MessageLookupByLibrary.simpleMessage("俄语"),
    "rule": MessageLookupByLibrary.simpleMessage("规则"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("匹配完整域名"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名关键字",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用域名正则表达式匹配",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名后缀",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "匹配DSCP标记（仅限 tproxy udp 入站）",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage("匹配请求目标端口范围"),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所属国家代码"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Geosite 内的域名",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("匹配入站名称"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage("匹配入站端口"),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage("匹配入站类型"),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "匹配入站用户名，支持使用 / 分隔多个用户名",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所属 ASN"),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 地址范围，IP-CIDR6 只是一个别名",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 地址范围"),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 后缀范围",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage("匹配所有请求，无需条件"),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage("匹配TCP或者UDP"),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程匹配，在Android平台可以匹配包名",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程名称正则表达式匹配，在Android平台可以匹配包名",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程名称通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "使用完整进程路径匹配",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程路径正则表达式匹配",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程路径通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "匹配重匹配名称，多个名称用/分隔",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "引用规则集合，需配置rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 所属国家代码",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 所属 ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 地址范围",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 后缀范围",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage("匹配请求来源端口范围"),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "匹配至子规则，需要注意括号的使用",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("规则为空"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "规则必须是 YAML 列表，每项一条规则，例如 - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BT 下载直连",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "屏蔽 DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage("防止代理回环"),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("屏蔽 QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("屏蔽 STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("局域网直连"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple 与 Microsoft 直连",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("规则集"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("规则集"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage("规则集中没有可用的条目"),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage("无法读取该 mrs 文件"),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "规则集同时包含域名和 IP 段，无法判断类型",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("规则目标"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "规则必须以受支持的类型开头，例如 DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("规则"),
    "rulesCount": m86,
    "runTime": MessageLookupByLibrary.simpleMessage("运行时长"),
    "running": MessageLookupByLibrary.simpleMessage("运行中"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("运行时配置"),
    "safeMode": MessageLookupByLibrary.simpleMessage("安全模式"),
    "safeModeAppTitle": m87,
    "saturation": MessageLookupByLibrary.simpleMessage("饱和度"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "script": MessageLookupByLibrary.simpleMessage("脚本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage("脚本模式，使用扩展脚本改写整个配置"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("滚动到已选"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m88,
    "secretKey": MessageLookupByLibrary.simpleMessage("密钥"),
    "sectionsInEffect": m89,
    "select": MessageLookupByLibrary.simpleMessage("选中"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("请选择规则集"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("请选择分流策略"),
    "send": MessageLookupByLibrary.simpleMessage("发送"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("从手机发送"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "导入手机发来的链接？",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "这台设备没有连接局域网",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "订阅链接或代理分享链接",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "已发送，请在另一台设备上确认导入。",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "把链接发送到 FlClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "从手机接收链接需要「附近的设备」权限，FlClash 才能访问局域网。请在应用设置中开启。",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "用手机相机扫描二维码，在打开的页面里粘贴链接。两台设备需要连在同一个网络。",
    ),
    "server": MessageLookupByLibrary.simpleMessage("服务器"),
    "serviceAbnormalCount": m90,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("全部可用"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("可用"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("已被封禁"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("全部检测"),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("即将上线"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage("不允许的 ISP"),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("检测失败"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("管理服务"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("仅限自制内容"),
    "servicePending": MessageLookupByLibrary.simpleMessage("待检测"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("访问受限"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage("显示在仪表盘"),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("服务状态"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("不可用"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage("地区不支持"),
    "settingEntries": MessageLookupByLibrary.simpleMessage("设置项"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "settingsCount": m91,
    "shareLinkUnreadable": m92,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage("无法从链接中读取代理"),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "在另一台设备上用 FlClash 扫码即可导入此配置。",
    ),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "showLess": MessageLookupByLibrary.simpleMessage("收起"),
    "showMore": MessageLookupByLibrary.simpleMessage("展开"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知栏显示停止按钮",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("显示密码"),
    "sidebar": MessageLookupByLibrary.simpleMessage("侧边栏"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "背景模糊会让侧边栏透出窗口后方的桌面。",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("静默启动"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("静默启动时不显示窗口。"),
    "singleAdd": MessageLookupByLibrary.simpleMessage("单条添加"),
    "singleImport": MessageLookupByLibrary.simpleMessage("单条导入"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "这里只能填写一条链接，多条请在列表的快速编辑中填写",
    ),
    "singleValueTip": m93,
    "size": MessageLookupByLibrary.simpleMessage("尺寸"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("跳过证书验证"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("跳过域名"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage("嗅探到跳过域名中的域名时不予采用。"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("跳过目标地址"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("跳过来源地址"),
    "slide": MessageLookupByLibrary.simpleMessage("滑动"),
    "sliders": MessageLookupByLibrary.simpleMessage("滑块"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("协议"),
    "sniffer": MessageLookupByLibrary.simpleMessage("域名嗅探"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "域名嗅探从 TLS、HTTP、QUIC 流量中识别域名，供规则匹配。",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks端口"),
    "softStyle": MessageLookupByLibrary.simpleMessage("柔和"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("来源"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("源IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊代理"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊规则"),
    "spectrum": MessageLookupByLibrary.simpleMessage("光谱"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("网速统计"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("分流策略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage("分流策略不能为空"),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs为空"),
    "stackMode": MessageLookupByLibrary.simpleMessage("栈模式"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("堆栈信息"),
    "standard": MessageLookupByLibrary.simpleMessage("标准"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "标准模式，在配置的基础上附加规则",
    ),
    "start": MessageLookupByLibrary.simpleMessage("启动"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("从零开始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在启动VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("启动与后台"),
    "status": MessageLookupByLibrary.simpleMessage("状态"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("关闭 DNS 后将使用系统 DNS。"),
    "stop": MessageLookupByLibrary.simpleMessage("暂停"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("策略"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("严格路由"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "严格路由防止 DNS 等流量绕过虚拟网卡，关闭 IPv6 时会阻断本机的 IPv6 连接。",
    ),
    "style": MessageLookupByLibrary.simpleMessage("风格"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("订阅信息"),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage("输入 sudo 密码"),
    "suspended": MessageLookupByLibrary.simpleMessage("挂起中…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("切换配置"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "systemApp": MessageLookupByLibrary.simpleMessage("系统应用"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "tab": MessageLookupByLibrary.simpleMessage("标签页"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("选项卡动画"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("点击图标重试"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("点击授权"),
    "target": MessageLookupByLibrary.simpleMessage("目标"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP并发"),
    "testInterval": MessageLookupByLibrary.simpleMessage("测试间隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("测速链接"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用时测试"),
    "textScale": MessageLookupByLibrary.simpleMessage("文本缩放"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage("应用内的文字将以这个大小显示"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色彩"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "tight": MessageLookupByLibrary.simpleMessage("紧凑"),
    "time": MessageLookupByLibrary.simpleMessage("时间"),
    "timeout": MessageLookupByLibrary.simpleMessage("超时"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("氛围"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "tolerance": MessageLookupByLibrary.simpleMessage("容差"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "torch": MessageLookupByLibrary.simpleMessage("手电筒"),
    "total": MessageLookupByLibrary.simpleMessage("总计"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("下载总量"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("总流量"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("上传总量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "traffic": MessageLookupByLibrary.simpleMessage("流量"),
    "trafficPeak": m94,
    "trafficTotal": m95,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量统计"),
    "transport": MessageLookupByLibrary.simpleMessage("传输协议"),
    "transportHeaders": m96,
    "tun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "虚拟网卡授权失败，已关闭。",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("虚拟网卡仅在管理员模式生效。"),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有配置的虚拟网卡设置，未添加的项沿用配置自身的设置。自定义配置自己添加的项优先。",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "turnOn": MessageLookupByLibrary.simpleMessage("开启"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP 中继模式"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP 超时"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 超时以秒为单位，仅在 gvisor、system 和 mixed 栈生效。",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("极致"),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("统一延迟"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("未知网络错误"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("向下还原"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("取消置顶"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("上行带宽"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m97,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统Hosts"),
    "usedShort": MessageLookupByLibrary.simpleMessage("已用"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("已用流量"),
    "userAgent": MessageLookupByLibrary.simpleMessage("用户代理"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("虚拟 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("鲜明"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "检测到VPN相关配置改动",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 通过 VpnService 自动路由系统所有流量。",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV配置"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名单模式"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("写入系统"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "写入系统会同时设置系统时钟，Android 上不生效。",
    ),
    "yearsAgo": m98,
    "yearsAgoShort": m99,
    "yes": MessageLookupByLibrary.simpleMessage("是"),
    "zhCN": MessageLookupByLibrary.simpleMessage("中文简体"),
  };
}
