import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/services/process_proxy/recording_browser.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy/payload.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';

class ProcessProxyRecordingBrowser extends StatefulWidget {
  final ProcessProxyService service;
  final ProcessProxySession session;
  final Future<ProcessProxyRecordingPage> Function(Map<String, dynamic>)?
  parsePage;
  final Future<ProcessProxyRecordingText> Function(
    ({Map<String, dynamic> response, ProcessProxyRecordingRow row}),
  )?
  formatDetail;

  const ProcessProxyRecordingBrowser({
    super.key,
    required this.service,
    required this.session,
    this.parsePage,
    this.formatDetail,
  });

  @override
  State<ProcessProxyRecordingBrowser> createState() =>
      _ProcessProxyRecordingBrowserState();
}

class _ProcessProxyRecordingBrowserState
    extends State<ProcessProxyRecordingBrowser> {
  final _filter = TextEditingController();
  final _history = <int>[];
  int _protocol = 0;
  int _limit = 16;
  int _generation = 0;
  bool _busy = false;
  Object? _error;
  ProcessProxyRecordingPage? _page;
  ProcessProxyRecordingRow? _selected;
  ProcessProxyRecordingText? _detail;

  @override
  void initState() {
    super.initState();
    unawaited(_load(0, reset: true));
  }

  @override
  void didUpdateWidget(covariant ProcessProxyRecordingBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id ||
        oldWidget.service != widget.service) {
      _generation++;
      _busy = false;
      _page = null;
      _selected = null;
      _detail = null;
      _history.clear();
      unawaited(_load(0, reset: true));
    }
  }

  bool _current(int generation) => mounted && generation == _generation;

  void _filtersChanged() {
    if (_busy) return;
    setState(() {
      _page = null;
      _selected = null;
      _detail = null;
      _error = null;
      _history.clear();
    });
  }

  Future<void> _load(
    int offset, {
    bool reset = false,
    bool back = false,
  }) async {
    if (_busy) return;
    final generation = ++_generation;
    final previous = _page;
    final query = ProcessProxyRecordingQuery(
      offset: offset,
      limit: _limit,
      filter: _filter.text.trim(),
      protocol: _protocol,
    );
    setState(() {
      _busy = true;
      _error = null;
      _selected = null;
      _detail = null;
    });
    try {
      final response = await widget.service.bridgeRequest(
        widget.session.id,
        'query',
        query.toJson(),
      );
      if (!_current(generation)) return;
      final page =
          await (widget.parsePage?.call(response) ??
              compute(parseProcessProxyRecordingPage, response));
      if (!_current(generation)) return;
      validateProcessProxyRecordingPage(
        page,
        query,
        previousRunId: reset ? null : previous?.runId,
      );
      setState(() {
        if (reset) {
          _history.clear();
        } else if (back) {
          if (_history.isNotEmpty) _history.removeLast();
        } else if (previous != null) {
          _history.add(previous.offset);
        }
        _page = page;
      });
    } catch (error) {
      if (_current(generation)) {
        setState(() {
          _error = error;
          if (error is ProcessProxyException &&
              error.code == 'recordingChanged') {
            _page = null;
            _history.clear();
          }
        });
      }
    } finally {
      if (_current(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _readDetail(ProcessProxyRecordingRow row) async {
    if (_busy || _page?.runId != row.runId) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _selected = row;
      _detail = null;
    });
    try {
      final response = await widget.service.bridgeRequest(
        widget.session.id,
        'query',
        row.detailQuery(),
      );
      if (!_current(generation)) return;
      final input = (response: response, row: row);
      final detail =
          await (widget.formatDetail?.call(input) ??
              compute(formatProcessProxyRecordingDetail, input));
      if (_current(generation) && _page?.runId == row.runId) {
        setState(() => _detail = detail);
      }
    } catch (error) {
      if (_current(generation)) setState(() => _error = error);
    } finally {
      if (_current(generation)) setState(() => _busy = false);
    }
  }

  Widget _result(ProcessProxyRecordingText text) => CommonCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (text.truncated)
            Text(context.appLocalizations.processProxyDataTruncated),
          SelectableText(
            text.text,
            style: AppTextStyle.footnote.of(context).toJetBrainsMono,
          ),
        ],
      ),
    ),
  );

  String _errorMessage(Object error) {
    final l = context.appLocalizations;
    if (error is ProcessProxyException) {
      if (error.code == 'recordingChanged')
        return l.processProxyRecordingChanged;
      if (error.code == 'recordingQueryInvalid')
        return l.processProxyRecordingQueryInvalid;
    }
    return processProxyErrorMessage(error, l);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final page = _page;
    final selected = _selected;
    final detail = _detail;
    final protocols = [
      l.processProxyRecordingAll,
      'HTTP',
      'TCP',
      'UDP',
      'TLS',
      'DNS',
      'QUIC',
    ];
    return CommonScaffold(
      title: l.processProxyRecordingBrowser,
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: context.sectionsTopPadding,
            bottom: 16 + context.bottomInset,
          ),
          children: [
            Text(l.processProxyRecordingBrowserHelp),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextFormField(
                controller: _filter,
                enabled: !_busy,
                autocorrect: false,
                maxLength: 256,
                decoration: InputDecoration(labelText: l.filter),
                onChanged: (_) => _filtersChanged(),
                onFieldSubmitted: (_) => unawaited(_load(0, reset: true)),
              ),
            ),
            IgnorePointer(
              ignoring: _busy,
              child: generateSection(
                items: [
                  ListItem<int>.options(
                    title: Text(l.protocol),
                    options: const [0, 1, 2, 3, 4, 5, 6],
                    value: _protocol,
                    textBuilder: (value) => protocols[value],
                    onChanged: (value) {
                      if (_busy) return;
                      _protocol = value;
                      _filtersChanged();
                    },
                  ),
                  ListItem<int>.options(
                    title: Text(l.processProxyRecordingPageSize),
                    options: const [1, 4, 8, 16, 32, 64],
                    value: _limit,
                    textBuilder: (value) => '$value',
                    onChanged: (value) {
                      if (_busy) return;
                      _limit = value;
                      _filtersChanged();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: _busy ? null : () => _load(0, reset: true),
                    child: Text(l.processProxyRefresh),
                  ),
                  OutlinedButton(
                    onPressed: !_busy && _history.isNotEmpty
                        ? () => _load(_history.last, back: true)
                        : null,
                    child: Text(l.processProxyRecordingPrevious),
                  ),
                  OutlinedButton(
                    onPressed: !_busy && page != null && page.hasNext
                        ? () => _load(page.nextOffset)
                        : null,
                    child: Text(l.processProxyRecordingNext),
                  ),
                ],
              ),
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error case final error?)
              Text(
                _errorMessage(error),
                style: AppTextStyle.body
                    .of(context)
                    .copyWith(color: context.colorScheme.error),
              ),
            if (page != null) ...[
              Text(
                l.processProxyRecordingPageSummary(
                  page.rows.isEmpty ? page.offset : page.offset + 1,
                  page.nextOffset,
                  page.total,
                  page.all,
                ),
              ),
              Text(l.processProxyRecordingWarnings(page.warnings)),
              if (page.stalled) Text(l.processProxyRecordingStalled),
              if (page.rows.isEmpty) Text(l.processProxyNoData),
              generateSection(
                items: [
                  for (final row in page.rows)
                    ListItem(
                      title: Text(row.label),
                      subtitle: Text(row.context),
                      onTap: _busy ? null : () => _readDetail(row),
                    ),
                ],
              ),
              _result(page.metadata),
            ],
            if (selected != null && detail != null) ...[
              const SizedBox(height: 16),
              Text(l.processProxyRecordingDetails),
              if (selected.cacheId != null)
                ListItem.open(
                  title: Text(l.processProxyPayloadViewer),
                  widget: ProcessProxyPayloadView(
                    service: widget.service,
                    session: widget.session,
                    runId: selected.runId,
                    cacheId: selected.cacheId,
                  ),
                )
              else
                Text(l.processProxyRecordingNoPayload),
              _result(detail),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    _filter.dispose();
    super.dispose();
  }
}
