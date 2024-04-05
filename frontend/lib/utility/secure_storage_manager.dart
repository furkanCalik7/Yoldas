// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageKey {
  name,
  phone_number,
  password,
  access_token,
  role,
  token_type,
  abilities,
}

class SecureStorageManager {
  static const _storage = FlutterSecureStorage();

  static Future<void> write(
      {required StorageKey key, required String value}) async {
    await _storage.write(key: key.name, value: value);
  }

  static Future<void> writeList(
      {required StorageKey key, required List<dynamic> value}) async {
    String jsonData = json.encode(value);
    await _storage.write(key: key.name, value: jsonData);
  }

  static Future<String?> read({required StorageKey key}) async {
    return await _storage.read(key: key.name);
  }

  static Future<List<String>?> readList({required StorageKey key}) async {
    String? jsonData = await _storage.read(key: key.name);
    if (jsonData != null) {
      List<dynamic> dynamic_list = json.decode(jsonData);
      List<String> string_list = dynamic_list.cast<String>();
      return string_list;
    }
    return null;
  }

  static Future<void> delete({required StorageKey key}) async {
    await _storage.delete(key: key.name);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
