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
import 'package:ketchapp_flutter/features/welcome/presentation/pages/welcome_page.dart';

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

    // --- Utente NON loggato ---
    if (!loggedIn) {
      // Se tenta di accedere a rotte protette (non auth/welcome), reindirizza a welcome/login
      if (!isAuthRoute && !isWelcomeRoute) {
        return '/'; // O '/login' se preferisci
      }
      // Altrimenti permette l'accesso a welcome/login/register
      return null;
    }

    // --- Utente È loggato ---
    // Se tenta di accedere a welcome/login/register, reindirizza a home
    if (isAuthRoute || isWelcomeRoute) {
      return '/home';
    }

    // Altrimenti (utente loggato che accede a rotte protette come /home), permette l'accesso
    return null;
  },
  // Definizione delle rotte
  routes: [
    // Rotte pubbliche (fuori dalla ShellRoute)
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // ShellRoute per le pagine che necessitano del layout principale (con Footer)
    ShellRoute(
      builder: (context, state, child) {
        // Usa MainLayout come guscio E fornisci HomeBloc
        return BlocProvider(
          // <-- Aggiungi BlocProvider qui
          create: (context) => HomeBloc(), // Crea l'istanza di HomeBloc
          child: MainLayout(
            child: child,
          ), // MainLayout è ora figlio del BlocProvider
        );
      },
      routes: [
        // Rotte protette all'interno della Shell
        GoRoute(
          path: '/home',
          // HomePage ora può accedere a HomeBloc perché è fornito sopra
          builder: (context, state) => const HomePage(),
        ),
        // Aggiungi qui altre rotte che necessitano di MainLayout e potenzialmente di HomeBloc
        // Esempio:
        // GoRoute(
        //   path: '/profile',
        //   builder: (context, state) => const ProfilePage(),
        // ),
      ],
    ),
    GoRoute(
      path: '/plan/:mode',
      builder: (context, state) {
        final mode =
            state.pathParameters['mode'] ??
            'automatic'; //se non viene fornuto un mode, usa 'automatic' come predefinito
        PlanMode planMode;
        switch (mode) {
          case 'manual':
            planMode = PlanMode.manual;
            break;
          case 'automatic':
            planMode = PlanMode.automatic;
            break;
          default:
            planMode = PlanMode.automatic;
        }
        return PlanLayout(mode: planMode);
      },
    ),
  ],

  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
