import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/pages/error_page.dart';
import 'package:ketchapp_flutter/app/layouts/main_layout.dart';
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:ketchapp_flutter/features/home/presentation/pages/home_page.dart';
import 'package:ketchapp_flutter/features/plan/layouts/plan_layout.dart';
import 'package:ketchapp_flutter/features/rankings/presentation/ranking_page.dart';
import 'package:ketchapp_flutter/features/settings/presentation/settings_page.dart';
import 'package:ketchapp_flutter/features/statistics/bloc/statistics_bloc.dart';
import 'package:ketchapp_flutter/features/welcome/presentation/pages/welcome_page.dart';
import 'package:ketchapp_flutter/features/profile/presentation/pages/profile_page.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/statistics/presentation/statistics_page.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ketchapp_flutter/features/settings/presentation/white_noises_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final location = state.matchedLocation;
    final isAuthRoute = location == '/login' || location == '/register' || location == '/forgot_password';
    final isWelcomeRoute = location == '/';
    final isAuthOptionsRoute = location == '/auth-options';
    if (!loggedIn) {
      if (!isAuthRoute && !isWelcomeRoute && !isAuthOptionsRoute) return '/';
      return null;
    }
    if (isAuthRoute || isWelcomeRoute || isAuthOptionsRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    ShellRoute(
      builder:
          (context, state, child) => BlocProvider(
            create: (context) => HomeBloc(),
            child: MainLayout(child: child),
          ),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/statistics',
          builder: (context, state) {
            return BlocProvider(
              create: (context) =>
                  StatisticsBloc(authBloc: context.read<AuthBloc>()),
              child: StatisticsPage(),
            );
          },
        ),
        GoRoute(
          path: '/ranking',
          builder: (context, state) => const RankingPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/white_noises_page',
          builder: (context, state) => const WhiteNoisesPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/plan/:mode',
      builder: (context, state) {
        final mode = state.pathParameters['mode'] ?? 'automatic';
        PlanMode planMode;
        switch (mode) {
          case 'manual':
            planMode = PlanMode.manual;
            break;
          case 'automatic':
          default:
            planMode = PlanMode.automatic;
        }
        return PlanLayout(mode: planMode);
      },
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
