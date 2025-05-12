import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Removed unused app_colors import as Theme.of(context) is used

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
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

    // SystemUiOverlayStyle consistent with LoginPage
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Assuming light theme for status bar icons
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface, // Matched with LoginPage
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colors.error,
                  ),
                );
            }
            // Successful registration navigation is typically handled by the router based on AuthState changes
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
              ), // Matched with LoginPage
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Google logo style (copied from LoginPage)
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            Colors.white, // Assuming a light theme context
                        child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/1200px-Google_2015_logo.svg.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
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
                      'Create account', // Changed title for registration
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'to get started with KetchApp', // Changed subtitle
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Material(
                      // TextFormField styling matched with LoginPage
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8),
                      child: TextFormField(
                        controller: _emailController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          // Changed hint text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: colors.onSurface.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      // TextFormField styling matched with LoginPage
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8),
                      child: TextFormField(
                        controller: _passwordController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: colors.onSurface.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      // TextFormField styling matched with LoginPage
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: colors.onSurface.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitRegister(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 28), // Adjusted spacing
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          // Matched with LoginPage
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submitRegister,
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
                                    : const Text(
                                      'Register',
                                    ), // Changed button text
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18), // Adjusted spacing
                    BlocBuilder<AuthBloc, AuthState>(
                      // Matched with LoginPage
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Row(
                          // Using Row for "Already have an account? Log In"
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withOpacity(0.7),
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  isLoading ? null : () => context.go('/login'),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                ), // Added padding for better spacing
                                textStyle: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Log In'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
