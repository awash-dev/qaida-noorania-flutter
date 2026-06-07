import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _key = 'qaida_logged_in';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<bool> isLoggedIn() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_key) ?? false;
      }
      final val = await _secureStorage.read(key: _key);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_key, value);
        return;
      }
      await _secureStorage.write(key: _key, value: value.toString());
    } catch (_) {}
  }

  static Future<void> clearLoggedIn() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_key);
        return;
      }
      await _secureStorage.delete(key: _key);
    } catch (_) {}
  }
}
