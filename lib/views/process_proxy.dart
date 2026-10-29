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
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProcessProxyView extends ConsumerStatefulWidget {
  final ProcessProxyService Function()? serviceFactory;
  final bool? isWindows;

  const ProcessProxyView({super.key, this.serviceFactory, this.isWindows});

  @override
  ConsumerState<ProcessProxyView> createState() => _ProcessProxyViewState();
}

class _ProcessProxyViewState extends ConsumerState<ProcessProxyView> {
  late final _service = widget.serviceFactory?.call() ?? ProcessProxyService();
  final _backend = TextEditingController();
  final _target = TextEditingController();
  final _arguments = TextEditingController(text: '[]');
  final _bypass = TextEditingController();
  final _query = TextEditingController();
  bool _loaded = false;
  bool _searching = false;
  bool _confirming = false;
  bool _includeChildren = true;
  bool _bypassPrivate = true;
  bool _blockUdp = true;
  bool _remoteDns = false;
  bool _trusted = false;
  bool _decryptHttps = false;
  bool _decryptQuic = false;
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
        _bypass.text = saved.bypassRules;
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

  ProcessProxyRuntime _runtime() {
    final config = ref.read(patchClashConfigProvider);
    final network = ref.read(networkSettingProvider);
    final authentication = network.authentication;
    return ProcessProxyRuntime(
      running:
          ref.read(coreStatusProvider) == CoreStatus.connected &&
          ref.read(runTimeProvider) != null,
      safeMode: ref.read(safeModeProvider),
      systemProxy: network.systemProxy,
      tunEnabled: config.tun.enable,
      mixedPort: config.mixedPort,
      socksPort: config.socksPort,
      httpPort: config.port,
      username: authentication.enable ? authentication.username : '',
      password: authentication.enable ? authentication.password : '',
    );
  }

  ProcessProxyLaunchRequest _request() {
    final arguments = parseProcessArguments(_arguments.text);
    return ProcessProxyLaunchRequest(
      backendPath: _backend.text.trim(),
      executable: _target.text.trim(),
      arguments: arguments,
      bypassRules: _bypass.text,
      includeChildren: _includeChildren,
      bypassPrivateNetworks: _bypassPrivate,
      blockUdp: _blockUdp,
      remoteDns: _remoteDns,
      trustedBackend: _trusted,
      decryptHttps: _decryptHttps,
      decryptQuic: _decryptQuic,
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
      await _service.launch(request: request, runtime: () async => _runtime());
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
                  onChanged: (_) => setState(() => _trusted = false),
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
                _field(controller: _target, label: l.processProxyTargetPath),
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
              ],
            ),
            generateSection(
              title: l.processProxyRules,
              items: [
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
                          : () => setState(
                              () => _target.text = process.executable,
                            ),
                    ),
              ],
              footer: l.processProxySearchHelp,
            ),
            generateSection(
              title: l.processProxyAdvanced,
              items: [
                _toggle(
                  title: l.processProxyDecryptHttps,
                  value: _decryptHttps,
                  onChanged: (value) => _decryptHttps = value,
                ),
                _toggle(
                  title: l.processProxyDecryptQuic,
                  value: _decryptQuic,
                  onChanged: (value) => _decryptQuic = value,
                ),
              ],
              footer: l.processProxyAdvancedHelp,
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
    _service.dispose();
    _backend.dispose();
    _target.dispose();
    _arguments.dispose();
    _bypass.dispose();
    _query.dispose();
    super.dispose();
  }
}
