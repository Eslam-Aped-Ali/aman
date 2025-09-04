import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Generic storage methods
  static Future<bool> setString(String key, String value) async {
    await init();
    return await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    await init();
    return await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    await init();
    return await prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  static Future<bool> remove(String key) async {
    await init();
    return await prefs.remove(key);
  }

  static Future<bool> clear() async {
    await init();
    return await prefs.clear();
  }
}
