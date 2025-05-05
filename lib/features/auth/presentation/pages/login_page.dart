import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    // Unfocus to dismiss keyboard
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    // Define the global gradient like in WelcomePage
    final Gradient globalBackgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.surface.withOpacity(0.0), // Start transparent
        kTomatoRed.withOpacity(0.4), // Slightly stronger accent at bottom
      ],
      stops: const [0.0, 1.0], // Control gradient spread
    );

    // Define SystemUiOverlayStyle like in WelcomePage
    const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      // For iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Make scaffold transparent for gradient
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: globalBackgroundGradient),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('Login Error: ${state.message}'),
                      backgroundColor: colors.error,
                    ),
                  );
              }
              // Navigation on success is handled by the router redirect
            },
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                // Consistent padding
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // Center items
                    children: [
                      // Icon Placeholder (Styled like WelcomePage icons)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: kTomatoRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.login, // Login icon
                          size: 60.0, // Consistent size
                          color: kTomatoRed,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title styled like WelcomePage
                      Text(
                        'Welcome Back!', // Changed Title
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              colors
                                  .onSurface, // Explicitly use onSurface color
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle/Description
                      Text(
                        'Please enter your details to log in.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withOpacity(0.8),
                          // Explicitly use onSurface color
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40), // Increased spacing
                      TextFormField(
                        controller: _emailController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        // Set input text color
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          // Set label color
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: kTomatoRed,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: colors.surfaceVariant.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email'; // Updated message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16), // Consistent spacing
                      TextFormField(
                        controller: _passwordController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        // Set input text color
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          // Set label color
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: kTomatoRed,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: colors.surfaceVariant.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password'; // Updated message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30), // Increased spacing
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return FilledButton(
                            onPressed: isLoading ? null : _submitLogin,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: kTomatoRed,
                              foregroundColor: colors.onPrimary,
                              // Text color for FilledButton
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ).copyWith(
                              overlayColor: const MaterialStatePropertyAll(
                                Colors.transparent,
                              ),
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white, // Ensure contrast
                                      ),
                                    )
                                    : const Text('Log In'),
                          );
                        },
                      ),
                      const SizedBox(height: 16), // Consistent spacing
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return TextButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      context.go('/register');
                                    },
                            style: TextButton.styleFrom(
                              foregroundColor: kTomatoRed,
                              // Explicitly set foreground (text) color
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ).copyWith(
                              overlayColor: const MaterialStatePropertyAll(
                                Colors.transparent,
                              ),
                            ),
                            child: Text(
                              // Ensure Text widget uses the button's foreground color
                              'Don\'t have an account? Register',
                              style: textTheme.labelLarge?.copyWith(
                                color: kTomatoRed,
                              ), // Explicitly set color
                            ),
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
      ),
    );
  }
}
