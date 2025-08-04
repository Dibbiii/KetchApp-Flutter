import 'package:bloc/bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc({required ApiService apiService})
    : _apiService = apiService,
      super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _apiService.postData('auth/login', {
          'username': event.username,
          'password': event.password,
        });
        await _apiService.setAuthToken(response['token']);
        emit(
          AuthAuthenticated(
            response['id'],
            response['username'],
            response['email'],
            response['token'],
          ),
        );
      } catch (e) {
        emit(AuthError('Login fallito: ${e.toString()}'));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _apiService.postData('auth/register', {
          'username': event.username,
          'email': event.email,
          'password': event.password,
        });
        await _apiService.setAuthToken(response['token']);
        emit(
          AuthAuthenticated(
            response['id'],
            response['username'],
            response['email'],
            response['token'],
          ),
        );
      } catch (e) {
        emit(AuthError('Registrazione fallita: ${e.toString()}'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await _apiService.clearAuthToken();
      emit(Unauthenticated());
    });
  }
}
