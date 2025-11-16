import 'package:flutter/material.dart';

import '../../data/models/user_profile.dart';
import '../../data/services/user_service.dart';
import '../../data/session/session_manager.dart';
import '../widgets/app_bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = UserService();
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProfile();
  }

  Future<UserProfile> _loadProfile() async {
    final token = SessionManager.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    return _service.fetchCurrentUser(token);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadProfile();
    });
    await _future;
  }

  Future<void> _logout() async {
    await SessionManager.instance.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE1C4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF9F43),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7F8697),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 45,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA74F),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                profile.role.isNotEmpty ? profile.role : 'Membro da Igreja',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoTile(
                icon: Icons.person,
                label: 'Nome',
                value: profile.fullName.isEmpty
                    ? 'Membro'
                    : profile.fullName,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.shield_outlined,
                label: 'Papel',
                value: profile.role,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE02036),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Color(0xFFFF9F43),
            ),
            const SizedBox(height: 16),
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFEEFE3),
            Color(0xFFFDF9F4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFFF9F43),
            onRefresh: _refresh,
            child: FutureBuilder<UserProfile>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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

                if (!snapshot.hasData) {
                  return _buildError(
                    'Não foi possível carregar os dados do usuário.',
                  );
                }

                return _buildContent(snapshot.data!);
              },
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentRoute: '/profile',
        ),
      ),
    );
  }
}
