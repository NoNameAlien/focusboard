import 'app_storage.dart';

class JsonListStore<T> {
  const JsonListStore({
    required AppStorage storage,
    required this.fileName,
    required this.fromJson,
    required this.toJson,
  }) : _storage = storage;

  final AppStorage _storage;
  final String fileName;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value) toJson;

  Future<List<T>> readAll() async {
    final items = await _storage.readList(fileName);
    return items.map(fromJson).toList(growable: false);
  }

  Future<void> writeAll(List<T> values) {
    return _storage.writeList(
      fileName,
      values.map(toJson).toList(growable: false),
    );
  }
}

class JsonObjectStore<T> {
  const JsonObjectStore({
    required AppStorage storage,
    required this.fileName,
    required this.fromJson,
    required this.toJson,
  }) : _storage = storage;

  final AppStorage _storage;
  final String fileName;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value) toJson;

  Future<T?> read() async {
    final value = await _storage.readObject(fileName);
    if (value == null) {
      return null;
    }
    return fromJson(value);
  }

  Future<void> write(T value) {
    return _storage.writeObject(fileName, toJson(value));
  }

  Future<void> clear() {
    return _storage.deleteFile(fileName);
  }
}
