import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token/profile storage.
/// Web over HTTP (LAN demo) cannot use flutter_secure_storage on iOS Safari,
/// so we fall back to SharedPreferences there.
class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<SharedPreferences> _prefsReady() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  bool get _usePrefs => kIsWeb;

  Future<void> write({required String key, required String value}) async {
    if (_usePrefs) {
      await (await _prefsReady()).setString(key, value);
      return;
    }
    await _secure.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    if (_usePrefs) {
      return (await _prefsReady()).getString(key);
    }
    return _secure.read(key: key);
  }

  Future<void> delete({required String key}) async {
    if (_usePrefs) {
      await (await _prefsReady()).remove(key);
      return;
    }
    await _secure.delete(key: key);
  }
}
