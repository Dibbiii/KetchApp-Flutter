part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  AuthRegisterRequested({required this.username, required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {
  final String? token;
  AuthLogoutRequested({this.token});

}

class AuthGoogleSignInRequested extends AuthEvent {
  final String? token;
  AuthGoogleSignInRequested({this.token});
} 

class _AuthUserChanged extends AuthEvent {
  final User? user;
  _AuthUserChanged(this.user);
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested({required this.email});
}