part of 'api_auth_bloc.dart';

@immutable
abstract class ApiAuthEvent {}

class ApiAuthCheckRequested extends ApiAuthEvent {}

class ApiAuthLoginRequested extends ApiAuthEvent {
  final String username;
  final String password;

  ApiAuthLoginRequested(this.username, this.password);
}

class ApiAuthRegisterRequested extends ApiAuthEvent {
  final String username;
  final String email;
  final String password;

  ApiAuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });
}

class ApiAuthLogoutRequested extends ApiAuthEvent {}

class ApiAuthPasswordResetRequested extends ApiAuthEvent {
  final String email;
  ApiAuthPasswordResetRequested(this.email);
}
