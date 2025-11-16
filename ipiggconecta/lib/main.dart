import 'package:flutter/material.dart';

import 'data/session/session_manager.dart';
import 'presentation/auth/forgot_password_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/community_feed_screen.dart';
import 'presentation/home/member_list_screen.dart';
import 'presentation/home/mural/mural_screen.dart';
import 'presentation/home/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.instance.load();
  runApp(
    MyApp(
      initialRoute: SessionManager.instance.isAuthenticated ? '/home' : '/login',
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPIGG Conecta',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D70F1),
          primary: const Color(0xFF0D70F1),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/home': (_) => const MuralScreen(),
        '/community': (_) => const CommunityFeedScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/members': (_) => const MemberListScreen(),
      },
    );
  }
}
