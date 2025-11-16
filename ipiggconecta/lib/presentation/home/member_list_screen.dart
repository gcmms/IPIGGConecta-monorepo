import 'package:flutter/material.dart';

import '../../data/models/user_profile.dart';
import '../../data/services/user_service.dart';
import '../../data/session/session_manager.dart';
import '../widgets/app_bottom_navigation.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _service = UserService();
  late Future<List<UserProfile>> _future;
  final Set<int> _updatingMembers = <int>{};

  bool get _isAdmin => SessionManager.instance.currentUser?.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _future = _loadMembers();
  }

  Future<List<UserProfile>> _loadMembers() async {
    final token = SessionManager.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    return _service.fetchMembers(token);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadMembers();
    });
    await _future;
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _changeRole(UserProfile member) async {
    final token = SessionManager.instance.token;
    if (token == null || token.isEmpty) {
      _showMessage('Sessão expirada. Faça login novamente.');
      return;
    }

    final isAdmin = member.role.toLowerCase() == 'administrador';
    final newRole = isAdmin ? 'Membro' : 'Administrador';

    setState(() {
      _updatingMembers.add(member.id);
    });

    try {
      await _service.updateMemberRole(
        userId: member.id,
        role: newRole,
        token: token,
      );
      _showMessage(
        isAdmin ? 'Membro rebaixado para membro comum.' : 'Membro promovido a administrador.',
      );
      await _refresh();
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _updatingMembers.remove(member.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF4FBFF),
            Color(0xFFFFF5EF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isAdmin
              ? RefreshIndicator(
                  color: const Color(0xFFFF9F43),
                  onRefresh: _refresh,
                  child: FutureBuilder<List<UserProfile>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 180),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error!);
                      }

                      final members = snapshot.data ?? [];
                      if (members.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildContent(members);
                    },
                  ),
                )
              : _buildRestrictedAccess(),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentRoute: '/members',
        ),
      ),
    );
  }

  Widget _buildContent(List<UserProfile> members) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Lista de membros',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Somente administradores podem visualizar.',
                style: TextStyle(
                  color: Color(0xFF8E94A3),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
            ],
          );
        }

        final member = members[index - 1];
        return _MemberTile(
          member: member,
          isUpdating: _updatingMembers.contains(member.id),
          onChangeRole: () => _changeRole(member),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 160),
      children: const [
        Center(
          child: Text(
            'Nenhum membro encontrado.',
            style: TextStyle(
              color: Color(0xFF7F8697),
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildError(Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 140),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Color(0xFFFF9F43),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7F8697)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F43),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestrictedAccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 52,
              color: Color(0xFFFF9F43),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acesso restrito',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apenas administradores podem visualizar a lista de membros.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7F8697)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F43),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Voltar para a Home'),
            )
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isUpdating,
    required this.onChangeRole,
  });

  final UserProfile member;
  final bool isUpdating;
  final VoidCallback onChangeRole;

  @override
  Widget build(BuildContext context) {
    final isAdmin = member.role.toLowerCase() == 'administrador';

    final badgeColor = isAdmin
        ? const Color(0xFFFFE7D5)
        : const Color(0xFFE4F0FF);
    final badgeTextColor =
        isAdmin ? const Color(0xFFFF8C42) : const Color(0xFF3F6FD7);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFFFE9D4),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFFFF9F43),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName.isEmpty ? 'Membro' : member.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  member.email,
                  style: const TextStyle(
                    color: Color(0xFF7F8697),
                  ),
                ),
                if ((member.phone ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.phone!,
                    style: const TextStyle(
                      color: Color(0xFF7F8697),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isUpdating ? null : onChangeRole,
                    icon: isUpdating
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isAdmin
                                ? Icons.keyboard_arrow_down
                                : Icons.admin_panel_settings_outlined,
                          ),
                    label: Text(
                      isAdmin ? 'Tornar membro' : 'Tornar administrador',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Administrador' : 'Membro',
              style: TextStyle(
                color: badgeTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
