part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthVerifying extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String id;
  final String username;
  final String email;
  final String token;
  const AuthAuthenticated(this.id, this.username, this.email, this.token);
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
