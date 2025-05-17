import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme
        .of(context)
        .colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Use mounted check for safety
            if (!mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colors.error,
                ),
              );
          }
        },
        child:
        const _LoginForm(), 
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController; 
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(); 
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose(); 
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              identifier: _identifierController.text.trim(), //trim serve per rimuovere gli spazi
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Google logo style
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor:
                  Colors.white, // Assuming a light theme context
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/1200px-Google_2015_logo.svg.png',
                    width: 48,
                    // Slightly increased size
                    height: 48,
                    // Slightly increased size
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context,
                        Object error,
                        StackTrace? stackTrace,) {
                      return Text(
                        'G',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                'Sign in',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'to continue to KetchApp',
                style: textTheme.bodyMedium?.copyWith(
                  // Changed from bodyLarge
                  color: colors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
                child: TextFormField(
                  controller: _identifierController, // MODIFICATO
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Email or Username', // MODIFICATO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Added focusedBorder
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 2.0),
                    ),
                    filled: true,
                    fillColor: colors.onSurface.withOpacity(
                      0.05,
                    ),
                    // Subtle fill color
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                  ),
                  keyboardType: TextInputType.text, // MODIFICATO: da emailAddress a text
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email or username'; // MODIFICATO
                    }
                    // Potresti aggiungere una validazione più specifica se necessario
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
                child: TextFormField(
                  controller: _passwordController,
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Added focusedBorder
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 2.0),
                    ),
                    filled: true,
                    fillColor: colors.onSurface.withOpacity(
                      0.05,
                    ),
                    // Subtle fill color
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // Implement forgot password logic
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    textStyle: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submitLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child:
                      isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Next'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.zero,
                      textStyle: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
