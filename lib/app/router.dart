import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/pages/error_page.dart';
import 'package:ketchapp_flutter/app/layouts/main_layout.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:ketchapp_flutter/features/home/presentation/pages/home_page.dart';
import 'package:ketchapp_flutter/features/plan/models/plan_model.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/plan_creation_loading_page.dart';
import 'package:ketchapp_flutter/features/rankings/presentation/ranking_page.dart';

import 'package:ketchapp_flutter/features/timer/presentation/timer_page.dart';
import 'package:ketchapp_flutter/features/welcome/presentation/pages/welcome_page.dart';
import 'package:ketchapp_flutter/features/profile/presentation/pages/profile_page.dart';

import '../features/statistics/presentation/statistics_page.dart';
import 'package:ketchapp_flutter/features/statistics/bloc/api_statistics_bloc.dart';
import 'package:ketchapp_flutter/features/statistics/bloc/statistics_event.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/forgot_password';
      final isWelcomeRoute = location == '/';

      // Se NON autenticato e non sei su login/register/welcome, manda a login
      if (!isAuthenticated && !isAuthRoute && !isWelcomeRoute) {
        return '/login';
      }

      // Se autenticato e sei su login/register/welcome, manda a home
      if (isAuthenticated && (isAuthRoute || isWelcomeRoute)) {
        return '/home';
      }

      // Altrimenti nessun redirect
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
        path: '/plan-creation-loading',
        redirect: (context, state) {
          if (state.extra is! PlanModel) {
            return '/home?refresh=true';
          }
          return null;
        },
        builder: (context, state) {
          final plan = state.extra as PlanModel;
          return PlanCreationLoadingPage(plan: plan);
        },
      ),
      GoRoute(
        path: '/timer/:tomatoID',
        builder: (context, state) {
          final tomatoID = int.tryParse(state.pathParameters['tomatoID'] ?? '');
          return TimerPage(tomatoId: tomatoID);
        },
      ),
      ShellRoute(
        builder:
            (context, state, child) => BlocProvider(
              create: (context) => HomeBloc(),
              child: MainLayout(child: child),
            ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final refresh = state.uri.queryParameters['refresh'] == 'true';
              return HomePage(refresh: refresh);
            },
          ),
          GoRoute(
            path: '/statistics',
            builder: (context, state) {
              return BlocProvider(
                create:
                    (context) => ApiStatisticsBloc(
                      apiService: context.read<ApiService>(),
                    )..add(const StatisticsLoadRequested()),
                child: StatisticsPage(),
              );
            },
          ),
          GoRoute(
            path: '/ranking',
            builder: (context, state) => const RankingPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}

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
