import 'dart:async'; // Necessario per StreamSubscription
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ketchapp_flutter/app/pages/error_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importa flutter_bloc
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart'; // Importa HomeBloc

// Importa il layout principale (shell)
import 'package:ketchapp_flutter/app/layouts/main_layout.dart';

// Importa le pagine dalle features
import 'package:ketchapp_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:ketchapp_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:ketchapp_flutter/features/home/presentation/pages/home_page.dart';
import 'package:ketchapp_flutter/features/plan/layouts/plan_layout.dart';

// --- Import the missing pages ---
import 'package:ketchapp_flutter/features/welcome/presentation/pages/welcome_page.dart';
import 'package:ketchapp_flutter/features/welcome/presentation/pages/auth_options_page.dart';

import '../features/statistics/presentation/statistics_page.dart';

// Helper class per GoRouter per ascoltare lo stream di AuthStateChanges
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
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

    // Definisci le rotte pubbliche/di autenticazione
    final isAuthRoute = location == '/login' || location == '/register';
    final isWelcomeRoute = location == '/';
    final isAuthOptionsRoute = location == '/auth-options';

    // --- Utente NON loggato ---
    if (!loggedIn) {
      // Se tenta di accedere a rotte protette (non auth/welcome/auth-options), reindirizza a welcome
      if (!isAuthRoute && !isWelcomeRoute && !isAuthOptionsRoute) {
        return '/'; // O '/login' se preferisci
      }
      // Altrimenti permette l'accesso a welcome/login/register/auth-options
      return null;
    }

    // --- Utente È loggato ---
    // Se tenta di accedere a welcome/login/register/auth-options, reindirizza a home
    if (isAuthRoute || isWelcomeRoute || isAuthOptionsRoute) {
      return '/home';
    }

    // Altrimenti (utente loggato che accede a rotte protette come /home), permette l'accesso
    return null;
  },
  // Definizione delle rotte
  routes: [
    // Rotte pubbliche (fuori dalla ShellRoute)
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    // Now recognized
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/auth-options',
      builder: (context, state) => const AuthOptionsPage(), // Now recognized
    ),

    // ShellRoute per le pagine che necessitano del layout principale (con Footer)
    ShellRoute(
      builder: (context, state, child) {
        // Usa MainLayout come guscio E fornisci HomeBloc
        return BlocProvider(
          create: (context) => HomeBloc(),
          child: MainLayout(child: child),
        );
      },
      routes: [
        // Rotte protette all'interno della Shell
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/statistics', builder: (context, state) => const StatisticsPage()),
        GoRoute(path: '/ranking', builder: (context, state) => const StatisticsPage()),
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
