import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _key = "user";

  static Future<void> register(String email, String senha) async {
    final prefs = await SharedPreferences.getInstance();

    final user = {"email": email, "senha": senha};

    await prefs.setString(_key, jsonEncode(user));
  }

  static Future<bool> login(String email, String senha) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return false;

    final user = jsonDecode(data);

    return user["email"] == email && user["senha"] == senha;
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return null;

    final user = jsonDecode(data);
    return user["email"];
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> isLogged() async {
    final email = await getEmail();
    return email != null;
  }
}
