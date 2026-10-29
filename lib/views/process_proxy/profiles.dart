import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/process_proxy/policy.dart';
import 'package:fl_clash/services/process_proxy/profile_storage.dart';
import 'package:fl_clash/services/process_proxy/profiles.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/process_proxy_error.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

final _defaultRepository = ProcessProxyProfilesRepository(
  FileProcessProxyProfileStorage(directory: getApplicationSupportDirectory),
);

class ProcessProxyProfilesView extends StatefulWidget {
  final ProcessProxyLaunchRequest? currentRequest;
  final ProcessProxyProfilesRepository? repository;
  final Future<String?> Function()? importText;
  final Future<void> Function(String text)? exportText;

  const ProcessProxyProfilesView({
    super.key,
    this.currentRequest,
    this.repository,
    this.importText,
    this.exportText,
  });

  @override
  State<ProcessProxyProfilesView> createState() =>
      _ProcessProxyProfilesViewState();
}

class _ProcessProxyProfilesViewState extends State<ProcessProxyProfilesView> {
  late final _repository = widget.repository ?? _defaultRepository;
  List<ProcessProxyProfile> _profiles = [];
  bool _busy = false;
  bool _working = false;
  bool _ready = false;
  bool _includeArguments = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _working = false;
        });
      }
    }
  }

  Future<T> _work<T>(Future<T> Function() action) async {
    if (mounted) setState(() => _working = true);
    try {
      return await action();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _load() => _perform(() async {
    final profiles = await _work(_repository.load);
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _ready = true;
      });
    }
  });

  Future<String?> _name(String value) {
    final l = context.appLocalizations;
    return dialogs.showCommonDialog<String>(
      context: context,
      child: InputDialog(
        title: value.isEmpty ? l.processProxyProfilesSaveCurrent : l.edit,
        labelText: l.name,
        value: value,
        maxLength: 64,
        keyboardType: TextInputType.text,
        validator: (value) {
          final name = value?.trim() ?? '';
          if (name.isEmpty || name.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
            return l.processProxyProfilesInvalid;
          }
          return null;
        },
      ),
    );
  }

  Future<void> _store(List<ProcessProxyProfile> profiles) async {
    await _work(() => _repository.save(profiles));
    if (mounted) setState(() => _profiles = profiles);
  }

  Future<void> _saveCurrent() => _perform(() async {
    final request = widget.currentRequest;
    if (request == null) return;
    final name = await _name('');
    if (!mounted || name == null) return;
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final profile = ProcessProxyProfile(
      id: id,
      name: name.trim(),
      request: request,
    );
    await _store(mergeProcessProxyProfiles(_profiles, [profile]));
  });

  Future<void> _rename(ProcessProxyProfile profile) => _perform(() async {
    final name = await _name(profile.name);
    if (!mounted || name == null) return;
    await _store([
      for (final item in _profiles)
        if (item.id == profile.id)
          ProcessProxyProfile(
            id: item.id,
            name: name.trim(),
            request: item.request,
          )
        else
          item,
    ]);
  });

  Future<void> _delete(ProcessProxyProfile profile) => _perform(() async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: l.delete,
      message: TextSpan(text: l.deleteTip(profile.name)),
      confirmText: l.delete,
      destructive: true,
    );
    if (!mounted || confirmed != true) return;
    await _store(_profiles.where((item) => item.id != profile.id).toList());
  });

  Future<void> _select(ProcessProxyProfile profile) => _perform(() async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: profile.name,
      message: TextSpan(text: l.processProxyProfilesLoadConfirm(profile.name)),
    );
    if (mounted && confirmed == true) {
      Navigator.of(context).pop(profile.request);
    }
  });

  Future<String?> _readImport() async {
    if (widget.importText case final read?) return read();
    final selected = await picker.pickerFile();
    if (selected == null) return null;
    final path = selected.path;
    if (path == null) throw const ProcessProxyException('profilesStorage');
    return _work(() => readProcessProxyProfilesFile(File(path)));
  }

  Future<void> _import() => _perform(() async {
    final text = await _readImport();
    if (!mounted || text == null) return;
    final incoming = await _work(() => _repository.decodeImport(text));
    if (!mounted) return;
    if (incoming.isEmpty) throw const ProcessProxyException('profilesInvalid');
    final merged = mergeProcessProxyProfiles(_profiles, incoming);
    final l = context.appLocalizations;
    final preview = incoming
        .map((profile) => '${profile.name}\n${profile.request.executable}')
        .join('\n\n');
    final confirmed = await dialogs.showMessage(
      context: context,
      title: l.processProxyProfilesImport,
      message: TextSpan(
        text:
            '${l.processProxyProfilesImportConfirm(incoming.length)}\n\n$preview',
      ),
    );
    if (!mounted || confirmed != true) return;
    await _store(merged);
  });

  Future<void> _export() => _perform(() async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: l.processProxyProfilesExport,
      message: TextSpan(text: l.processProxyProfilesExportConfirm),
    );
    if (!mounted || confirmed != true) return;
    final profiles = _profiles;
    final includeArguments = _includeArguments;
    final text = await _work(
      () => _repository.exportProfiles(
        profiles,
        includeArguments: includeArguments,
      ),
    );
    if (!mounted) return;
    if (widget.exportText case final write?) {
      await _work(() => write(text));
    } else {
      await picker.saveFile(
        'Flclash-Jing-process-profiles.json',
        Uint8List.fromList(utf8.encode(text)),
      );
    }
  });

  String _errorMessage(Object error) {
    final l = context.appLocalizations;
    if (error is! ProcessProxyException) return l.processProxyProfilesStorage;
    return switch (error.code) {
      'profilesInvalid' => l.processProxyProfilesInvalid,
      'profilesTooLarge' => l.processProxyProfilesTooLarge,
      'profilesLimit' => l.processProxyProfilesLimit,
      'profilesConflict' => l.processProxyProfilesConflict,
      'profilesStorage' => l.processProxyProfilesStorage,
      'profilesBusy' => l.processProxyErrorBusy,
      _ => processProxyErrorMessage(error, l),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final enabled = _ready && !_busy;
    return CommonScaffold(
      title: l.processProxyProfiles,
      isLoading: _working && !_ready,
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: context.sectionsTopPadding,
            bottom: 16 + context.bottomInset,
          ),
          children: [
            Text(l.processProxyProfilesHelp),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _errorMessage(error),
                  style: AppTextStyle.body
                      .of(context)
                      .copyWith(color: context.colorScheme.error),
                ),
              ),
            if (!_ready && !_busy)
              TextButton(onPressed: _load, child: Text(l.retry)),
            if (_working && _ready) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    key: const ValueKey('process-proxy-save-profile'),
                    onPressed: enabled && widget.currentRequest != null
                        ? _saveCurrent
                        : null,
                    child: Text(l.processProxyProfilesSaveCurrent),
                  ),
                  OutlinedButton(
                    onPressed: enabled ? _import : null,
                    child: Text(l.processProxyProfilesImport),
                  ),
                  OutlinedButton(
                    onPressed: enabled && _profiles.isNotEmpty ? _export : null,
                    child: Text(l.processProxyProfilesExport),
                  ),
                ],
              ),
            ),
            if (_ready)
              generateSection(
                items: [
                  if (_profiles.isEmpty)
                    ListItem(title: Text(l.processProxyProfilesEmpty))
                  else
                    for (final profile in _profiles)
                      ContextMenuRegion(
                        menuItems: enabled
                            ? [
                                CommonPopupMenuItem(
                                  glyph: AppGlyphs.edit,
                                  label: l.edit,
                                  onPressed: () => _rename(profile),
                                ),
                                CommonPopupMenuItem(
                                  glyph: AppGlyphs.delete,
                                  label: l.delete,
                                  danger: true,
                                  onPressed: () => _delete(profile),
                                ),
                              ]
                            : null,
                        child: ListItem(
                          title: Text(profile.name),
                          subtitle: Text(profile.request.executable),
                          onTap: enabled ? () => _select(profile) : null,
                        ),
                      ),
                ],
              ),
            generateSection(
              items: [
                ListItem.toggle(
                  title: Text(l.processProxyProfilesIncludeArguments),
                  value: _includeArguments,
                  onChanged: enabled
                      ? (value) => setState(() => _includeArguments = value)
                      : null,
                ),
              ],
              footer: l.processProxyProfilesExportHelp,
            ),
          ],
        ),
      ),
    );
  }
}
