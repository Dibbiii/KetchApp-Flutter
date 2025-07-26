part of 'api_auth_bloc.dart';

@immutable
abstract class ApiAuthState {}

class ApiAuthInitial extends ApiAuthState {}

class ApiAuthLoading extends ApiAuthState {}

class ApiAuthenticated extends ApiAuthState {
  // Potresti voler salvare qui i dati dell'utente o il token
  final Map<String, dynamic> userData;
  ApiAuthenticated(this.userData);
}

class ApiUnauthenticated extends ApiAuthState {}

class ApiAuthFailure extends ApiAuthState {
  final String error;
  ApiAuthFailure(this.error);
}

class ApiAuthPasswordResetSuccess extends ApiAuthState {
  final String message;
  ApiAuthPasswordResetSuccess(this.message);
}

