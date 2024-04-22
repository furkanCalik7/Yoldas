import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageKey {
  name,
  phone_number,
  password,
  access_token,
  role,
  token_type,
  abilities,
  isConsultant,
}

class SecureStorageManager {
  static const _storage = FlutterSecureStorage();
  static final Map<StorageKey, String> _cache = {};

  static Future<void> write(
      {required StorageKey key, required String value}) async {
    _storage.write(key: key.name, value: value);
    // Update cache after writing
    _cache[key] = value;
  }

  static Future<void> writeList(
      {required StorageKey key, required List<dynamic> value}) async {
    String jsonData = json.encode(value);
    _storage.write(key: key.name, value: jsonData);
    // Update cache after writing
    _cache[key] = jsonData;
  }

  static String? readFromCache({required StorageKey key}) {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    return null;
  }

  static Future<String?> read({required StorageKey key}) async {
    // Read asynchronously from storage and update cache
    String? value = await _storage.read(key: key.name);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  static List<String>? readListFromCache({required StorageKey key}) {
    if (_cache.containsKey(key)) {
      return json.decode(_cache[key]!).cast<String>();
    }
    return null;
  }

  static Future<List<String>?> readList({required StorageKey key}) async {
    String? jsonData = await _storage.read(key: key.name);
    if (jsonData != null) {
      // Update cache after reading
      _cache[key] = jsonData;
      return json.decode(jsonData).cast<String>();
    }
    return null;
  }

  static Future<void> delete({required StorageKey key}) async {
    await _storage.delete(key: key.name);
    // Remove from cache after deletion
    _cache.remove(key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
    // Clear cache after deleting all
    _cache.clear();
  }
}
