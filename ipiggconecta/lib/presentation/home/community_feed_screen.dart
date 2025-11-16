import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/community_comment.dart';
import '../../data/models/community_post.dart';
import '../../data/services/community_service.dart';
import '../../data/session/session_manager.dart';
import '../widgets/app_bottom_navigation.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _service = const CommunityService();
  late Future<List<CommunityPost>> _future;
  List<CommunityPost> _posts = const [];
  final _postController = TextEditingController();
  bool _isPosting = false;

  UserSession? get _currentUser => SessionManager.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _future = _loadFeed();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<List<CommunityPost>> _loadFeed() async {
    final data = await _service.fetchFeed(userId: _currentUser?.id);
    _posts = data;
    return _posts;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadFeed();
    });
    try {
      await _future;
    } on TimeoutException {
      _showMessage('Tempo de resposta esgotado. Tente novamente.');
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openComposer() async {
    if (_currentUser == null) {
      _showMessage('Faça login para publicar.');
      return;
    }

    _postController.clear();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nova publicação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _postController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Compartilhe uma mensagem com a comunidade...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isPosting
                    ? null
                    : () async {
                        final text = _postController.text.trim();
                        if (text.isEmpty) {
                          _showMessage('Digite uma mensagem.');
                          return;
                        }
                        setState(() => _isPosting = true);
                        try {
                          await _service.createPost(
                            userId: _currentUser!.id,
                            content: text,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _showMessage('Publicação enviada!');
                            await _refresh();
                          }
                        } catch (error) {
                          _showMessage(error.toString());
                        } finally {
                          if (mounted) {
                            setState(() => _isPosting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F43),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFFF9F43).withOpacity(0.4),
                ),
                child: _isPosting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Publicar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(CommunityPost post) async {
    if (_currentUser == null) {
      _showMessage('Faça login para curtir.');
      return;
    }

    try {
      final result = await _service.toggleLike(
        postId: post.id,
        userId: _currentUser!.id,
      );

      setState(() {
        _posts = _posts.map((item) {
          if (item.id == post.id) {
            return item.copyWith(
              likesCount: result['likes_count'] as int,
              likedByUser: result['liked'] as bool,
            );
          }
          return item;
        }).toList();
        _future = Future.value(_posts);
      });
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _openComments(CommunityPost post) async {
    if (_currentUser == null) {
      _showMessage('Faça login para comentar.');
      return;
    }

    final commentController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: FutureBuilder<List<CommunityComment>>(
            future: _service.fetchComments(post.id),
            builder: (context, snapshot) {
              final comments = snapshot.data ?? [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Escreva um comentário...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final text = commentController.text.trim();
                      if (text.isEmpty) {
                        _showMessage('Digite um comentário.');
                        return;
                      }
                      try {
                        final updatedComments = await _service.addComment(
                          postId: post.id,
                          userId: _currentUser!.id,
                          comment: text,
                        );
                        commentController.clear();
                        setState(() {
                          _posts = _posts.map((item) {
                            if (item.id == post.id) {
                              return item.copyWith(
                                commentsCount: updatedComments.length,
                              );
                            }
                            return item;
                          }).toList();
                          _future = Future.value(_posts);
                        });
                        if (mounted) {
                          Navigator.pop(context);
                        }
                        _showMessage('Comentário enviado!');
                      } catch (error) {
                        _showMessage(error.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D70F1),
                    ),
                    child: const Text('Enviar'),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              comment.authorName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment.comment),
                            trailing: Text(
                              comment.relativeTime,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostTile(CommunityPost post) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9F43),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '· ${post.relativeTime}',
                        style: const TextStyle(
                          color: Color(0xFF8E94A3),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 15.5,
                      height: 1.4,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _FeedActionButton(
              icon: Icons.chat_bubble_outline,
              label: post.commentsCount.toString(),
              onPressed: () => _openComments(post),
              color: const Color(0xFF8E94A3),
            ),
            _FeedActionButton(
              icon: Icons.repeat,
              label: '0',
              onPressed: () => _showMessage('Repost ainda não implementado.'),
              color: const Color(0xFF8E94A3),
            ),
            _FeedActionButton(
              icon: post.likedByUser ? Icons.favorite : Icons.favorite_border,
              label: post.likesCount.toString(),
              activeColor: post.likedByUser ? const Color(0xFFFF4D67) : null,
              color: post.likedByUser ? const Color(0xFFFF4D67) : const Color(0xFF8E94A3),
              onPressed: () => _toggleLike(post),
            ),
            _FeedActionButton(
              icon: Icons.ios_share_outlined,
              label: '',
              onPressed: () =>
                  _showMessage('Compartilhar ainda não implementado.'),
              color: const Color(0xFF8E94A3),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 32, color: Color(0xFFE5E6EC)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Feed da Comunidade',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF9F43),
          onRefresh: _refresh,
          child: FutureBuilder<List<CommunityPost>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Center(child: Text('Nenhuma publicação ainda.')),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostTile(post);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposer,
        backgroundColor: const Color(0xFFFF9F43),
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: '/community',
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.icon,
    required this.onPressed,
    required this.label,
    this.activeColor,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String label;
  final Color? activeColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? activeColor ?? const Color(0xFF6E7585);
    final labelWidget = label.isEmpty
        ? const SizedBox.shrink()
        : Text(
            label,
            style: TextStyle(
              color: resolvedColor,
              fontWeight: FontWeight.w500,
            ),
          );
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: resolvedColor,
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icon, size: 18, color: resolvedColor),
        label: labelWidget,
      ),
    );
  }
}
