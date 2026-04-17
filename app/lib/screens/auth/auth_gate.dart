import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/daily_log_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../main/main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Push the new auth state into the provider so it can load/clear
        // per-user data. Done in a post-frame callback so we don't mutate
        // state during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final diaryProvider   = context.read<DailyLogProvider>();
          final profileProvider = context.read<UserProfileProvider>();
          if (diaryProvider.userId != user?.uid) {
            diaryProvider.setUser(user?.uid);
          }
          if (profileProvider.userId != user?.uid) {
            profileProvider.setUser(user?.uid);
          }
        });

        if (user != null) return const MainShell();
        return const LoginScreen();
      },
    );
  }
}
