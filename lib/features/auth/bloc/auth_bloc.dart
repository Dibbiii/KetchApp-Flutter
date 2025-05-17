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
        String emailToLogin;
        // Determina se l'identifier è un'email o un username
        if (event.identifier.contains('@') && event.identifier.contains('.')) { 
          emailToLogin = event.identifier;
        } else { //dall'username bisogna recuperare l'email perchè firebase utilizza l'email come identificatore primario per l'accesso con email e password
          // È un username, recupera l'email dal backend
          try {
            final userData = await _apiService.findEmailByUsername(event.identifier);
            // Assumendo che findEmailByUsername restituisca una mappa con la chiave 'email'
            // o direttamente la stringa dell'email se il backend è strutturato così.
            // Se userData è una mappa:
            if (userData is Map<String, dynamic> && userData['email'] != null) {
              emailToLogin = userData['email'] as String;
            } 
            // Se userData fosse direttamente la stringa email (meno probabile per un API RESTful JSON):
            else if (userData is String) {
              emailToLogin = userData;
            }
            else {
              emit(const AuthError('Username non trovato o email non associata.'));
              return;
            }
          } on NotFoundException { // Specifica per l'username non trovato
             emit(const AuthError('Username non trovato.'));
             return;
          } on ApiException catch (e) { 
            emit(AuthError('Errore nel recuperare l\'email per l\'username: ${e.message}'));
            return;
          } catch (e) {
            emit(const AuthError('Errore sconosciuto nel recuperare l\'email per l\'username.'));
            return;
          }
        }
    
        await _firebaseAuth.signInWithEmailAndPassword(
          email: emailToLogin,
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
            'username': event.username,
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
      } on UsernameAlreadyExistsException catch (e) {
        await userCredential?.user?.delete(); 
        emit(AuthError(e.message)); 
      } on EmailAlreadyExistsInBackendException catch (e) { 
        await userCredential?.user?.delete();
        emit(AuthError(e.message));
      } on ConflictException catch (e) { 
        // Questo potrebbe coprire altri tipi di 409 se UserAlreadyExistsException è troppo generica
        // o se il backend restituisce un 409 non specifico per username/email.
        await userCredential?.user?.delete();
        emit(AuthError(e.message));
      } on ApiException catch (e) { 
        await userCredential?.user?.delete();
        emit(AuthError(
            'Registrazione Firebase riuscita, ma errore del server: ${e.message}'));
      } catch (e, s) { // Aggiunto StackTrace s per un debug migliore
        await userCredential?.user?.delete();
        // Aggiungi e.toString() e lo stack trace per un debug più dettagliato
        print('[AuthBloc] Errore generico in AuthRegisterRequested: ${e.toString()}');
        print('[AuthBloc] StackTrace: ${s.toString()}');
        emit(AuthError('Errore sconosciuto durante la registrazione: ${e.toString()}'));
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