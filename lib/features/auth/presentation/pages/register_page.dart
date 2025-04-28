import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart'; // Importa il BLoC

class RegisterPage extends StatefulWidget { // Convertito a StatefulWidget
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> { // State class
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  // Aggiungi altri controller se necessario (es. conferma password)

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      // Dispatch evento di registrazione al BLoC
      context.read<AuthBloc>().add(
        AuthRegisterRequested( // Assicurati che questo evento esista nel tuo BLoC
          email: _emailController.text.trim(),
          password: _passwordController.text,
          // Aggiungi altri campi se necessario
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
      ),
      // Aggiungi BlocListener per gestire stati di errore/successo
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Errore Registrazione: ${state.message}')),
              );
          }
          // Potresti voler navigare altrove in caso di successo (AuthSuccess)
          // ma spesso la navigazione è gestita dal redirect di GoRouter basato sullo stato di autenticazione.
        },
        child: Center(
          child: SingleChildScrollView( // Permette lo scroll se la tastiera copre i campi
            padding: const EdgeInsets.all(16.0),
            child: Form( // Usa la Form key
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Allunga i widget figli
                children: [
                  const Text(
                    'Crea Account', // Titolo
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Inserisci una email valida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la password';
                      }
                      if (value.length < 6) { // Controllo lunghezza password
                        return 'La password deve avere almeno 6 caratteri';
                      }
                      return null;
                    },
                  ),
                  // Aggiungi qui un TextFormField per la conferma password se necessario
                  const SizedBox(height: 20),
                  // Usa BlocBuilder per mostrare lo stato di caricamento sul pulsante
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitRegister, // Chiama _submitRegister
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Registrati'),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  // Anche il pulsante per andare al login viene disabilitato durante il caricamento
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return TextButton(
                        onPressed: isLoading ? null : () {
                          // Naviga al login usando GoRouter
                          context.go('/login');
                        },
                        child: const Text('Hai già un account? Accedi'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}