import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:material_ui/material_ui.dart';

class ProcessProxyApplicationsView extends StatefulWidget {
  final ProcessProxyService service;

  const ProcessProxyApplicationsView({super.key, required this.service});

  @override
  State<ProcessProxyApplicationsView> createState() =>
      _ProcessProxyApplicationsViewState();
}

class _ProcessProxyApplicationsViewState
    extends State<ProcessProxyApplicationsView> {
  final _query = TextEditingController();
  List<ProcessProxyApplication> _applications = [];
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  Future<void> _search() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final applications = await widget.service.searchApplications(_query.text);
      if (mounted) setState(() => _applications = applications);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonScaffold(
      title: l.processProxyApplications,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.bottomInset),
        children: [
          Text(l.processProxyApplicationsHelp),
          const SizedBox(height: 16),
          TextFormField(
            controller: _query,
            enabled: !_busy,
            autocorrect: false,
            decoration: InputDecoration(labelText: l.processProxySearch),
            onFieldSubmitted: (_) => unawaited(_search()),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _search,
            child: Text(l.processProxySearch),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error case final error?)
            Text(
              processProxyErrorMessage(error, l),
              style: AppTextStyle.body
                  .of(context)
                  .copyWith(color: context.colorScheme.error),
            ),
          if (!_busy && _error == null && _applications.isEmpty)
            Text(l.processProxyNoData),
          for (final application in _applications)
            ListItem(
              title: Text(application.name),
              subtitle: Text(
                '${application.executable}\n${application.source}',
              ),
              onTap: _busy
                  ? null
                  : () => Navigator.of(context).pop(application),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }
}
