import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/traffic.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';

class ProcessProxyPayloadView extends StatefulWidget {
  final ProcessProxyService service;
  final ProcessProxySession session;
  final String? runId;
  final int? cacheId;
  final Future<ProcessProxyPayloadPreview> Function(Map<String, dynamic>)?
  format;

  const ProcessProxyPayloadView({
    super.key,
    required this.service,
    required this.session,
    this.runId,
    this.cacheId,
    this.format,
  });

  @override
  State<ProcessProxyPayloadView> createState() =>
      _ProcessProxyPayloadViewState();
}

class _ProcessProxyPayloadViewState extends State<ProcessProxyPayloadView> {
  late final _runId = TextEditingController(text: widget.runId ?? '');
  late final _cacheId = TextEditingController(
    text: widget.cacheId?.toString() ?? '',
  );
  final _offset = TextEditingController(text: '0');
  bool _client = true;
  bool _busy = false;
  bool _hex = false;
  Object? _error;
  ProcessProxyPayloadPreview? _preview;

  Future<void> _read(String type) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final cacheId = int.tryParse(_cacheId.text);
      final offset = int.tryParse(_offset.text);
      final runId = _runId.text.trim();
      if (cacheId == null ||
          cacheId < 1 ||
          offset == null ||
          offset < 0 ||
          runId.isEmpty ||
          runId.length > 256) {
        throw const ProcessProxyException('invalidQuery');
      }
      final response = await widget.service.bridgeRequest(
        widget.session.id,
        'query',
        {
          'type': type,
          'run_id': runId,
          'cache_id': cacheId,
          'direction': _client ? 'client' : 'server',
          if (type == 'cache_read' || type == 'dns_read') ...{
            'offset': offset,
            'length': type == 'dns_read' ? 65535 : 16384,
          },
          if (type == 'cache_decode' || type == 'doh_read')
            'preview_bytes': 16384,
        },
      );
      if (!mounted) return;
      final preview =
          await (widget.format?.call(response) ??
              compute(formatProcessProxyPayload, response));
      if (mounted) setState(() => _preview = preview);
    } catch (error) {
      if (mounted)
        setState(() {
          _error = error;
          _preview = null;
        });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      enabled: !_busy,
      autocorrect: false,
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final preview = _preview;
    return CommonScaffold(
      title: l.processProxyPayloadViewer,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.bottomInset),
        children: [
          Text(l.processProxyPayloadHelp),
          _field(_runId, l.processProxyRunId),
          _field(_cacheId, l.processProxyCacheId),
          _field(_offset, l.processProxyOffset),
          ListItem.toggle(
            title: Text(_client ? l.processProxyClient : l.processProxyServer),
            value: _client,
            onChanged: _busy
                ? null
                : (value) => setState(() => _client = value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final action in [
                  (l.processProxyPayloadRead, 'cache_read'),
                  (l.processProxyPayloadDecode, 'cache_decode'),
                  (l.processProxyPayloadDns, 'dns_read'),
                  (l.processProxyPayloadDoh, 'doh_read'),
                ])
                  OutlinedButton(
                    onPressed: _busy ? null : () => _read(action.$2),
                    child: Text(action.$1),
                  ),
              ],
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error case final error?)
            Text(
              processProxyErrorMessage(error, l),
              style: AppTextStyle.body
                  .of(context)
                  .copyWith(color: context.colorScheme.error),
            ),
          if (preview?.truncated == true) Text(l.processProxyDataTruncated),
          if (preview?.incomplete == true)
            Text(l.processProxyPayloadUnavailable),
          ListItem.toggle(
            title: Text(l.processProxyHex),
            value: _hex,
            onChanged: (value) => setState(() => _hex = value),
          ),
          CommonCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                preview == null
                    ? l.processProxyNoData
                    : (_hex ? preview.hex : preview.raw),
                style: AppTextStyle.footnote.of(context).toJetBrainsMono,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CommonCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                preview?.metadata ?? l.processProxyNoData,
                style: AppTextStyle.footnote.of(context).toJetBrainsMono,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _runId.dispose();
    _cacheId.dispose();
    _offset.dispose();
    super.dispose();
  }
}
