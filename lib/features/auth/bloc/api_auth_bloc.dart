import 'package:bloc/bloc.dart';
import 'package:ketchapp_flutter/services/api_auth_service.dart';
import 'package:ketchapp_flutter/services/api_exceptions.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:meta/meta.dart';

part 'api_auth_event.dart';
part 'api_auth_state.dart';

class ApiAuthBloc extends Bloc<ApiAuthEvent, ApiAuthState> {
  final ApiAuthService _apiAuthService;
  final ApiService _apiService; // Per gestire il token

  ApiAuthBloc({required ApiAuthService apiAuthService, required ApiService apiService})
      : _apiAuthService = apiAuthService,
        _apiService = apiService,
        super(ApiAuthInitial()) {
    on<ApiAuthCheckRequested>((event, emit) async {
      emit(ApiAuthLoading());
      try {
        final isAuthenticated = await _apiAuthService.isAuthenticated();
        if (isAuthenticated) {
          // Se il token è valido, potresti voler recuperare i dati dell'utente
          final userData = await _apiService.fetchData('auth/me');
          emit(ApiAuthenticated(userData));
        } else {
          emit(ApiUnauthenticated());
        }
      } catch (_) {
        emit(ApiUnauthenticated());
      }
    });

    on<ApiAuthLoginRequested>((event, emit) async {
      emit(ApiAuthLoading());
      try {
        final response = await _apiAuthService.login(event.username, event.password);
        // Assumendo che la risposta contenga il token e i dati utente
        final token = response['token'];
        final user = response['user'];

        // Salva il token nel servizio API per le richieste future
        _apiService.setAuthToken(token);

        emit(ApiAuthenticated(user));
      } on ApiException catch (e) {
        emit(ApiAuthFailure(e.message));
      } catch (e) {
        emit(ApiAuthFailure('Errore sconosciuto durante il login: ${e.toString()}'));
      }
    });

    on<ApiAuthRegisterRequested>((event, emit) async {
      emit(ApiAuthLoading());
      try {
        await _apiAuthService.register(
          username: event.username,
          email: event.email,
          password: event.password,
        );
        // Dopo la registrazione, potresti voler effettuare il login automaticamente
        add(ApiAuthLoginRequested(event.email, event.password));
      } on ApiException catch (e) {
        emit(ApiAuthFailure(e.message));
      } catch (e) {
        emit(ApiAuthFailure('Errore sconosciuto durante la registrazione: ${e.toString()}'));
      }
    });

    on<ApiAuthLogoutRequested>((event, emit) async {
      emit(ApiAuthLoading());
      try {
        await _apiAuthService.logout();
        _apiService.clearAuthToken(); // Rimuovi il token
        emit(ApiUnauthenticated());
      } on ApiException catch (e) {
        emit(ApiAuthFailure(e.message));
      } catch (e) {
        emit(ApiAuthFailure('Errore durante il logout: ${e.toString()}'));
      }
    });

    on<ApiAuthPasswordResetRequested>((event, emit) async {
      emit(ApiAuthLoading());
      try {
        await _apiAuthService.sendPasswordResetEmail(event.email);
        emit(ApiAuthPasswordResetSuccess('Email di reset inviata a ${event.email}.'));
      } on ApiException catch (e) {
        emit(ApiAuthFailure(e.message));
      } catch (e) {
        emit(ApiAuthFailure('Errore durante la richiesta di reset password: ${e.toString()}'));
      }
    });
  }
}
