import 'dart:convert';
import 'dart:io';

import 'policy.dart';
import 'profiles.dart';

Future<String> readProcessProxyProfilesFile(File file) async {
  if (await FileSystemEntity.type(file.path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw const ProcessProxyException('profilesStorage');
  }
  final handle = await file.open();
  try {
    if (await handle.length() > processProxyProfilesMaxBytes) {
      throw const ProcessProxyException('profilesTooLarge');
    }
    final bytes = await handle.read(processProxyProfilesMaxBytes + 1);
    if (bytes.length > processProxyProfilesMaxBytes) {
      throw const ProcessProxyException('profilesTooLarge');
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const ProcessProxyException('profilesInvalid');
    }
  } finally {
    await handle.close();
  }
}

class FileProcessProxyProfileStorage implements ProcessProxyProfileStorage {
  final Future<Directory> Function() directory;

  FileProcessProxyProfileStorage({required this.directory});

  Future<File> _file() async {
    final root = await directory();
    final file = File(
      '${root.path}${Platform.pathSeparator}process-proxy'
      '${Platform.pathSeparator}profiles.json',
    );
    final type = await FileSystemEntity.type(
      file.parent.path,
      followLinks: false,
    );
    if (type != FileSystemEntityType.directory &&
        type != FileSystemEntityType.notFound) {
      throw const ProcessProxyException('profilesStorage');
    }
    return file;
  }

  @override
  Future<String?> read() async {
    final file = await _file();
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
        FileSystemEntityType.notFound) {
      return null;
    }
    return readProcessProxyProfilesFile(file);
  }

  @override
  Future<void> write(String text) async {
    if (utf8.encode(text).length > processProxyProfilesMaxBytes) {
      throw const ProcessProxyException('profilesTooLarge');
    }
    final file = await _file();
    await file.parent.create(recursive: true);
    final pending = File('${file.path}.pending');
    final backup = File('${file.path}.backup');
    for (final path in [file.path, pending.path, backup.path]) {
      final type = await FileSystemEntity.type(path, followLinks: false);
      if (type != FileSystemEntityType.file &&
          type != FileSystemEntityType.notFound) {
        throw const ProcessProxyException('profilesStorage');
      }
    }
    try {
      await pending.writeAsString(text, flush: true);
      if (await file.exists()) {
        if (await file.length() > processProxyProfilesMaxBytes) {
          throw const ProcessProxyException('profilesTooLarge');
        }
        await file.copy(backup.path);
      }
      await pending.rename(file.path);
    } on Object {
      if (!await file.exists() && await backup.exists()) {
        await backup.copy(file.path);
      }
      rethrow;
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  }
}
