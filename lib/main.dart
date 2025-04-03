import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/screens/AuthWrapper.dart';
import 'package:ketchapp_flutter/screens/HomeScreen.dart';
import 'package:ketchapp_flutter/screens/LoginScreen.dart';
import 'package:ketchapp_flutter/screens/RegisterScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Assicura che i binding di Flutter siano inizializzati
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Usa le opzioni generate
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          // builder: (context, state) => const HomeScreen(),
          builder: (context, state) => AuthWrapper(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}
