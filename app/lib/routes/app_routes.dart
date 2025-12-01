import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login.dart';
import '../screens/register.dart';
import '../screens/dashboard.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
