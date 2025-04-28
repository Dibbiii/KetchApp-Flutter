// filepath: lib/features/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
// Importa altri servizi se necessario (es. Firestore per salvare dati utente)
// import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart'; // Include gli eventi
part 'auth_state.dart'; // Include gli stati

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  // final FirebaseFirestore _firestore; // Se salvi dati extra
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required FirebaseAuth firebaseAuth /*, required FirebaseFirestore firestore */})
      : _firebaseAuth = firebaseAuth,
        // _firestore = firestore,
        super(AuthInitial()) { // Stato iniziale

    // Ascolta i cambiamenti di stato di FirebaseAuth
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(_AuthUserChanged(user)); // Invia un evento interno al BLoC
    });

    // Gestore per l'evento interno di cambio utente
    on<_AuthUserChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user!)); // Utente loggato
      } else {
        emit(Unauthenticated()); // Utente non loggato
      }
    });

    // Gestore per la richiesta di login
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading()); // Mostra caricamento
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        // Non emettere Authenticated qui, lo stream authStateChanges lo farà
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthErrorCodeToMessage(e.code))); // Emetti errore
      } catch (e) {
        emit(const AuthError('Errore sconosciuto durante il login.'));
      }
    });

    // Gestore per la richiesta di registrazione
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        // --- OPZIONALE: Salva dati extra su Firestore ---
        // if (userCredential.user != null) {
        //   await _firestore.collection('users').doc(userCredential.user!.uid).set({
        //     'email': event.email,
        //     'username': event.username, // Se hai un campo username
        //     'createdAt': FieldValue.serverTimestamp(),
        //   });
        // }
        // ---------------------------------------------

        // Non emettere Authenticated qui, lo stream authStateChanges lo farà
      } on FirebaseAuthException catch (e) {
         emit(AuthError(_mapAuthErrorCodeToMessage(e.code)));
      } catch (e) {
        emit(const AuthError('Errore sconosciuto durante la registrazione.'));
      }
    });

    // Gestore per la richiesta di logout
    on<AuthLogoutRequested>((event, emit) async {
       emit(AuthLoading()); // Opzionale: mostrare caricamento per logout
       try {
          await _firebaseAuth.signOut();
          // Non emettere Unauthenticated qui, lo stream authStateChanges lo farà
       } catch (e) {
          emit(const AuthError('Errore durante il logout.')); // Gestisci errore logout
       }
    });
  }

  // Helper per mappare codici di errore Firebase a messaggi user-friendly
  String _mapAuthErrorCodeToMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // Nuovo codice per credenziali errate
        return 'Credenziali non valide.';
      case 'invalid-email':
        return 'L\'indirizzo email non è valido.';
      case 'email-already-in-use':
        return 'L\'account esiste già per questa email.';
      case 'weak-password':
        return 'La password fornita è troppo debole.';
      default:
        return 'Errore di autenticazione. Riprova.';
    }
  }

  // Cancella la sottoscrizione quando il BLoC viene chiuso
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}