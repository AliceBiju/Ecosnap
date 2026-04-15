import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List posts = [];
  bool logado = false;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    final lista = await PostService.getPosts();
    final status = await AuthService.isLogged();

    setState(() {
      posts = lista;
      logado = status;
    });
  }

  void abrirCriarPost() async {
    final nomeController = TextEditingController();
    final textoController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Novo Post 🌱"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Seu nome"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textoController,
                decoration: const InputDecoration(labelText: "Comentário"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nomeController.text.isEmpty ||
                    textoController.text.isEmpty) {
                  return;
                }

                await PostService.addPost(
                  nomeController.text,
                  textoController.text,
                );

                Navigator.pop(context);
                carregar();
              },
              child: const Text("Postar"),
            ),
          ],
        );
      },
    );
  }

  String formatarData(String data) {
    final d = DateTime.parse(data);
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comunidade 🌿"),
        backgroundColor: const Color(0xFF7BB88D),
      ),

      body: posts.isEmpty
          ? const Center(child: Text("Nenhum post ainda"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final post = posts[i];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["nome"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatarData(post["data"]),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(post["texto"]),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: logado
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7BB88D),
              onPressed: abrirCriarPost,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
