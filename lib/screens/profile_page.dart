import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    final e = await AuthService.getEmail();
    setState(() => email = e);
  }

  void logout() async {
    await AuthService.logout();
    setState(() => email = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF7BB88D),
        title: const Text("Perfil"),
        centerTitle: true,
      ),

      body: email == null
          ? Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Entrar / Criar conta"),
              ),
            )
          : Column(
              children: [
                // TOPO VERDE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: const BoxDecoration(
                    color: Color(0xFF7BB88D),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage("assets/images/Logo.png"),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CARDS
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _card(Icons.local_florist, "Minhas plantas"),
                      _card(Icons.history, "Histórico"),
                      _card(Icons.settings, "Configurações"),
                      _card(Icons.logout, "Sair", onTap: logout),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _card(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7BB88D)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
