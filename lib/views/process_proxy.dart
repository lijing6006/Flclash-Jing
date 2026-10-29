import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:fl_clash/views/process_proxy/advanced.dart';
import 'package:fl_clash/views/process_proxy/applications.dart';
import 'package:fl_clash/views/process_proxy/profiles.dart';
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
  bool _loaded = false;
  bool _searching = false;
  bool _confirming = false;
  bool _includeChildren = true;
  bool _childRuleInclude = false;
  bool _bypassPrivate = true;
  bool _blockUdp = true;
  bool _remoteDns = false;
  bool _trusted = false;
  bool _prepareQuic = false;
  Object? _error;
  List<ProcessProxyCandidate> _processes = [];

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
      if (mounted) _error = error;
    } finally {
      if (mounted) setState(() => _loaded = true);
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
      bypassRules: _bypass.text,
      proxyOnlyRules: _proxyOnly.text,
      childRules: _childRules.text,
      childRuleInclude: _childRuleInclude,
      includeChildren: _includeChildren,
      bypassPrivateNetworks: _bypassPrivate,
      blockUdp: _blockUdp,
      remoteDns: _remoteDns,
      trustedBackend: _trusted,
    );
  }

  Future<void> _save() async {
    try {
      await _service.saveSettings(_request());
      if (mounted) setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _pickExecutable({required bool backend}) async {
    try {
      final file = await picker.pickerFile();
      final path = file?.path;
      if (!mounted || path == null) return;
      setState(() {
        if (backend) {
          _backend.text = path;
          _trusted = false;
        } else {
          _target.text = path;
        }
        _prepareQuic = false;
      });
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

  Future<void> _launch() async {
    if (_confirming || _service.busy) return;
    setState(() {
      _confirming = true;
      _error = null;
    });
    try {
      final request = _request();
      final container = ProviderScope.containerOf(context, listen: false);
      final confirmed = await dialogs.showMessage(
        context: context,
        title: context.appLocalizations.processProxyLaunch,
        message: TextSpan(
          text: context.appLocalizations.processProxyConfirmLaunch(
            request.executable,
          ),
        ),
        confirmText: context.appLocalizations.processProxyLaunch,
      );
      if (!mounted || confirmed != true) return;
      await _service.launch(
        request: request,
        runtime: () => _verifiedProcessProxyRuntime(container),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _showBackend(ProcessProxySession session) async {
    try {
      await _service.showBackendWindow(session.id);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _openApplications() async {
    if (_confirming || _service.busy) return;
    setState(() => _confirming = true);
    try {
      final selected = await BaseNavigator.push<ProcessProxyApplication>(
        context,
        ProcessProxyApplicationsView(service: _service),
      );
      if (!mounted || selected == null) return;
      setState(() {
        _target.text = selected.executable;
        _arguments.text = jsonEncode(selected.arguments);
        _workingDirectory.text = selected.workingDirectory;
        _prepareQuic = false;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _openProfiles() async {
    if (_confirming || _service.busy) return;
    setState(() => _confirming = true);
    try {
      ProcessProxyLaunchRequest? current;
      try {
        current = _request();
      } on ProcessProxyException {
        current = null;
      }
      final selected = await BaseNavigator.push<ProcessProxyLaunchRequest>(
        context,
        ProcessProxyProfilesView(currentRequest: current),
      );
      if (!mounted || selected == null) return;
      setState(() {
        _backend.text = selected.backendPath;
        _target.text = selected.executable;
        _arguments.text = jsonEncode(selected.arguments);
        _workingDirectory.text = selected.workingDirectory;
        _bypass.text = selected.bypassRules;
        _proxyOnly.text = selected.proxyOnlyRules;
        _childRules.text = selected.childRules;
        _childRuleInclude = selected.childRuleInclude;
        _includeChildren = selected.includeChildren;
        _bypassPrivate = selected.bypassPrivateNetworks;
        _blockUdp = selected.blockUdp;
        _remoteDns = selected.remoteDns;
        _trusted = false;
        _prepareQuic = false;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _setPrepareQuic(bool value) async {
    if (!value) {
      setState(() => _prepareQuic = false);
      return;
    }
    if (_confirming || _service.busy) return;
    setState(() => _confirming = true);
    try {
      final l = context.appLocalizations;
      final confirmed = await dialogs.showMessage(
        context: context,
        title: l.processProxyPrepareQuic,
        message: TextSpan(text: l.processProxyPrepareQuicHelp),
      );
      if (mounted && confirmed == true) {
        setState(() => _prepareQuic = true);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  String _sessionStatus(ProcessProxySession session, AppLocalizations l) {
    return switch (session.status) {
      'requested' => l.processProxyRequested,
      'backendRunning' => l.processProxyBackendRunning,
      'exited' => l.processProxyExited,
      _ => l.processProxyFailed(processProxyExitMessage(session.exitCode, l)),
    };
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? help,
    bool multiline = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        enabled: _loaded && !_service.busy && !_confirming,
        autocorrect: false,
        maxLines: multiline ? null : 1,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          helperText: help,
          helperMaxLines: 8,
        ),
      ),
    );
  }

  Widget _toggle({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListItem.toggle(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      onChanged: _loaded && !_service.busy && !_confirming
          ? (value) => setState(() => onChanged(value))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
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
    final protocol = runtime.mixedPort > 0 || runtime.socksPort > 0
        ? 'SOCKS5'
        : 'HTTP';
    final blocker = runtime.safeMode
        ? l.processProxySafeMode
        : !runtime.running
        ? l.processProxyCoreRequired
        : runtime.directMode
        ? l.processProxyDirectMode
        : runtime.systemProxy || runtime.tunEnabled
        ? l.processProxyTakeoverOff
        : port <= 0
        ? l.processProxyNoPort
        : null;
    final busy = _service.busy || _confirming || !_loaded;
    final canLaunch =
        (widget.isWindows ?? system.isWindows) &&
        !busy &&
        blocker == null &&
        _trusted;
    return CommonScaffold(
      title: l.processProxy,
      isLoading: !_loaded,
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: context.sectionsTopPadding,
            bottom: 16 + context.bottomInset,
          ),
          children: [
            generateSection(
              items: [
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.appsList),
                  title: Text(l.processProxyIntro),
                  subtitle: Text(
                    blocker ??
                        '${l.processProxyEndpoint}: $protocol · 127.0.0.1:$port',
                  ),
                ),
                if (_error case final error?)
                  ListItem(
                    title: Text(
                      l.processProxyFailed(processProxyErrorMessage(error, l)),
                      style: AppTextStyle.body
                          .of(context)
                          .copyWith(color: context.colorScheme.error),
                    ),
                  ),
              ],
            ),
            generateSection(
              title: l.processProxyBackend,
              items: [
                _field(
                  controller: _backend,
                  label: l.processProxyBackendPath,
                  onChanged: (_) => setState(() {
                    _trusted = false;
                    _prepareQuic = false;
                  }),
                ),
                ListItem(
                  title: Text(l.processProxySelectFile),
                  onTap: busy ? null : () => _pickExecutable(backend: true),
                ),
                _toggle(
                  title: l.processProxyTrust,
                  value: _trusted,
                  onChanged: (value) => _trusted = value,
                ),
              ],
              footer: l.processProxyBackendHelp,
            ),
            generateSection(
              title: l.processProxyTarget,
              items: [
                ListItem(
                  title: Text(l.processProxyApplications),
                  onTap: busy ? null : _openApplications,
                ),
                _field(
                  controller: _target,
                  label: l.processProxyTargetPath,
                  onChanged: (_) => setState(() => _prepareQuic = false),
                ),
                ListItem(
                  title: Text(l.processProxySelectFile),
                  onTap: busy ? null : () => _pickExecutable(backend: false),
                ),
                _field(
                  controller: _arguments,
                  label: l.processProxyArguments,
                  help: l.processProxyArgumentsHelp,
                  multiline: true,
                ),
                _field(
                  controller: _workingDirectory,
                  label: l.processProxyWorkingDirectory,
                  help: l.processProxyWorkingDirectoryHelp,
                ),
              ],
            ),
            generateSection(
              title: l.processProxyRules,
              items: [
                _field(
                  controller: _proxyOnly,
                  label: l.processProxyOnlyRules,
                  help: l.processProxyOnlyRulesHelp,
                  multiline: true,
                ),
                _field(
                  controller: _bypass,
                  label: l.processProxyBypass,
                  help: l.processProxyBypassHelp,
                  multiline: true,
                ),
                _toggle(
                  title: l.processProxyChildren,
                  value: _includeChildren,
                  onChanged: (value) => _includeChildren = value,
                ),
                _field(
                  controller: _childRules,
                  label: l.processProxyChildRules,
                  help: l.processProxyChildRulesHelp,
                  multiline: true,
                ),
                _toggle(
                  title: l.processProxyChildRuleInclude,
                  value: _childRuleInclude,
                  onChanged: (value) => _childRuleInclude = value,
                ),
                _toggle(
                  title: l.processProxyPrivate,
                  value: _bypassPrivate,
                  onChanged: (value) => _bypassPrivate = value,
                ),
                _toggle(
                  title: l.processProxyBlockUdp,
                  value: _blockUdp,
                  onChanged: (value) => _blockUdp = value,
                ),
                _toggle(
                  title: l.processProxyRemoteDns,
                  value: _remoteDns,
                  onChanged: (value) => _remoteDns = value,
                ),
                ListItem.toggle(
                  title: Text(l.processProxyPrepareQuic),
                  subtitle: Text(l.processProxyPrepareQuicHelp),
                  value: _prepareQuic,
                  onChanged: busy ? null : _setPrepareQuic,
                ),
              ],
              footer: l.processProxyDnsHelp,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: canLaunch ? _launch : null,
                    child: Text(l.processProxyLaunch),
                  ),
                  TextButton(
                    onPressed: busy ? null : _save,
                    child: Text(l.save),
                  ),
                  OutlinedButton(
                    onPressed: busy ? null : _openProfiles,
                    child: Text(l.processProxyProfiles),
                  ),
                ],
              ),
            ),
            generateSection(
              title: l.processProxySearch,
              items: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _query,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      labelText: l.processProxySearchHint,
                      suffixIcon: IconButton(
                        tooltip: l.processProxySearch,
                        onPressed:
                            _searching ||
                                !(widget.isWindows ?? system.isWindows)
                            ? null
                            : _search,
                        icon: const GlyphIcon(AppGlyphs.search),
                      ),
                    ),
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  )
                else if (_processes.isEmpty)
                  ListItem(title: Text(l.processProxyNoProcesses))
                else
                  for (final process in _processes)
                    ListItem(
                      title: Text('${process.name} · PID ${process.pid}'),
                      subtitle: Text(process.executable),
                      onTap: busy
                          ? null
                          : () => setState(() {
                              _target.text = process.executable;
                              _prepareQuic = false;
                            }),
                    ),
              ],
              footer: l.processProxySearchHelp,
            ),
            if (_service.sessions.isNotEmpty)
              generateSection(
                title: l.processProxySessions,
                items: [
                  for (final session in _service.sessions) ...[
                    ListItem(
                      title: Text(session.executable),
                      subtitle: Text(
                        '${_sessionStatus(session, l)} · PID ${session.backendPid}',
                      ),
                    ),
                    if (session.status == 'backendRunning')
                      if (session.nativeBridge)
                        ListItem.open(
                          title: Text(l.processProxyNativeWorkspace),
                          widget: ProcessProxyAdvancedView(
                            service: _service,
                            session: session,
                          ),
                        )
                      else
                        ListItem(
                          title: Text(l.processProxyOpenBackend),
                          onTap: () => _showBackend(session),
                        ),
                  ],
                ],
                footer: l.processProxySessionHelp,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    if (widget.serviceFactory != null) _service.dispose();
    _backend.dispose();
    _target.dispose();
    _arguments.dispose();
    _workingDirectory.dispose();
    _bypass.dispose();
    _proxyOnly.dispose();
    _childRules.dispose();
    _query.dispose();
    super.dispose();
  }
}
