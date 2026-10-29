import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

  // 核心路径与参数控制器
  final _backend = TextEditingController();
  final _target = TextEditingController();
  final _arguments = TextEditingController(text: '[]');
  final _workingDirectory = TextEditingController();

  // 代理服务器设置控制器
  final _host = TextEditingController(text: '127.0.0.1');
  final _port = TextEditingController(text: '7890');
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _psk = TextEditingController();
  final _redirectDns = TextEditingController(text: '8.8.8.8');

  // 规则控制器
  final _childRules = TextEditingController();
  final _bypass = TextEditingController();
  final _proxyOnly = TextEditingController();
  final _query = TextEditingController();

  // 交互状态
  bool _obscurePassword = true;
  bool _searching = false;
  bool _confirming = false;
  bool _testing = false;
  bool? _testSuccess;
  String _testStatusText = '就绪 · 待测试';

  // 代理选项
  bool _hookTcp = true;
  bool _hookUdp = false;
  bool _includeChildren = true;
  bool _blockUdp = true;
  bool _blockIpv6 = false;
  bool _remoteDns = true; // true: 服务器解析, false: 本地解析
  bool _redirectPrivateDns = false;
  bool _childRuleInclude = true; // true: 仅代理包含, false: 排除
  bool _targetModeBypass = true; // true: 绕过目标(直连), false: 仅代理目标
  final _prepareQuic = false;

  _ProxyOptionsTab _currentTab = _ProxyOptionsTab.basic;
  String _profileName = '分流';
  List<String> _profileNames = ['分流', '全局代理', 'Direct'];
  final Map<String, Map<String, dynamic>> _profilesMap = {};
  String _proxyType = 'SOCKS5';
  String _encryptionMode = '标准 (不加密)';
  Object? _error;
  List<ProcessProxyCandidate> _processes = [];
  List<ProcessProxyApplication> _installedApps = [];

  // 真实最近启动项
  List<Map<String, String>> _recentApps = [
    {
      'name': 'Antigravity',
      'path': r'C:\Users\李璟\AppData\Local\Programs\antigravity\Antigravity.exe',
    },
    {
      'name': 'Obsidian',
      'path': r'D:\Work\tool\Obsidian\Obsidian.exe',
    },
    {
      'name': 'Google Chrome',
      'path': r'C:\Program Files\Google\Chrome\Application\chrome.exe',
    },
    {
      'name': 'CC Switch',
      'path': r'D:\Work\tool\cc-switch.exe',
    },
    {
      'name': 'Claude',
      'path': 'Claude.exe',
    },
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
      // 1. 自动搜索检测本地真实 ProxyLane 后端路径与配置
      const candidateBackendDirs = [
        r'D:\桌面\ProxyLane-1.2.15-Windows',
        r'D:\Work\tool\ProxyLane',
        r'.',
      ];
      String? foundIniPath;
      for (final dir in candidateBackendDirs) {
        final exe = File('$dir\\ProxyLane.exe');
        final exe64 = File('$dir\\ProxyLane64.exe');
        if (exe.existsSync() || exe64.existsSync()) {
          _backend.text = exe64.existsSync() ? exe64.path : exe.path;
          final ini = File('$dir\\ProxyLane.ini');
          if (ini.existsSync()) {
            foundIniPath = ini.path;
          }
          break;
        }
      }

      // 2. 如果存在 ProxyLane.ini，解析真实配置与最近应用
      if (foundIniPath != null) {
        _parseProxyLaneIni(foundIniPath);
      }

      // 3. 读取本地持久化设置
      final saved = await _service.loadSettings();
      if (!mounted) return;
      if (saved != null) {
        if (saved.backendPath.isNotEmpty) _backend.text = saved.backendPath;
        if (saved.executable.isNotEmpty) _target.text = saved.executable;
        _arguments.text = jsonEncode(saved.arguments);
        _workingDirectory.text = saved.workingDirectory;
        if (saved.bypassRules.isNotEmpty) _bypass.text = saved.bypassRules;
        if (saved.proxyOnlyRules.isNotEmpty) _proxyOnly.text = saved.proxyOnlyRules;
        if (saved.childRules.isNotEmpty) _childRules.text = saved.childRules;
        _childRuleInclude = saved.childRuleInclude;
        _includeChildren = saved.includeChildren;
        _blockUdp = saved.blockUdp;
        _remoteDns = saved.remoteDns;
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _parseProxyLaneIni(String iniPath) {
    try {
      final file = File(iniPath);
      final lines = file.readAsLinesSync();
      String currentSection = '';
      final parsedRecent = <Map<String, String>>[];
      Map<String, String> currentRecentApp = {};

      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith(';') || line.startsWith('#')) continue;

        if (line.startsWith('[') && line.endsWith(']')) {
          if (currentSection.startsWith('recent_app_') && currentRecentApp.isNotEmpty) {
            final name = currentRecentApp['name'] ?? '';
            final path = currentRecentApp['path'] ?? '';
            if (name.isNotEmpty) {
              parsedRecent.add({'name': name, 'path': path});
            }
            currentRecentApp = {};
          }
          currentSection = line.substring(1, line.length - 1);
          if (currentSection.startsWith('proxy_')) {
            final pName = currentSection.substring(6);
            if (!_profileNames.contains(pName)) {
              _profileNames.add(pName);
            }
            _profilesMap[pName] = {};
          }
          continue;
        }

        final eqIdx = line.indexOf('=');
        if (eqIdx == -1) continue;
        final key = line.substring(0, eqIdx).trim();
        final val = line.substring(eqIdx + 1).trim();

        if (currentSection.startsWith('proxy_')) {
          final pName = currentSection.substring(6);
          _profilesMap[pName]?[key] = val;
        } else if (currentSection.startsWith('recent_app_')) {
          if (key == 'NameUtf8Base64' && val.isNotEmpty) {
            try {
              currentRecentApp['name'] = utf8.decode(base64Decode(val));
            } catch (_) {}
          } else if (key == 'PathUtf8Base64' && val.isNotEmpty) {
            try {
              currentRecentApp['path'] = utf8.decode(base64Decode(val));
            } catch (_) {}
          }
        }
      }

      if (currentRecentApp.isNotEmpty && currentRecentApp['name'] != null) {
        parsedRecent.add({'name': currentRecentApp['name']!, 'path': currentRecentApp['path'] ?? ''});
      }

      if (parsedRecent.isNotEmpty) {
        _recentApps = parsedRecent;
      }

      // 如果有当前选中的配置，载入该配置
      if (_profilesMap.containsKey(_profileName)) {
        _applyLoadedProfile(_profileName);
      }
    } catch (_) {}
  }

  void _applyLoadedProfile(String name) {
    final cfg = _profilesMap[name];
    if (cfg == null) return;
    setState(() {
      _hookTcp = cfg['HookTCP'] != '0';
      _hookUdp = cfg['HookUDP'] == '1';
      _includeChildren = cfg['HookChildProcess'] != '0';
      _blockUdp = cfg['BlockUDP'] != '0';
      _blockIpv6 = cfg['BlockIPv6'] == '1';
      _remoteDns = cfg['dnsOpt'] != '0';
      _redirectPrivateDns = cfg['RedirectPrivateDNS'] == '1';
      if (cfg['RedirectDNS'] != null && cfg['RedirectDNS']!.isNotEmpty) {
        _redirectDns.text = cfg['RedirectDNS']!;
      }
      if (cfg['Host'] != null && cfg['Host']!.isNotEmpty) {
        _host.text = cfg['Host']!;
      }
      if (cfg['Port'] != null && cfg['Port']!.isNotEmpty) {
        _port.text = cfg['Port']!;
      }
      if (cfg['Type'] != null && cfg['Type']!.isNotEmpty) {
        _proxyType = cfg['Type']!;
      }
      if (cfg['User'] != null) _username.text = cfg['User']!;
      if (cfg['Pass'] != null) _password.text = cfg['Pass']!;
      if (cfg['PSK'] != null) _psk.text = cfg['PSK']!;
      if (cfg['TargetFilter'] != null) {
        _bypass.text = cfg['TargetFilter']!.replaceAll('|', '\n');
        _targetModeBypass = cfg['TargetFilterMode'] == '0';
      }
      if (cfg['ChildFilter'] != null) {
        _childRules.text = cfg['ChildFilter']!.replaceAll('|', '\n');
        _childRuleInclude = cfg['ChildFilterMode'] == '1';
      }
    });
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
      bypassRules: _targetModeBypass ? _bypass.text.trim() : '',
      proxyOnlyRules: !_targetModeBypass ? _bypass.text.trim() : _proxyOnly.text.trim(),
      childRules: _childRules.text.trim(),
      childRuleInclude: _childRuleInclude,
      includeChildren: _includeChildren,
      bypassPrivateNetworks: true,
      blockUdp: _blockUdp,
      remoteDns: _remoteDns,
    );
  }

  Future<void> _save() async {
    if (_service.busy) return;
    try {
      await _service.saveSettings(_request());
      _profilesMap[_profileName] = {
        'HookTCP': _hookTcp ? '1' : '0',
        'HookUDP': _hookUdp ? '1' : '0',
        'HookChildProcess': _includeChildren ? '1' : '0',
        'BlockUDP': _blockUdp ? '1' : '0',
        'BlockIPv6': _blockIpv6 ? '1' : '0',
        'dnsOpt': _remoteDns ? '1' : '0',
        'RedirectPrivateDNS': _redirectPrivateDns ? '1' : '0',
        'RedirectDNS': _redirectDns.text,
        'Host': _host.text,
        'Port': _port.text,
        'Type': _proxyType,
        'User': _username.text,
        'Pass': _password.text,
        'PSK': _psk.text,
        'TargetFilter': _bypass.text.trim().replaceAll('\n', '|'),
        'TargetFilterMode': _targetModeBypass ? '0' : '1',
        'ChildFilter': _childRules.text.trim().replaceAll('\n', '|'),
        'ChildFilterMode': _childRuleInclude ? '1' : '0',
      };
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存并应用')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  // 真实的 Socket 握手测试连接
  Future<void> _testCurrentSettings() async {
    setState(() {
      _testing = true;
      _testSuccess = null;
      _testStatusText = '正在测试连接...';
    });
    final host = _host.text.trim().isEmpty ? '127.0.0.1' : _host.text.trim();
    final port = int.tryParse(_port.text.trim()) ?? 7890;
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
      stopwatch.stop();
      await socket.close();
      if (mounted) {
        setState(() {
          _testing = false;
          _testSuccess = true;
          _testStatusText = '✓ 握手成功 · 延时 ${stopwatch.elapsedMilliseconds}ms';
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _testing = false;
          _testSuccess = false;
          final msg = e.toString().contains('refused')
              ? '连接被拒绝 (端口未开启)'
              : e.toString().contains('timed out')
              ? '连接超时'
              : e.toString().split(':').last.trim();
          _testStatusText = '✗ 无法连接 ($host:$port): $msg';
        });
      }
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
      final apps = await _service.searchApplications(_query.text.trim());
      if (mounted) {
        setState(() {
          _processes = processes;
          _installedApps = apps;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _pickAndLaunchApp() async {
    try {
      final file = await FilePicker.pickFile();
      if (file != null && file.path != null) {
        final path = file.path!;
        final name = file.name;
        setState(() {
          _recentApps.insert(0, {'name': name, 'path': path});
        });
        await _launchTarget(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $e')),
        );
      }
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

      // 确保后端路径有效
      var backendPath = _backend.text.trim();
      if (backendPath.isEmpty || !File(backendPath).existsSync()) {
        const candidatePaths = [
          r'D:\桌面\ProxyLane-1.2.15-Windows\ProxyLane.exe',
          r'D:\桌面\ProxyLane-1.2.15-Windows\ProxyLane64.exe',
          r'ProxyLane.exe',
          r'ProxyLane64.exe',
        ];
        for (final p in candidatePaths) {
          if (File(p).existsSync()) {
            backendPath = p;
            _backend.text = p;
            break;
          }
        }
      }

      final request = ProcessProxyLaunchRequest(
        backendPath: backendPath,
        executable: executablePath,
        arguments: const [],
        workingDirectory: '',
        prepareQuic: _prepareQuic,
        bypassRules: _targetModeBypass ? _bypass.text.trim() : '',
        proxyOnlyRules: !_targetModeBypass ? _bypass.text.trim() : _proxyOnly.text.trim(),
        childRules: _childRules.text.trim(),
        childRuleInclude: _childRuleInclude,
        includeChildren: _includeChildren,
        bypassPrivateNetworks: true,
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
          SnackBar(content: Text('已成功启动进程并接管代理: $executablePath')),
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
        builder: (context, setSheetState) => DefaultTabController(
          length: 3,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '应用与进程管理',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563eb),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _pickAndLaunchApp();
                          },
                          icon: const Icon(Icons.file_open_outlined, size: 16, color: Colors.white),
                          label: const Text('浏览 EXE 文件', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _query,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '搜索运行中的进程名、PID 或已安装软件...',
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
                const SizedBox(height: 12),
                const TabBar(
                  indicatorColor: Color(0xFF2563eb),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(text: '运行中的进程'),
                    Tab(text: '已安装的应用'),
                    Tab(text: '活跃代理会话'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 1. 运行中进程列表
                      _searching
                          ? const Center(child: CircularProgressIndicator())
                          : _processes.isEmpty
                          ? const Center(child: Text('未找到匹配的运行中进程', style: TextStyle(color: Colors.white38)))
                          : ListView.separated(
                              itemCount: _processes.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                              itemBuilder: (_, index) {
                                final item = _processes[index];
                                return ListTile(
                                  leading: const Icon(Icons.memory, color: Color(0xFF60a5fa), size: 20),
                                  title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text('PID: ${item.pid}  ·  ${item.executable}', style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                                    child: const Text('代理启动', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                );
                              },
                            ),

                      // 2. 已安装应用列表
                      _searching
                          ? const Center(child: CircularProgressIndicator())
                          : _installedApps.isEmpty
                          ? const Center(child: Text('未找到已安装应用', style: TextStyle(color: Colors.white38)))
                          : ListView.separated(
                              itemCount: _installedApps.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                              itemBuilder: (_, index) {
                                final app = _installedApps[index];
                                return ListTile(
                                  leading: const Icon(Icons.apps, color: Color(0xFF34d399), size: 20),
                                  title: Text(app.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text(app.executable, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563eb),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      _launchTarget(app.executable);
                                    },
                                    child: const Text('启动并代理', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                );
                              },
                            ),

                      // 3. 活跃代理会话列表
                      _service.sessions.isEmpty
                          ? const Center(child: Text('当前暂无活跃代理会话', style: TextStyle(color: Colors.white38)))
                          : ListView.separated(
                              itemCount: _service.sessions.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                              itemBuilder: (_, index) {
                                final s = _service.sessions[index];
                                return ListTile(
                                  leading: const Icon(Icons.check_circle, color: Color(0xFF34d399), size: 20),
                                  title: Text(s.executable, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text('状态: ${s.status}  ·  PID: ${s.backendPid} (目标 PID: ${s.targetPid ?? "-"})', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                  trailing: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFf87171),
                                      side: const BorderSide(color: Color(0x66F87171)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('已断开会话 ${s.id}')),
                                      );
                                    },
                                    child: const Text('断开', style: TextStyle(fontSize: 12)),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
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
    final defaultPort = runtime.mixedPort > 0
        ? runtime.mixedPort
        : runtime.socksPort > 0
        ? runtime.socksPort
        : runtime.httpPort;

    if (_port.text.isEmpty || _port.text == '7890' || _port.text == '0') {
      if (defaultPort > 0) _port.text = '$defaultPort';
    }

    final isServiceActive = runtime.running || _service.sessions.isNotEmpty;

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
                              value: _profileNames.contains(_profileName) ? _profileName : _profileNames.first,
                              dropdownColor: const Color(0xFF22242a),
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              items: _profileNames.map((name) {
                                return DropdownMenuItem(value: name, child: Text(name));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _profileName = val);
                                  _applyLoadedProfile(val);
                                }
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
                            if (_profileNames.length <= 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('至少保留一个配置')),
                              );
                              return;
                            }
                            setState(() {
                              _profileNames.remove(_profileName);
                              _profilesMap.remove(_profileName);
                              _profileName = _profileNames.first;
                              _applyLoadedProfile(_profileName);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已删除该配置')),
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
                            SizedBox(
                              width: 120,
                              height: 32,
                              child: TextField(
                                controller: _host,
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF15161a),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('端口', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              height: 32,
                              child: TextField(
                                controller: _port,
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF60a5fa)),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF15161a),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
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
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _username,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '可选',
                                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                    filled: true,
                                    fillColor: const Color(0xFF15161a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text('密码', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _password,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '可选',
                                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 14, color: Colors.white38),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      padding: EdgeInsets.zero,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF15161a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
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
                            SizedBox(
                              width: 150,
                              height: 32,
                              child: TextField(
                                controller: _psk,
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: '密钥 (可选)',
                                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                  filled: true,
                                  fillColor: const Color(0xFF15161a),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24, color: Colors.white10),

                        // 操作按钮与真实状态反馈
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _testSuccess == true
                                    ? const Color(0x2610B981)
                                    : _testSuccess == false
                                    ? const Color(0x26F87171)
                                    : const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _testSuccess == true
                                      ? const Color(0x4D10B981)
                                      : _testSuccess == false
                                      ? const Color(0x4DF87171)
                                      : const Color(0x26FFFFFF),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_testing) ...[
                                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    _testStatusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _testSuccess == true
                                          ? const Color(0xFF34d399)
                                          : _testSuccess == false
                                          ? const Color(0xFFfca5a5)
                                          : Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0x2EFFFFFF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              ),
                              onPressed: _testing ? null : _testCurrentSettings,
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

                  // 动态切换区域：根据当前选中的 Tab 显示真实内容
                  if (_currentTab == _ProxyOptionsTab.basic) ...[
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
                                value: _hookUdp,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _hookUdp = val ?? false),
                              ),
                              const Text('代理 UDP (仅 SOCKS5)', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                                value: _blockIpv6,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _blockIpv6 = val ?? false),
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
                              Checkbox(
                                value: _redirectPrivateDns,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _redirectPrivateDns = val ?? false),
                              ),
                              const Text('内网 DNS 自动替换为：', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              SizedBox(
                                width: 120,
                                height: 32,
                                child: TextField(
                                  controller: _redirectDns,
                                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF15161a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (_currentTab == _ProxyOptionsTab.childRules) ...[
                    // 子进程规则卡片
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
                          Row(
                            children: [
                              const Text('子进程规则', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                              const Spacer(),
                              Radio<bool>(
                                value: false,
                                groupValue: _childRuleInclude,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _childRuleInclude = val ?? false),
                              ),
                              const Text('排除列表', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(width: 12),
                              Radio<bool>(
                                value: true,
                                groupValue: _childRuleInclude,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _childRuleInclude = val ?? true),
                              ),
                              const Text('仅包含列表', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '配置要针对性排除或代理的子程序，每行一个进程名或路径通配符（如 helper.exe 或 C:\\Tools\\*）',
                            style: TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _childRules,
                            maxLines: 6,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'helper.exe\nchrome_crashpad_handler.exe\nC:\\MyPath\\*',
                              hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                              filled: true,
                              fillColor: const Color(0xFF15161a),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_currentTab == _ProxyOptionsTab.targetRules) ...[
                    // 目标分流规则卡片
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
                          Row(
                            children: [
                              const Text('目标分流规则', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                              const Spacer(),
                              Radio<bool>(
                                value: true,
                                groupValue: _targetModeBypass,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _targetModeBypass = val ?? true),
                              ),
                              const Text('绕过目标 (直连)', style: TextStyle(fontSize: 12, color: Colors.white)),
                              const SizedBox(width: 12),
                              Radio<bool>(
                                value: false,
                                groupValue: _targetModeBypass,
                                activeColor: const Color(0xFF2563eb),
                                onChanged: (val) => setState(() => _targetModeBypass = val ?? false),
                              ),
                              const Text('仅代理目标', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '每行一个域名、IP 或 CIDR，支持通配符（如 *.kingsware.cn:*、10.11.3.*:*、192.168.*:*）',
                            style: TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _bypass,
                            maxLines: 6,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '*.kingsware.cn:*\nkingsware.cn:*\n10.11.3.*:*\n192.168.*:*',
                              hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                              filled: true,
                              fillColor: const Color(0xFF15161a),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

                    // 绿色胶囊状态: 代理服务状态指示
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isServiceActive ? const Color(0x2410B981) : const Color(0x1AF87171),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isServiceActive ? const Color(0x4D10B981) : const Color(0x4DF87171)),
                      ),
                      child: Center(
                        child: Text(
                          isServiceActive ? '代理服务已启动' : '代理服务未连接',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isServiceActive ? const Color(0xFF34d399) : const Color(0xFFfca5a5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      '拖入程序或快捷方式，或点击下方选择应用启动并代理。',
                      style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0x332563EB)),
                          backgroundColor: const Color(0x1A2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: _pickAndLaunchApp,
                        icon: const Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF60a5fa)),
                        label: const Text('浏览选择本地 EXE...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text('最近启动', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 10),

                    // 最近启动应用列表 (真实的 Antigravity, Obsidian, Chrome, CC Switch, Claude 等)
                    ..._recentApps.take(6).map((app) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (app['path'] != null && app['path']!.isNotEmpty) {
                            _launchTarget(app['path']!);
                          } else {
                            _openApplicationsSheet();
                          }
                        },
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
                                      : app['name'] == 'Obsidian'
                                      ? const Color(0x338B5CF6)
                                      : const Color(0x332563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    app['name']![0],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: app['name'] == 'Claude'
                                          ? const Color(0xFFfb923c)
                                          : app['name'] == 'Obsidian'
                                          ? const Color(0xFFa78bfa)
                                          : const Color(0xFF60a5fa),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  app['name']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    _backend.dispose();
    _target.dispose();
    _arguments.dispose();
    _workingDirectory.dispose();
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    _psk.dispose();
    _redirectDns.dispose();
    _bypass.dispose();
    _proxyOnly.dispose();
    _childRules.dispose();
    _query.dispose();
    super.dispose();
  }
}
