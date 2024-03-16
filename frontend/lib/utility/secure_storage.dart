// ignore_for_file: constant_identifier_names

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageKey {
  name,
  email,
  phone_number,
  password,
  access_token,
  role,
  token_type
}

class SecureStorageManager {
  static const _storage = FlutterSecureStorage();

  static Future<void> write(
      {required StorageKey key, required String value}) async {
    await _storage.write(key: key.name, value: value);
  }

  static Future<String?> read({required StorageKey key}) async {
    return await _storage.read(key: key.name);
  }

  static Future<void> delete({required StorageKey key}) async {
    await _storage.delete(key: key.name);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
