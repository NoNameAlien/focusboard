import 'dart:convert';
import 'dart:io';

import 'app_storage.dart';

Future<AppStorage> createAppStorage() async {
  final directory = await _resolveStorageDirectory();
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return _IoAppStorage(directory);
}

class _IoAppStorage implements AppStorage {
  _IoAppStorage(this._directory);

  final Directory _directory;

  @override
  Future<Object?> readJson(String fileName) async {
    final file = _fileFor(fileName);
    if (!await file.exists()) {
      return null;
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return null;
    }

    return jsonDecode(content);
  }

  @override
  Future<void> writeJson(String fileName, Object value) async {
    final file = _fileFor(fileName);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(value),
      flush: true,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> readList(String fileName) async {
    final decoded = await readJson(fileName);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  @override
  Future<void> writeList(String fileName, List<Map<String, dynamic>> value) {
    return writeJson(fileName, value);
  }

  @override
  Future<Map<String, dynamic>?> readObject(String fileName) async {
    final decoded = await readJson(fileName);
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  }

  @override
  Future<void> writeObject(String fileName, Map<String, dynamic> value) {
    return writeJson(fileName, value);
  }

  @override
  Future<void> deleteFile(String fileName) async {
    final file = _fileFor(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  File _fileFor(String fileName) => File('${_directory.path}/$fileName');
}

Future<Directory> _resolveStorageDirectory() async {
  final home = Platform.environment['HOME'];
  if (home != null && home.isNotEmpty) {
    return Directory('$home/.focusboard');
  }

  final appData = Platform.environment['APPDATA'];
  if (appData != null && appData.isNotEmpty) {
    return Directory('$appData/focusboard');
  }

  return Directory('${Directory.systemTemp.path}/focusboard');
}
