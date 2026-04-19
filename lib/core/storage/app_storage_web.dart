// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

import 'app_storage.dart';

Future<AppStorage> createAppStorage() async {
  return _WebAppStorage();
}

class _WebAppStorage implements AppStorage {
  static const _prefix = 'focusboard:';

  @override
  Future<Object?> readJson(String fileName) async {
    final raw = html.window.localStorage['$_prefix$fileName'];
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    return jsonDecode(raw);
  }

  @override
  Future<void> writeJson(String fileName, Object value) async {
    html.window.localStorage['$_prefix$fileName'] =
        const JsonEncoder.withIndent('  ').convert(value);
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
    html.window.localStorage.remove('$_prefix$fileName');
  }
}
