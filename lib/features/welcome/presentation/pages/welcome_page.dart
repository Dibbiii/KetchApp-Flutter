import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Per la navigazione

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Questa pagina è semplice, potrebbe non necessitare di un BLoC dedicato
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Benvenuto in KetchApp!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Naviga alla pagina di login
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                child: const Text('Accedi'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  // Naviga alla pagina di registrazione
                  context.push('/register');
                },
                 style: OutlinedButton.styleFrom(minimumSize: const Size(200, 50)),
                child: const Text('Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}