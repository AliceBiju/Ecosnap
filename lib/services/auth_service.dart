import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:ecosnap/repository/user_repository.dart';
import 'package:ecosnap/models/user.dart';
import 'session_manager.dart';

class AuthService {
  final UserRepository _repository = UserRepository();

  /// Gera hash SHA-256 para a senha do usuário
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> userExists(String email) async {
    final user = await _repository.getUserByEmail(email);
    return user != null;
  }

  Future<bool> register(User user) async {
    if (await userExists(user.email)) return false;

    // Criptografa/Hash da senha antes de salvar
    final hashedPassword = _hashPassword(user.password);
    final userToSave = User(
      id: user.id,
      name: user.name,
      email: user.email,
      password: hashedPassword,
      profilePictureURL: user.profilePictureURL,
    );

    await _repository.saveUser(userToSave);

    final created = await _repository.getUserByEmail(user.email);
    if (created != null) {
      await SessionManager.save(created.id);
      return true;
    }

    return false;
  }

  Future<bool> login(String email, String password) async {
    final userInDb = await _repository.getUserByEmail(email);
    if (userInDb != null) {
      final hashedInput = _hashPassword(password);
      // Fallback: Permite login se a senha no banco for igual ao hash da entrada
      // OU se for igual à senha plana (para contas criadas anteriormente)
      if (userInDb.password == hashedInput || userInDb.password == password) {
        await SessionManager.save(userInDb.id);
        return true;
      }
    }
    return false;
  }

  Future<String?> getCurrentUserId() async {
    return await SessionManager.get();
  }

  Future<String?> getEmail() async {
    final uid = await SessionManager.get();
    if (uid != null) {
      final user = await _repository.getUser(uid);
      return user?.email;
    }
    return null;
  }

  Future<String?> getName() async {
    final uid = await SessionManager.get();
    if (uid != null) {
      final user = await _repository.getUser(uid);
      return user?.name;
    }
    return null;
  }

  Future<void> logout() async {
    await SessionManager.clear();
  }

  Future<bool> isLogged() async {
    return await SessionManager.get() != null;
  }

  /// Retorna o objeto User completo do usuário logado.
  Future<User?> getCurrentUser() async {
    final uid = await SessionManager.get();
    if (uid == null) return null;
    return await _repository.getUser(uid);
  }

  /// Atualiza o nome e a senha (criptografada) do usuário logado.
  Future<void> updateProfile(String name, String password) async {
    final uid = await SessionManager.get();
    if (uid == null) return;

    final hashedPassword = _hashPassword(password);
    await _repository.updateUser(uid, {
      'name': name,
      'password': hashedPassword,
    });
  }
}
