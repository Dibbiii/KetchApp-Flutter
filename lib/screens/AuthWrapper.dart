import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ketchapp_flutter/screens/HomeScreen.dart';
import 'package:ketchapp_flutter/screens/LoginScreen.dart';
import 'package:ketchapp_flutter/screens/login_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ascolta lo stream dello stato di autenticazione
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostra un indicatore di caricamento mentre controlla lo stato
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Se l'utente è loggato (snapshot ha dati)
        if (snapshot.hasData && snapshot.data != null) {
          // Utente loggato, mostra la HomePage
          return HomeScreen(); // Passa l'utente se necessario: HomePage(user: snapshot.data!)
        } else {
          // Utente non loggato, mostra la LoginPage
          return LoginPage();
        }
      },
    );
  }
}