import 'package:ecosnap/domain/user.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:ecosnap/services/new_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final NewAuthService _newAuthService = NewAuthService();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void login() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem("Preencha todos os campos");
      return;
    }

    final ok = await _newAuthService.login(email, senha);

    if (ok) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      mostrarMensagem("Email ou senha incorretos");
    }
  }

  void cadastrar() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem("Preencha todos os campos");
      return;
    }

    if (senha.length < 4) {
      mostrarMensagem("Senha muito curta");
      return;
    }

    final novoUsuario = User.forRegistration(
      name: email.split('@')[0],
      email: email,
      password: senha,
    );

    final sucesso = await _newAuthService.register(novoUsuario);

    if (sucesso) {
      mostrarMensagem("Conta criada com sucesso!");
      emailController.clear();
      senhaController.clear();
    } else {
      mostrarMensagem('Email já cadastrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BB88D),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// LOGO
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/Logo.png"),
              ),

              const SizedBox(height: 20),

              const Text(
                "Bem-vindo 🌱",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// CARD BRANCO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// BOTÃO LOGIN
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7BB88D),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Entrar"),
                    ),

                    const SizedBox(height: 10),

                    /// BOTÃO CADASTRO
                    OutlinedButton(
                      onPressed: cadastrar,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Criar conta"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
