import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
 import '../../../services/api_service.dart';
import '../../../services/api_exceptions.dart'; // MODIFICA: Aggiungi import per le eccezioni API

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final ApiService _apiService; 
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({
    required FirebaseAuth firebaseAuth,
    required ApiService apiService,
  })  : _firebaseAuth = firebaseAuth,
        _apiService = apiService,
        super(AuthInitial()) {
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(_AuthUserChanged(user));
    });

    on<_AuthUserChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user!));
      } else {
        emit(Unauthenticated());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        // Non emettere Authenticated qui, lo stream authStateChanges lo farà
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthErrorCodeToMessage(e.code)));
      } catch (e) {
        emit(const AuthError('Errore sconosciuto durante il login.'));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      UserCredential? userCredential; // Dichiaralo qui per accedervi nel blocco catch

      try {
        userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        if (userCredential.user != null) {
          // Chiama il tuo backend per salvare/verificare l'utente
          await _apiService.postData('users', { // Sostituisci 'users/register'
            'firebaseUid': userCredential.user!.uid,
            'email': event.email,
            'username': "test",
            // Aggiungi altri campi se necessario
          });
          // Se la chiamata al backend ha successo, lo stream authStateChanges
          // gestirà l'emissione dello stato Authenticated.
          // Non è necessario emettere Authenticated qui.
        } else {
          // Questo caso dovrebbe essere raro se createUserWithEmailAndPassword ha successo
          emit(const AuthError('Registrazione Firebase riuscita ma utente nullo.'));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthErrorCodeToMessage(e.code)));
      } on UserAlreadyExistsException catch (e) { // MODIFICA: Gestisci UserAlreadyExistsException
        // L'utente Firebase è stato creato, ma esiste già nel tuo backend.
        // Potresti voler eliminare l'utente Firebase per mantenere la consistenza.
        // Questo richiede che l'utente sia stato recentemente autenticato.
        // Se l'utente è stato appena creato, userCredential.user?.delete() potrebbe funzionare.
        await userCredential?.user?.delete(); // Tenta di eliminare l'utente Firebase
        emit(AuthError(e.message)); // Usa il messaggio dall'eccezione
      } on ApiException catch (e) { // MODIFICA: Gestisci altre eccezioni API generiche
        // Errore durante la comunicazione con il backend
        // Se l'utente Firebase è stato creato, considera di eliminarlo.
        await userCredential?.user?.delete();
        emit(AuthError(
            'Registrazione Firebase riuscita, ma errore del server: ${e.message}'));
      } catch (e) {
        // Errore generico
        // Se l'utente Firebase è stato creato, considera di eliminarlo.
        await userCredential?.user?.delete();
        emit(const AuthError('Errore sconosciuto durante la registrazione.'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.signOut();
        // Lo stream authStateChanges emetterà Unauthenticated
      } catch (e) {
        emit(const AuthError('Errore durante il logout.'));
      }
    });
  }

  String _mapAuthErrorCodeToMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenziali non valide.';
      case 'invalid-email':
        return 'L\'indirizzo email non è valido.';
      case 'email-already-in-use':
        return 'L\'account Firebase esiste già per questa email.';
      case 'weak-password':
        return 'La password fornita è troppo debole.';
      default:
        return 'Errore di autenticazione Firebase. Riprova.';
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}