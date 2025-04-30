import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                child: const Text('Accedi'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
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