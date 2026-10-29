import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';

enum _Panel { overview, traffic, recording, certificates }

typedef _Reply = ({String text, bool truncated});

_Reply _formatReply(Map<String, dynamic> response) {
  final encoded = const JsonEncoder.withIndent('  ').convert(response);
  final bytes = utf8.encode(encoded);
  const limit = 48 * 1024;
  return (
    text: bytes.length > limit
        ? utf8.decode(bytes.sublist(0, limit), allowMalformed: true)
        : encoded,
    truncated: bytes.length > limit,
  );
}

class ProcessProxyAdvancedView extends StatefulWidget {
  final ProcessProxyService service;
  final ProcessProxySession session;
  final Future<({String text, bool truncated})> Function(Map<String, dynamic>)?
  formatResponse;

  const ProcessProxyAdvancedView({
    super.key,
    required this.service,
    required this.session,
    this.formatResponse,
  });

  @override
  State<ProcessProxyAdvancedView> createState() =>
      _ProcessProxyAdvancedViewState();
}

class _ProcessProxyAdvancedViewState extends State<ProcessProxyAdvancedView> {
  final _recordingDirectory = TextEditingController();
  final _replayDirectory = TextEditingController();
  final _capacity = TextEditingController(text: '8192');
  final _reserve = TextEditingController(text: '512');
  final _query = TextEditingController(
    text: '{"type":"recording_page","offset":0,"limit":16}',
  );
  final _capture = TextEditingController(
    text:
        '{"entry_mib":32,"total_mib":512,"history_rows":512,'
        '"preview_kib":64,"decode_mib":4,"connections":128,'
        '"pending_requests":8,"udp_packets":256,"handshake_seconds":15}',
  );
  final Map<_Panel, _Reply> _responses = {};
  bool _busy = false;
  bool _decryptHttps = false;
  bool _decryptQuic = false;
  bool _recordDecryptHttps = false;
  bool _recordDecryptQuic = false;
  int _after = 0;
  int _logsAfter = 0;
  String? _runId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_run('status', panel: _Panel.overview));
  }

  Map<String, dynamic> _jsonObject(String text) {
    try {
      if (utf8.encode(text).length > 4096) {
        throw const FormatException();
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return decoded;
    } catch (_) {
      throw const ProcessProxyException('invalidQuery');
    }
  }

  Future<void> _run(
    String operation, {
    required _Panel panel,
    Map<String, dynamic> arguments = const {},
    String? confirmAction,
    bool certificateChange = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!widget.session.nativeBridge) {
        throw const ProcessProxyException('bridgeNotReady');
      }
      if (confirmAction != null) {
        final l = context.appLocalizations;
        final confirmed = await dialogs.showMessage(
          context: context,
          title: confirmAction,
          message: TextSpan(
            text: certificateChange
                ? '${l.processProxyConfirmCa(confirmAction)}\n\n${l.processProxyCaWarning}'
                : l.processProxyConfirmAdvanced(confirmAction),
          ),
          confirmText: l.confirm,
          destructive: certificateChange,
        );
        if (!mounted || confirmed != true) return;
      }
      final response = await widget.service.bridgeRequest(
        widget.session.id,
        operation,
        arguments,
      );
      if (!mounted) return;
      final formatted =
          await (widget.formatResponse?.call(response) ??
              compute(_formatReply, response));
      if (!mounted) return;
      setState(() {
        _responses[panel] = formatted;
        if (operation == 'monitor.start' || operation == 'recording.start') {
          _after = 0;
          _runId = null;
        }
        final runId = response['run_id'];
        var runChanged = false;
        if (runId is String && runId.isNotEmpty) {
          runChanged = _runId != null && _runId != runId;
          _runId = runId;
          if (runChanged) _after = 0;
        }
        final next = response['next'];
        if (next is int && next >= 0) {
          if (operation == 'logs') _logsAfter = next;
          if (operation == 'query' &&
              arguments['type'] == 'poll' &&
              !runChanged) {
            _after = next;
          }
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyCapture() async {
    try {
      await _run(
        'capture.options',
        panel: _Panel.traffic,
        arguments: {'settings': _jsonObject(_capture.text), 'confirm': true},
        confirmAction: context.appLocalizations.processProxyApplyCapture,
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _readQuery() async {
    try {
      final query = _jsonObject(_query.text);
      const types = {
        'stats',
        'poll',
        'cache_status',
        'cache_read',
        'cache_decode',
        'dns_read',
        'doh_read',
        'recording_status',
        'recording_page',
        'recording_detail',
        'monitor_status',
        'monitor_stop_status',
      };
      if (!types.contains(query['type'])) {
        throw const ProcessProxyException('invalidQuery');
      }
      await _run('query', panel: _Panel.recording, arguments: query);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _startRecording() async {
    try {
      final capacity = int.tryParse(_capacity.text);
      final reserve = int.tryParse(_reserve.text);
      if (capacity == null || reserve == null) {
        throw const ProcessProxyException('invalidQuery');
      }
      await _run(
        'recording.start',
        panel: _Panel.recording,
        arguments: {
          'directory': _recordingDirectory.text.trim(),
          'capacity_mib': capacity,
          'reserve_mib': reserve,
          'decrypt_https': _recordDecryptHttps,
          'decrypt_quic': _recordDecryptQuic,
          'confirm': true,
        },
        confirmAction: context.appLocalizations.processProxyStartRecording,
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Widget _button(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: _busy ? null : onPressed,
      child: Text(text),
    );
  }

  Widget _actions(List<Widget> actions) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Wrap(spacing: 12, runSpacing: 12, children: actions),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool multiline = false,
    String? help,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: !_busy,
        autocorrect: false,
        maxLines: multiline ? null : 1,
        decoration: InputDecoration(
          labelText: label,
          helperText: help,
          helperMaxLines: 8,
        ),
      ),
    );
  }

  Widget _result(_Panel panel) {
    final l = context.appLocalizations;
    final response = _responses[panel];
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (response?.truncated == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l.processProxyDataTruncated),
              ),
            SelectableText(
              response?.text ?? l.processProxyNoData,
              style: AppTextStyle.footnote.of(context).toJetBrainsMono,
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(BuildContext context, List<Widget> children) => ListView(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: 16 + context.bottomInset,
    ),
    children: children,
  );

  Widget _overview(BuildContext context) {
    final l = context.appLocalizations;
    return _page(context, [
      SelectableText(widget.session.executable),
      Text('PID ${widget.session.targetPid ?? widget.session.backendPid}'),
      _actions([
        _button(
          l.processProxyStatus,
          () => _run('status', panel: _Panel.overview),
        ),
        _button(
          l.logs,
          () => _run(
            'logs',
            panel: _Panel.overview,
            arguments: {'after': _logsAfter, 'limit': 64},
          ),
        ),
        _button(
          l.processProxyStats,
          () => _run(
            'query',
            panel: _Panel.overview,
            arguments: {'type': 'stats'},
          ),
        ),
      ]),
      _result(_Panel.overview),
    ]);
  }

  Widget _traffic(BuildContext context) {
    final l = context.appLocalizations;
    return _page(context, [
      generateSection(
        title: l.processProxyMonitor,
        items: [
          ListItem.toggle(
            title: Text(l.processProxyDecryptHttps),
            value: _decryptHttps,
            onChanged: _busy
                ? null
                : (value) => setState(() => _decryptHttps = value),
          ),
          ListItem.toggle(
            title: Text(l.processProxyDecryptQuic),
            value: _decryptQuic,
            onChanged: _busy
                ? null
                : (value) => setState(() => _decryptQuic = value),
          ),
        ],
        footer: l.processProxyCapturePrivacy,
      ),
      _actions([
        _button(
          l.processProxyStartMonitor,
          () => _run(
            'monitor.start',
            panel: _Panel.traffic,
            arguments: {
              'decrypt_https': _decryptHttps,
              'decrypt_quic': _decryptQuic,
              'confirm': true,
            },
            confirmAction: l.processProxyStartMonitor,
          ),
        ),
        _button(
          l.processProxyStopMonitor,
          () => _run(
            'monitor.stop',
            panel: _Panel.traffic,
            confirmAction: l.processProxyStopMonitor,
          ),
        ),
        _button(
          l.processProxyReadNext,
          () => _run(
            'query',
            panel: _Panel.traffic,
            arguments: {
              'type': 'poll',
              'after': _after,
              'limit': 16,
              'live_preview': true,
            },
          ),
        ),
        _button(
          l.processProxyStatus,
          () => _run(
            'query',
            panel: _Panel.traffic,
            arguments: {'type': 'monitor_status'},
          ),
        ),
      ]),
      _result(_Panel.traffic),
      const SizedBox(height: 16),
      _field(_capture, l.processProxyCaptureOptions, multiline: true),
      _actions([_button(l.processProxyApplyCapture, _applyCapture)]),
    ]);
  }

  Widget _recording(BuildContext context) {
    final l = context.appLocalizations;
    return _page(context, [
      Text(l.processProxyCapturePrivacy),
      generateSection(
        items: [
          ListItem.toggle(
            title: Text(l.processProxyDecryptHttps),
            value: _recordDecryptHttps,
            onChanged: _busy
                ? null
                : (value) => setState(() => _recordDecryptHttps = value),
          ),
          ListItem.toggle(
            title: Text(l.processProxyDecryptQuic),
            value: _recordDecryptQuic,
            onChanged: _busy
                ? null
                : (value) => setState(() => _recordDecryptQuic = value),
          ),
        ],
      ),
      _field(
        _recordingDirectory,
        '${l.processProxyRecording} · ${l.processProxyDirectory}',
      ),
      _field(_capacity, l.processProxyRecordingCapacity),
      _field(_reserve, l.processProxyRecordingReserve),
      _actions([
        _button(l.processProxyStartRecording, _startRecording),
        _button(
          l.processProxyStopRecording,
          () => _run(
            'recording.stop',
            panel: _Panel.recording,
            confirmAction: l.processProxyStopRecording,
          ),
        ),
        _button(
          l.processProxyStatus,
          () => _run(
            'query',
            panel: _Panel.recording,
            arguments: {'type': 'recording_status'},
          ),
        ),
      ]),
      _field(
        _replayDirectory,
        '${l.processProxyReplay} · ${l.processProxyDirectory}',
      ),
      _actions([
        _button(
          l.processProxyOpenReplay,
          () => _run(
            'replay.open',
            panel: _Panel.recording,
            arguments: {
              'directory': _replayDirectory.text.trim(),
              'confirm': true,
            },
            confirmAction: l.processProxyOpenReplay,
          ),
        ),
        _button(
          l.processProxyCloseReplay,
          () => _run(
            'replay.close',
            panel: _Panel.recording,
            confirmAction: l.processProxyCloseReplay,
          ),
        ),
      ]),
      _field(
        _query,
        l.processProxyReadQuery,
        multiline: true,
        help: l.processProxyReadQueryHelp,
      ),
      _actions([_button(l.processProxyReadDetails, _readQuery)]),
      _result(_Panel.recording),
    ]);
  }

  Widget _certificates(BuildContext context) {
    final l = context.appLocalizations;
    return _page(context, [
      Text(l.processProxyCaWarning),
      _actions([
        _button(
          l.processProxyRefresh,
          () => _run('ca.query', panel: _Panel.certificates),
        ),
        for (final action in [
          ('ca.initialize', l.processProxyInitializeCa),
          ('ca.trust', l.processProxyTrustCa),
          ('ca.remove', l.processProxyRemoveCa),
        ])
          _button(
            action.$2,
            () => _run(
              action.$1,
              panel: _Panel.certificates,
              arguments: {'scope': 'current-user', 'confirm': true},
              confirmAction: action.$2,
              certificateChange: true,
            ),
          ),
      ]),
      _result(_Panel.certificates),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return DefaultTabController(
      length: 4,
      child: CommonScaffold(
        title: l.processProxyNativeWorkspace,
        body: Builder(
          builder: (context) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.processProxyExperimentalHint),
              ),
              if (_error case final error?)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    processProxyErrorMessage(error, l),
                    style: AppTextStyle.body
                        .of(context)
                        .copyWith(color: context.colorScheme.error),
                  ),
                ),
              if (_busy) const LinearProgressIndicator(),
              TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l.processProxyOverview),
                  Tab(text: l.traffic),
                  Tab(text: l.processProxyRecording),
                  Tab(text: l.processProxyCertificates),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _overview(context),
                    _traffic(context),
                    _recording(context),
                    _certificates(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordingDirectory.dispose();
    _replayDirectory.dispose();
    _capacity.dispose();
    _reserve.dispose();
    _query.dispose();
    _capture.dispose();
    super.dispose();
  }
}
