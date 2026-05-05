import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecosnap/repository/user_repository.dart';
import 'package:ecosnap/domain/user.dart';
class NewAuthService {
final UserRepository _repository = UserRepository();
static const String _sessionKey = "user_id";

  Future<bool> userExists(String email) async {
    final userExists = await _repository.getUserByEmail(email);
    if(userExists != null){
      return true;
    }
    return false;
  }

  Future<bool> register(User user) async {
    if(await userExists(user.email) == true){
      return false;
    }

    await _repository.saveUser(user);

    final userJustCreated = await _repository.getUserByEmail(user.email);

    if(userJustCreated != null){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, userJustCreated.id);
      return true;
    }

    return false;

  }

  Future<bool> login(String email, String password) async {
    final userinDb = await _repository.getUserByEmail(email);
    if( userinDb != null && userinDb.password == password){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, userinDb.id);
      return true;
    }
    return false;

  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString(_sessionKey);

    if(uid != null){
      final user = await _repository.getUser(uid);
      return user?.email;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionKey);
  }
}
