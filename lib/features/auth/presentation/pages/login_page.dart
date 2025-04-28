
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget { // Changed to StatefulWidget
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> { // State class
  // Controllers and Form Key managed by the State
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

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

  void _submitLogin() {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Dispatch event to the BLoC
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You might provide the AuthBloc higher up the tree (e.g., in main.dart or app.dart)
    // If not, wrap this Scaffold with BlocProvider(create: (_) => AuthBloc(), child: ...)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      // Listen to AuthState changes for side effects (errors, navigation on success maybe)
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Login Error: ${state.message}')),
              );
          }
          // Success state might trigger navigation via GoRouter's refreshListenable/redirect
          // based on FirebaseAuth state, so explicit navigation here might be redundant.
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form( // Use the Form key
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Login', // Title
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController, // Correctly referenced
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
                    controller: _passwordController, // Correctly referenced
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
                      // if (value.length < 6) { // Optional length check
                      //   return 'La password deve avere almeno 6 caratteri';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Use BlocBuilder to show loading state on the button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin, // Call _submitLogin
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Accedi'),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                   BlocBuilder<AuthBloc, AuthState>( // Also disable register button when loading
                     builder: (context, state) {
                       final isLoading = state is AuthLoading;
                       return TextButton(
                         onPressed: isLoading ? null : () {
                           // Navigate to registration using GoRouter
                           context.go('/register');
                         },
                         child: const Text('Non hai un account? Registrati'),
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