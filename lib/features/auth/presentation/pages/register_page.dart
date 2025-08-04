import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';

import 'register_shimmer_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          colors.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
      statusBarBrightness: colors.brightness,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness:
          colors.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Registrazione effettuata con successo!'),
                    backgroundColor: colors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              context.go('/home');
            }
            if (state is AuthError) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
            }
          },
          child: const _RegisterForm(),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _showShimmer = true;
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _initializeAnimations();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
        _fadeAnimationController.forward();
        _scaleAnimationController.forward();
      }
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          username: _usernameController.text,
          email: _emailController.text,
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
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;

    if (_showShimmer) {
      return const RegisterShimmerPage();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 48),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: colors.primaryContainer,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'assets/images/KetchApp_Logo.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Create Account',
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join KetchApp to boost your productivity',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _usernameController,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Choose a unique username',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.error,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: colors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colors.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.error,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: colors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Create a strong password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.error,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: colors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.error,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: colors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
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

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submitRegister,
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: colors.primary.withValues(
                                alpha: 0.3,
                              ),
                              textStyle: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child:
                                isLoading
                                    ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colors.onPrimary,
                                      ),
                                    )
                                    : const Text('Create Account'),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  context.go('/login');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  textStyle: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
