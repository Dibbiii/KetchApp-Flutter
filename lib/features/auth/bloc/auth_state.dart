// filepath: lib/features/auth/bloc/auth_state.dart
part of 'auth_bloc.dart'; // Associa questo file al bloc

@immutable
abstract class AuthState {
  const AuthState();
}

// Stato iniziale o mentre si verifica lo stato
class AuthInitial extends AuthState {}

// Stato durante un'operazione (login, registrazione)
class AuthLoading extends AuthState {
   
}

// Stato quando l'utente è autenticato
class Authenticated extends AuthState {

  final User user; // Potresti voler passare l'oggetto User
  const Authenticated(this.user);
}

// Stato quando l'utente non è autenticato
class Unauthenticated extends AuthState {}

// Stato quando si verifica un errore di autenticazione
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}