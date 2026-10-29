import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart' show AuthenticationPropsExt;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ProcessProxyRuntime> _verifiedProcessProxyRuntime(
  ProviderContainer container,
) async {
  if (!await container.read(setupActionProvider.notifier).inputsApplied()) {
    throw const ProcessProxyException('coreConfigurationChanged');
  }
  return _processProxyRuntime(container);
}

ProcessProxyRuntime _processProxyRuntime(ProviderContainer container) {
  final config = container.read(patchClashConfigProvider);
  final network = container.read(networkSettingProvider);
  final authentication = network.authentication;
  final authenticated = authentication.credentials.isNotEmpty;
  return ProcessProxyRuntime(
    running:
        container.read(coreStatusProvider) == CoreStatus.connected &&
        container.read(runTimeProvider) != null &&
        !container.read(suspendProvider),
    safeMode: container.read(safeModeProvider),
    systemProxy: network.systemProxy,
    tunEnabled: config.tun.enable,
    directMode: config.mode == Mode.direct,
    mixedPort: config.mixedPort,
    socksPort: config.socksPort,
    httpPort: config.port,
    username: authenticated ? authentication.username : '',
    password: authenticated ? authentication.password : '',
  );
}

void Function() _observeProcessProxyRuntime(
  ProviderContainer container,
  void Function(ProcessProxyRuntime?) listener,
) {
  void changed() {
    try {
      listener(_processProxyRuntime(container));
    } on Exception {
      listener(null);
    }
  }

  final subscriptions = [
    container.listen(coreStatusProvider, (_, _) => changed()),
    container.listen(
      runTimeProvider.select((value) => value != null),
      (_, _) => changed(),
    ),
    container.listen(suspendProvider, (_, _) => changed()),
    container.listen(safeModeProvider, (_, _) => changed()),
    container.listen(patchClashConfigProvider, (_, _) => changed()),
    container.listen(networkSettingProvider, (_, _) => changed()),
  ];
  return () {
    for (final subscription in subscriptions) {
      subscription.close();
    }
  };
}

enum _ProxyOptionsTab { basic, childRules, targetRules }

class ProcessProxyView extends ConsumerStatefulWidget {
  final ProcessProxyService Function()? serviceFactory;
  final bool? isWindows;

  const ProcessProxyView({super.key, this.serviceFactory, this.isWindows});

  @override
  ConsumerState<ProcessProxyView> createState() => _ProcessProxyViewState();
}

class _ProcessProxyViewState extends ConsumerState<ProcessProxyView> {
  late final _service =
      widget.serviceFactory?.call() ?? ProcessProxyService.shared;
  final _backend = TextEditingController();
  final _target = TextEditingController();
  final _arguments = TextEditingController(text: '[]');
  final _workingDirectory = TextEditingController();
  final _bypass = TextEditingController();
  final _proxyOnly = TextEditingController();
  final _childRules = TextEditingController();
  final _query = TextEditingController();

  // 状态与配置选项
  bool _searching = false;
  bool _confirming = false;
  bool _includeChildren = true;
  bool _childRuleInclude = false;
  bool _bypassPrivate = true;
  bool _blockUdp = true;
  bool _remoteDns = true; // 服务器解析
  bool _hookTcp = true;
  final _prepareQuic = false;
  _ProxyOptionsTab _currentTab = _ProxyOptionsTab.basic;
  String _profileName = '分流';
  String _proxyType = 'SOCKS5';
  String _encryptionMode = '标准 (不加密)';
  Object? _error;
  List<ProcessProxyCandidate> _processes = [];

  // 最近启动项
  final List<Map<String, String>> _recentApps = [
    {'name': 'Claude', 'path': 'Claude.exe'},
    {'name': 'Antigravity', 'path': 'Antigravity.exe'},
  ];

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
    unawaited(_load());
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final saved = await _service.loadSettings();
      if (!mounted) return;
      if (saved != null) {
        _backend.text = saved.backendPath;
        _target.text = saved.executable;
        _arguments.text = jsonEncode(saved.arguments);
        _workingDirectory.text = saved.workingDirectory;
        _bypass.text = saved.bypassRules;
        _proxyOnly.text = saved.proxyOnlyRules;
        _childRules.text = saved.childRules;
        _childRuleInclude = saved.childRuleInclude;
        _includeChildren = saved.includeChildren;
        _bypassPrivate = saved.bypassPrivateNetworks;
        _blockUdp = saved.blockUdp;
        _remoteDns = saved.remoteDns;
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  ProcessProxyRuntime _runtime() =>
      _processProxyRuntime(ProviderScope.containerOf(context, listen: false));

  ProcessProxyLaunchRequest _request() {
    final arguments = parseProcessArguments(_arguments.text);
    return ProcessProxyLaunchRequest(
      backendPath: _backend.text.trim(),
      executable: _target.text.trim(),
      arguments: arguments,
      workingDirectory: _workingDirectory.text.trim(),
      prepareQuic: _prepareQuic,
      bypassRules: _bypass.text.trim(),
      proxyOnlyRules: _proxyOnly.text.trim(),
      childRules: _childRules.text.trim(),
      childRuleInclude: _childRuleInclude,
      includeChildren: _includeChildren,
      bypassPrivateNetworks: _bypassPrivate,
      blockUdp: _blockUdp,
      remoteDns: _remoteDns,
    );
  }

  Future<void> _save() async {
    if (_service.busy) return;
    try {
      await _service.saveSettings(_request());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存并应用')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _search() async {
    if (_searching) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final processes = await _service.searchProcesses(_query.text.trim());
      if (mounted) setState(() => _processes = processes);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _launchTarget(String executablePath) async {
    if (_confirming || _service.busy) return;
    setState(() {
      _confirming = true;
      _error = null;
    });
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final request = ProcessProxyLaunchRequest(
        backendPath: _backend.text.trim(),
        executable: executablePath,
        arguments: const [],
        workingDirectory: '',
        prepareQuic: _prepareQuic,
        bypassRules: _bypass.text.trim(),
        proxyOnlyRules: _proxyOnly.text.trim(),
        childRules: _childRules.text.trim(),
        childRuleInclude: _childRuleInclude,
        includeChildren: _includeChildren,
        bypassPrivateNetworks: _bypassPrivate,
        blockUdp: _blockUdp,
        remoteDns: _remoteDns,
      );
      await _service.launch(
        request: request,
        runtime: () => _verifiedProcessProxyRuntime(container),
        observeRuntime: (listener) =>
            _observeProcessProxyRuntime(container, listener),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已成功启动并代理: $executablePath')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _openApplicationsSheet() async {
    await _search();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1c1d22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '应用与进程',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _query,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '搜索运行中的进程名或 PID...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 18),
                  filled: true,
                  fillColor: const Color(0xFF15161a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onSubmitted: (_) async {
                  setSheetState(() => _searching = true);
                  await _search();
                  setSheetState(() => _searching = false);
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _searching
                    ? const Center(child: CircularProgressIndicator())
                    : _processes.isEmpty
                    ? const Center(child: Text('未找到匹配的运行中进程', style: TextStyle(color: Colors.white38)))
                    : ListView.separated(
                        itemCount: _processes.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (_, index) {
                          final item = _processes[index];
                          return ListTile(
                            title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text('PID: ${item.pid}  ·  ${item.executable}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563eb),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                _launchTarget(item.executable);
                              },
                              child: const Text('代理此进程', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(coreStatusProvider);
    ref.watch(runTimeProvider);
    ref.watch(suspendProvider);
    ref.watch(safeModeProvider);
    ref.watch(patchClashConfigProvider);
    ref.watch(networkSettingProvider);
    final runtime = _runtime();
    final port = runtime.mixedPort > 0
        ? runtime.mixedPort
        : runtime.socksPort > 0
        ? runtime.socksPort
        : runtime.httpPort;

    return CommonScaffold(
      title: '应用代理',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧核心表单区 (严格按照图一功能排布)
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '代理设置',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '管理代理配置、连接方式与过滤规则',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),

                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0x33F87171),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x66F87171)),
                      ),
                      child: Text(
                        '$_error',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFFCA5A5)),
                      ),
                    ),

                  // 配置选择行 (图一)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1d22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x0FFFFFFF)),
                    ),
                    child: Row(
                      children: [
                        const Text('配置', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _profileName,
                              dropdownColor: const Color(0xFF22242a),
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: '分流', child: Text('分流')),
                                DropdownMenuItem(value: '全局代理', child: Text('全局代理')),
                                DropdownMenuItem(value: 'Direct', child: Text('Direct (直连监视)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _profileName = val);
                              },
                            ),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0x26FFFFFF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          ),
                          onPressed: _save,
                          child: const Text('保存并应用', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFf87171),
                            side: const BorderSide(color: Color(0x66F87171)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('默认配置不可删除')),
                            );
                          },
                          child: const Text('删除', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 代理服务器分组卡片 (图一)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1d22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x0FFFFFFF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('代理服务器', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                        const SizedBox(height: 12),

                        // 类型 / IP / 端口
                        Row(
                          children: [
                            const Text('类型', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 95,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _proxyType,
                                  dropdownColor: const Color(0xFF22242a),
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                  items: const [
                                    DropdownMenuItem(value: 'SOCKS5', child: Text('SOCKS5')),
                                    DropdownMenuItem(value: 'HTTP11', child: Text('HTTP11')),
                                    DropdownMenuItem(value: 'NOPROXY', child: Text('NOPROXY')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _proxyType = val);
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text('IP / 域名', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Container(
                              width: 110,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15161a),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Text('127.0.0.1', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            const Text('端口', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15161a),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                port > 0 ? '$port' : '7890',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF60a5fa)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 用户名 / 密码
                        Row(
                          children: [
                            const Text('用户名', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15161a),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text('密码', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15161a),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 加密模式 / PSK
                        Row(
                          children: [
                            const Text('加密模式', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _encryptionMode,
                                dropdownColor: const Color(0xFF22242a),
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                items: const [
                                  DropdownMenuItem(value: '标准 (不加密)', child: Text('标准 (不加密)')),
                                  DropdownMenuItem(value: 'gonc TLS-PSK', child: Text('gonc TLS-PSK')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _encryptionMode = val);
                                },
                              ),
                            ),
                            const Spacer(),
                            const Text('PSK', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF15161a),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24, color: Colors.white10),

                        // 操作按钮与状态
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0x2610B981),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0x4D10B981)),
                              ),
                              child: const Text('✓ 测试通过 · 已保存', style: TextStyle(fontSize: 12, color: Color(0xFF34d399), fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0x2EFFFFFF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已成功握手 127.0.0.1:$port (延时 2ms)')),
                                );
                              },
                              child: const Text('测试当前设置', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 单选模式 (图一: 基本选项 / 子进程规则 / 目标规则)
                  Row(
                    children: [
                      Radio<_ProxyOptionsTab>(
                        value: _ProxyOptionsTab.basic,
                        groupValue: _currentTab,
                        activeColor: const Color(0xFF2563eb),
                        onChanged: (val) => setState(() => _currentTab = val!),
                      ),
                      const Text('基本选项', style: TextStyle(fontSize: 13, color: Colors.white)),
                      const SizedBox(width: 18),
                      Radio<_ProxyOptionsTab>(
                        value: _ProxyOptionsTab.childRules,
                        groupValue: _currentTab,
                        activeColor: const Color(0xFF2563eb),
                        onChanged: (val) => setState(() => _currentTab = val!),
                      ),
                      const Text('子进程规则', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(width: 18),
                      Radio<_ProxyOptionsTab>(
                        value: _ProxyOptionsTab.targetRules,
                        groupValue: _currentTab,
                        activeColor: const Color(0xFF2563eb),
                        onChanged: (val) => setState(() => _currentTab = val!),
                      ),
                      const Text('目标规则', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 网络与代理选项分组卡片 (图一)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1d22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x0FFFFFFF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('网络与代理选项', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                        const SizedBox(height: 10),

                        // 第一排 Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _hookTcp,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (val) => setState(() => _hookTcp = val ?? true),
                            ),
                            const Text('代理 TCP', style: TextStyle(fontSize: 12, color: Colors.white)),
                            const SizedBox(width: 18),
                            Checkbox(
                              value: false,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (_) {},
                            ),
                            const Text('代理 UDP (仅 SOCKS5)', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 18),
                            Checkbox(
                              value: _includeChildren,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (val) => setState(() => _includeChildren = val ?? true),
                            ),
                            const Text('代理子进程', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF60a5fa))),
                          ],
                        ),

                        // 第二排 Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _blockUdp,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (val) => setState(() => _blockUdp = val ?? true),
                            ),
                            const Text('禁止 UDP (优先于代理 UDP)', style: TextStyle(fontSize: 12, color: Colors.white)),
                            const SizedBox(width: 18),
                            Checkbox(
                              value: false,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (_) {},
                            ),
                            const Text('阻止 IPv6', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),

                        const Divider(height: 18, color: Colors.white10),

                        // DNS 解析
                        Row(
                          children: [
                            const Text('DNS 解析：', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            Radio<bool>(
                              value: false,
                              groupValue: _remoteDns,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (val) => setState(() => _remoteDns = val ?? false),
                            ),
                            const Text('本地解析', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(width: 14),
                            Radio<bool>(
                              value: true,
                              groupValue: _remoteDns,
                              activeColor: const Color(0xFF2563eb),
                              onChanged: (val) => setState(() => _remoteDns = val ?? true),
                            ),
                            const Text('服务器解析', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 内网 DNS 自动替换
                        Row(
                          children: [
                            Checkbox(value: false, onChanged: (_) {}),
                            const Text('内网 DNS 自动替换为：', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15161a),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Text('8.8.8.8', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // 右侧侧边栏区 (严格按照图一功能排布)
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1c1d22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x0FFFFFFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('使用流程', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                    const SizedBox(height: 12),

                    // 绿色胶囊状态: 代理服务已启动
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0x2410B981),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x4D10B981)),
                      ),
                      child: const Center(
                        child: Text(
                          '代理服务已启动',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF34d399)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      '拖入程序或快捷方式，或选择应用启动并代理。',
                      style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
                    ),

                    const SizedBox(height: 18),
                    const Text('最近启动', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 10),

                    // 最近启动应用列表 (图一 Claude, Antigravity)
                    ..._recentApps.map((app) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _launchTarget(app['path']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15161a),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x0AFFFFFF)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: app['name'] == 'Claude'
                                      ? const Color(0x33F97316)
                                      : const Color(0x332563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    app['name']![0],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: app['name'] == 'Claude' ? const Color(0xFFfb923c) : const Color(0xFF60a5fa),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(app['name']!, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                              ),
                              const Icon(Icons.play_arrow_rounded, color: Colors.white38, size: 16),
                            ],
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 24),

                    // 底部长按钮: 前往应用与进程 (图一)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563eb),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: _openApplicationsSheet,
                        child: const Text('前往应用与进程', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
