import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart'; // Import the BLoC
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class RegisterPage extends StatefulWidget {
  // Converted to StatefulWidget
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // State class
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController
  _confirmPasswordController; // Added confirm password controller

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController =
        TextEditingController(); // Initialize confirm password controller
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose confirm password controller
    super.dispose();
  }

  void _submitRegister() {
    // Unfocus to dismiss keyboard
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Dispatch registration event to BLoC
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          // Ensure this event exists in your BLoC
          email: _emailController.text.trim(),
          password: _passwordController.text,
          // Add other fields if necessary
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    // Define the global gradient like in LoginPage
    final Gradient globalBackgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.surface.withOpacity(0.0), // Start transparent
        kTomatoRed.withOpacity(0.4), // Slightly stronger accent at bottom
      ],
      stops: const [0.0, 1.0], // Control gradient spread
    );

    // Define SystemUiOverlayStyle like in LoginPage
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
        // Removed AppBar
        backgroundColor:
            Colors.transparent, // Make scaffold transparent for gradient
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: globalBackgroundGradient),
          // Add BlocListener to handle error/success states
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'Registration Error: ${state.message}',
                      ), // English text
                      backgroundColor: colors.error,
                    ),
                  );
              }
              // Navigation on success is often handled by GoRouter's redirect based on auth state.
            },
            child: Center(
              child: SingleChildScrollView(
                // Allows scrolling if keyboard covers fields
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1,
                ), // Consistent padding
                child: Form(
                  // Use the Form key
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center, // Center items like LoginPage
                    children: [
                      // Icon Placeholder (Styled like LoginPage icons)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: kTomatoRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1, // Registration icon
                          size: 60.0, // Consistent size
                          color: kTomatoRed,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title styled like LoginPage
                      Text(
                        'Create Account', // English Title
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
                        'Enter your details to create an account.',
                        // English text
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withOpacity(
                            0.8,
                          ), // Explicitly use onSurface color
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
                          // Styled like LoginPage
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
                            return 'Please enter a valid email'; // English message
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
                          // Styled like LoginPage
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
                        textInputAction: TextInputAction.next,
                        // Change to next
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password'; // English message
                          }
                          if (value.length < 6) {
                            // Password length check
                            return 'Password must be at least 6 characters'; // English message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16), // Consistent spacing
                      // Add TextFormField for password confirmation
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        // Set input text color
                        decoration: InputDecoration(
                          // Styled like LoginPage
                          labelText: 'Confirm Password',
                          // English label
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
                        // Change to done
                        onFieldSubmitted: (_) => _submitRegister(),
                        // Submit on done
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password'; // English message
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match'; // English message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30), // Increased spacing
                      // Use BlocBuilder to show loading state on the button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return FilledButton(
                            // Styled like LoginPage 'Log In'
                            onPressed:
                                isLoading
                                    ? null
                                    : _submitRegister, // Call _submitRegister
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: kTomatoRed,
                              foregroundColor: colors.onPrimary,
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
                                    : const Text('Register'), // English text
                          );
                        },
                      ),
                      const SizedBox(height: 16), // Consistent spacing
                      // Also disable the button to go to login during loading
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return TextButton(
                            // Styled like LoginPage secondary button
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      // Navigate to login using GoRouter
                                      context.go('/login');
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
                              'Already have an account? Log In', // English text
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
