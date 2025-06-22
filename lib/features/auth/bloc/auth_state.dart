part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthVerifying extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final bool isGoogleSignIn;

  const Authenticated(this.user, {this.isGoogleSignIn = false});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthPasswordResetEmailSentSuccess extends AuthState {
  final String message;
  const AuthPasswordResetEmailSentSuccess(this.message);
}