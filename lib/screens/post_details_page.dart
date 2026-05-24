import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/session_manager.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({super.key});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final PostService _postService = PostService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final uid = await SessionManager.get();
    setState(() => _currentUserId = uid);
  }

  @override
  Widget build(BuildContext context) {
    final initialPost = ModalRoute.of(context)!.settings.arguments as Post;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BB88D),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Visualizar Post",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Post?>(
        stream: _postService.getPostStream(initialPost.id),
        initialData: initialPost,
        builder: (context, snapshot) {
          final post = snapshot.data;
          if (post == null) {
            return const Center(child: Text("Post indisponível ou excluído."));
          }

          final date = post.createdAt;
          final dateStr =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

          final isLiked =
              _currentUserId != null && post.likedBy.contains(_currentUserId);
          final likeCount = post.likedBy.length;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(post.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7BB88D), Color(0xFFC8E6C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_florist,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(
                              0xFF7BB88D,
                            ).withValues(alpha: 0.2),
                            child: Text(
                              post.userName.isNotEmpty
                                  ? post.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.userName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          _buildLikeButton(
                            isLiked: isLiked,
                            count: likeCount,
                            onTap: () async {
                              if (_currentUserId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Faça login para poder curtir posts! 🔒",
                                    ),
                                  ),
                                );
                                return;
                              }
                              await _postService.toggleLike(post.id);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text(
                        post.description.isNotEmpty
                            ? post.description
                            : "Sem descrição.",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLikeButton({
    required bool isLiked,
    required int count,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLiked
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.grey[500]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiked
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  "$count",
                  style: TextStyle(
                    color: isLiked ? Colors.red[800] : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
