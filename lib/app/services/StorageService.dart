import 'package:get_storage/get_storage.dart';

class StorageLocalService {
  static final StorageLocalService _instance = StorageLocalService._internal();
  factory StorageLocalService() => _instance;
  StorageLocalService._internal();

  final GetStorage _box = GetStorage();

  Future<void> writeString(String key, String value) async {
    await _box.write(key, value);
  }

  String? readString(String key) {
    return _box.read(key) as String?;
  }

  Future<void> writeInt(String key, int value) async {
    await _box.write(key, value);
  }

  int? readInt(String key) {
    return _box.read(key) as int?;
  }

  Future<void> writeBool(String key, bool value) async {
    await _box.write(key, value);
  }

  bool? readBool(String key) {
    return _box.read(key) as bool?;
  }
  
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clear() async {
    await _box.erase();
  }
}
