import 'package:flutter/foundation.dart' show kIsWeb;
import 'session_manager_web.dart'
    if (dart.library.io) 'session_manager_stub.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _key = 'user_id';

  static Future<void> save(String userId) async {
    if (kIsWeb) {
      saveToLocalStorage(_key, userId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, userId);
    }
  }

  static Future<String?> get() async {
    if (kIsWeb) {
      return getFromLocalStorage(_key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    }
  }

  static Future<void> clear() async {
    if (kIsWeb) {
      removeFromLocalStorage(_key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }
  }
}
