import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../layout/main_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  
  String? email;
  String? name;
  bool _isLoadingUser = true;

  final ScrollController _scrollController = ScrollController();
  int _postsLimit = 5;
  List<Post> _myPosts = [];
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    carregar();

    // Ouvinte para o scroll infinito
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _carregarMaisPosts();
      }
    });
  }

  void carregar() async {
    setState(() => _isLoadingUser = true);
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        email = user.email;
        name = user.name;
        _isLoadingUser = false;
      });
      _setupPostsFuture();
    } else {
      setState(() {
        email = null;
        name = null;
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _setupPostsFuture() async {
    if (_loadingMore) return;

    // Se for o primeiro carregamento, mostra o indicador geral
    final isFirst = _myPosts.isEmpty;
    if (isFirst) {
      setState(() {
        _loadingMore = true;
      });
    }

    final stream = await _postService.getMyPosts(limit: _postsLimit);
    if (stream != null) {
      try {
        // Pega a primeira emissão (Future) para evitar piscadas do StreamBuilder
        final postsList = await stream.first;
        if (mounted) {
          setState(() {
            _myPosts = postsList;
            _loadingMore = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loadingMore = false);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _loadingMore = false;
        });
      }
    }
  }

  void _carregarMaisPosts() {
    if (_loadingMore) return;
    setState(() {
      _postsLimit += 5; // Aumenta o limite sob demanda
    });
    _setupPostsFuture();
  }

  void _deletarPost(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text(
                "Excluir Post?",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
            ],
          ),
          content: const Text(
            "Tem certeza que deseja apagar esta publicação permanentemente? Essa ação não poderá ser desfeita.",
            style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Fecha diálogo
                try {
                  await _postService.deletePost(postId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Publicação excluída com sucesso! 🗑️"),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  }
                  // Recarrega lista local
                  _setupPostsFuture();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao excluir post: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Excluir", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    await _authService.logout();
    setState(() {
      email = null;
      name = null;
      _myPosts = [];
      _postsLimit = 5;
      _loadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const MainLayout(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7BB88D)),
        ),
      );
    }

    return MainLayout(
      body: email == null
          ? Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7BB88D).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_circle_outlined,
                          size: 64,
                          color: Color(0xFF5A9B6F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Seu Perfil EcoSnap 🌱",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Crie uma conta ou faça login para poder compartilhar suas plantinhas na comunidade, interagir com curtidas e salvar todo o seu histórico de análises.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login').then((_) {
                            carregar();
                          });
                        },
                        icon: const Icon(Icons.login),
                        label: const Text("Entrar ou Criar Perfil"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BB88D),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
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
                          backgroundImage: AssetImage("assets/images/Logo.jpg"),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name ?? "EcoSnap Member",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARDS DE OPÇÕES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _card(Icons.edit, "Editar Perfil", onTap: () {
                          Navigator.pushNamed(context, '/edit-profile').then((_) {
                            carregar();
                          });
                        }),
                        _card(Icons.history, "Histórico", onTap: () {
                          Navigator.pushNamed(context, '/history');
                        }),
                        _card(Icons.logout, "Sair", onTap: logout),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Divider(),

                  // 🌿 MEUS POSTS (SCROLL INFINITO)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Minhas Publicações 🌱",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ),

                  if (_loadingMore && _myPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF7BB88D)),
                      ),
                    )
                  else ...[
                    if (_myPosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "Você ainda não publicou nenhuma foto na comunidade.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Scroll principal cuida disso
                        itemCount: _myPosts.length,
                        itemBuilder: (context, index) {
                          final post = _myPosts[index];
                          return _ProfilePostCard(
                            post: post,
                            onDelete: () => _deletarPost(post.id),
                          );
                        },
                      ),
                      
                      // Indicador de "Carregando mais" no final da lista
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Color(0xFF7BB88D),
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                  
                  const SizedBox(height: 35),
                ],
              ),
            ),
    );
  }

  Widget _card(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7BB88D)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onDelete;

  const _ProfilePostCard({
    required this.post,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.grey[100],
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/post-details',
            arguments: post,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Foto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: post.imageUrl != null
                      ? Image.network(post.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.local_florist, color: Colors.white, size: 28),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Título e Likes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          post.likedBy.length == 1
                              ? "1 curtida"
                              : "${post.likedBy.length} curtidas",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // LIXEIRA DE DELEÇÃO PARA O DONO
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ),

              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
