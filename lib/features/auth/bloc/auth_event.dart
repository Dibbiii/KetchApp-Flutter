// filepath: lib/features/auth/bloc/auth_event.dart
part of 'auth_bloc.dart'; // Associa questo file al bloc

@immutable // Gli eventi dovrebbero essere immutabili
abstract class AuthEvent {}

// Evento inviato quando l'utente tenta il login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

// Evento inviato quando l'utente tenta la registrazione
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  // Aggiungi altri campi necessari per la registrazione (es. username)
  // final String username;

  AuthRegisterRequested({required this.email, required this.password /*, required this.username */});
}

// Evento inviato quando l'utente richiede il logout
class AuthLogoutRequested extends AuthEvent {}

// Evento interno per notificare cambiamenti dallo stream di FirebaseAuth
class _AuthUserChanged extends AuthEvent {
  final User? user;
  _AuthUserChanged(this.user);
}