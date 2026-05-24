import 'package:ecosnap/models/user.dart';
import 'package:flutter/material.dart';
import 'package:ecosnap/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _newAuthService = AuthService();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final nomeController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool _isLoginMode = true;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: msg.contains("sucesso") ? const Color(0xFF2E7D32) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void login() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem("Preencha todos os campos");
      return;
    }

    final ok = await _newAuthService.login(email, senha);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      mostrarMensagem("Email ou senha incorretos");
    }
  }

  void cadastrar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      mostrarMensagem("Preencha todos os campos");
      return;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem("As senhas não coincidem");
      return;
    }

    if (senha.length < 4) {
      mostrarMensagem("A senha deve ter pelo menos 4 caracteres");
      return;
    }

    final novoUsuario = User.forRegistration(
      name: nome,
      email: email,
      password: senha,
    );

    final sucesso = await _newAuthService.register(novoUsuario);

    if (sucesso) {
      mostrarMensagem("Conta criada com sucesso! 🌱");
      nomeController.clear();
      emailController.clear();
      senhaController.clear();
      confirmarSenhaController.clear();
      setState(() {
        _isLoginMode = true;
      });
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
              const SizedBox(height: 40),

              
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/Logo.jpg"),
              ),

              const SizedBox(height: 20),

              Text(
                _isLoginMode ? "Bem-vindo 🌱" : "Criar Conta 🌿",
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    if (!_isLoginMode) ...[
                      TextField(
                        controller: nomeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Nome Completo",
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF7BB88D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF7BB88D), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7BB88D)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7BB88D), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7BB88D)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF7BB88D), width: 2),
                        ),
                      ),
                    ),

                    if (!_isLoginMode) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmarSenhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirmar Senha",
                          prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFF7BB88D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF7BB88D), width: 2),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    
                    ElevatedButton(
                      onPressed: _isLoginMode ? login : cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _isLoginMode ? "Entrar" : "Cadastrar",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 16),

                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                        });
                      },
                      child: Text(
                        _isLoginMode
                            ? "Não tem uma conta? Cadastre-se"
                            : "Já tem uma conta? Faça Login",
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
