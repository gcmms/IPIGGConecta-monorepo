import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  const UserSession({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: () {
        final raw = json['role']?.toString();
        if (raw != null && raw.isNotEmpty) {
          return raw;
        }
        return 'Membro';
      }(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isAdmin => role.toLowerCase() == 'administrador';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.token,
  });

  final UserSession user;
  final String token;
}

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();
  static const _sessionKey = 'auth_session';

  AuthSession? _session;

  UserSession? get currentUser => _session?.user;
  String? get token => _session?.token;
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_sessionKey);
    if (stored == null) return;

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final userData = decoded['user'];
      final token = decoded['token']?.toString();

      if (userData is Map<String, dynamic> && token != null) {
        _session = AuthSession(
          user: UserSession.fromJson(userData),
          token: token,
        );
      }
    } catch (_) {
      await prefs.remove(_sessionKey);
    }
  }

  Future<void> setSession({
    required UserSession user,
    required String token,
  }) async {
    _session = AuthSession(user: user, token: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'token': token,
        'user': user.toJson(),
      }),
    );
  }

  Future<void> clear() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
