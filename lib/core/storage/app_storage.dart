import 'app_storage_io.dart'
    if (dart.library.html) 'app_storage_web.dart'
    as storage_impl;

abstract class AppStorage {
  static Future<AppStorage> initialize() {
    return storage_impl.createAppStorage();
  }

  Future<Object?> readJson(String fileName);
  Future<void> writeJson(String fileName, Object value);
  Future<List<Map<String, dynamic>>> readList(String fileName);
  Future<void> writeList(String fileName, List<Map<String, dynamic>> value);
  Future<Map<String, dynamic>?> readObject(String fileName);
  Future<void> writeObject(String fileName, Map<String, dynamic> value);
  Future<void> deleteFile(String fileName);
}
