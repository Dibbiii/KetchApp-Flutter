import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart'; // Include gli eventi
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth,
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
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthErrorCodeToMessage(e.code)));
      } catch (e) {
        emit(const AuthError('Errore sconosciuto durante il login.'));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        // TODO: Salva dati extra su Firestore
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

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
          await _firebaseAuth.signOut();
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
        return 'L\'account esiste già per questa email.';
      case 'weak-password':
        return 'La password fornita è troppo debole.';
      default:
        return 'Errore di autenticazione. Riprova.';
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}