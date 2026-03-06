import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/calendar/calendar_url_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/team_select/team_select_screen.dart';

// GoRouter ≒ Next.js App Router.
// `redirect` は Next.js の middleware に相当する認証ガード。
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'teams',
            builder: (context, state) {
              final sport = state.uri.queryParameters['sport'] ?? 'soccer';
              return TeamSelectScreen(sport: sport);
            },
          ),
          GoRoute(
            path: 'calendar',
            builder: (context, state) => const CalendarUrlScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
