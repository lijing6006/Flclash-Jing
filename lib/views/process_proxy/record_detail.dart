import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/record_detail.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy/payload.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';

class ProcessProxyRecordDetailView extends StatefulWidget {
  final ProcessProxyService service;
  final ProcessProxySession session;
  final ProcessProxyRecordInput input;
  final Future<ProcessProxyRecordDetail> Function(ProcessProxyRecordInput)?
  parse;

  const ProcessProxyRecordDetailView({
    super.key,
    required this.service,
    required this.session,
    required this.input,
    this.parse,
  });

  @override
  State<ProcessProxyRecordDetailView> createState() =>
      _ProcessProxyRecordDetailViewState();
}

class _ProcessProxyRecordDetailViewState
    extends State<ProcessProxyRecordDetailView> {
  ProcessProxyRecordDetail? _detail;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_parse());
  }

  @override
  void didUpdateWidget(covariant ProcessProxyRecordDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.input != widget.input ||
        oldWidget.session.id != widget.session.id) {
      _detail = null;
      _error = null;
      unawaited(_parse());
    }
  }

  Future<void> _parse() async {
    final generation = ++_generation;
    try {
      final detail =
          await (widget.parse?.call(widget.input) ??
              compute(parseProcessProxyRecordDetail, widget.input));
      if (mounted && generation == _generation) {
        setState(() => _detail = detail);
      }
    } catch (error) {
      if (mounted && generation == _generation) setState(() => _error = error);
    }
  }

  Widget _text(String text) => SelectableText(
    text,
    style: AppTextStyle.footnote.of(context).toJetBrainsMono,
  );

  Widget _message(String title, ProcessProxyHttpMessage message) {
    final l = context.appLocalizations;
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTextStyle.headline.of(context)),
            _text(message.summary),
            if (!message.complete) Text(l.processProxyMessageIncomplete),
            if (message.truncated) Text(l.processProxyDataTruncated),
            Text(l.processProxyHeaders),
            if (!message.headersAvailable)
              Text(l.processProxyHeadersUnavailable)
            else if (message.headers.isEmpty)
              Text(l.processProxyNoData)
            else
              _text(
                message.headers.map((p) => '${p.name}: ${p.value}').join('\n'),
              ),
            if (message.trailers.isNotEmpty) ...[
              Text(l.processProxyTrailers),
              _text(
                message.trailers.map((p) => '${p.name}: ${p.value}').join('\n'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _packets(ProcessProxyRecordDetail detail, int side) {
    final l = context.appLocalizations;
    final direction = detail.datagrams[side];
    final count = direction.reportedCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          side == 0 ? l.processProxyClient : l.processProxyServer,
          style: AppTextStyle.headline.of(context),
        ),
        if (count != null) Text(l.processProxyPacketCount(count)),
        if (!direction.indexed) Text(l.processProxyPacketsUnavailable),
        if (direction.truncated) Text(l.processProxyPacketLimit),
        if (direction.indexed && direction.packets.isEmpty)
          Text(l.processProxyNoData),
        for (var i = 0; i < direction.packets.length; i++)
          _packet(detail, direction.packets[i], side, i + 1),
      ],
    );
  }

  Widget _packet(
    ProcessProxyRecordDetail detail,
    ProcessProxyDatagram packet,
    int side,
    int number,
  ) {
    final l = context.appLocalizations;
    final title = l.processProxyPacketMetadata(
      number,
      packet.offset,
      packet.length,
    );
    if (packet.length == 0 || detail.identity.cacheId == null) {
      return ListItem(
        title: Text(title),
        subtitle: Text(l.processProxyEmptyPacket),
      );
    }
    return ListItem.open(
      title: Text(title),
      subtitle: Text(l.processProxyPacketPrefix(packet.previewLength)),
      widget: ProcessProxyPayloadView(
        service: widget.service,
        session: widget.session,
        runId: detail.identity.runId,
        cacheId: detail.identity.cacheId,
        initialOffset: packet.offset,
        readLength: packet.previewLength,
        initialClient: side == 0,
        boundedRange: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final detail = _detail;
    return CommonScaffold(
      title: l.processProxySemanticDetails,
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            context.sectionsTopPadding,
            16,
            16 + context.bottomInset,
          ),
          children: [
            Text(l.processProxySemanticHelp),
            if (_error case final error?)
              Text(processProxyErrorMessage(error, l)),
            if (detail == null && _error == null)
              const LinearProgressIndicator(),
            if (detail != null) ...[
              _text('${detail.protocol}\n${detail.context}'),
              if (detail.encrypted) Text(l.processProxyEncryptedPayload),
              if (detail.truncated) Text(l.processProxyDataTruncated),
              if (detail.request case final message?)
                _message(l.processProxyClient, message),
              for (final message in detail.informational)
                _message(l.processProxyInformational, message),
              if (detail.response case final message?)
                _message(l.processProxyServer, message),
              if (detail.datagrams.isNotEmpty) ...[
                Text(
                  l.processProxyDatagrams,
                  style: AppTextStyle.headline.of(context),
                ),
                Text(l.processProxyDatagramsHelp),
                _packets(detail, 0),
                _packets(detail, 1),
              ],
              if (detail.request == null &&
                  detail.response == null &&
                  detail.informational.isEmpty &&
                  detail.datagrams.isEmpty)
                Text(l.processProxySemanticUnavailable),
              if (detail.identity.cacheId != null)
                ListItem.open(
                  title: Text(l.processProxyPayloadViewer),
                  widget: ProcessProxyPayloadView(
                    service: widget.service,
                    session: widget.session,
                    runId: detail.identity.runId,
                    cacheId: detail.identity.cacheId,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
