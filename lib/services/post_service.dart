import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String _key = "posts";

  static Future<void> addPost(String nome, String texto) async {
    final prefs = await SharedPreferences.getInstance();

    final posts = await getPosts();

    final novoPost = {
      "nome": nome,
      "texto": texto,
      "data": DateTime.now().toString(),
    };

    posts.insert(0, novoPost);

    await prefs.setString(_key, jsonEncode(posts));
  }

  static Future<List<Map<String, dynamic>>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }
}
