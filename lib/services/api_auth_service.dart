import 'package:ketchapp_flutter/services/api_service.dart';

class ApiAuthService {
  final String _authBaseUrl = "http://151.61.228.91:8080/api";
  final ApiService _apiService;

  ApiAuthService(this._apiService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.postData(
      'auth/login',
      {
        'username': username,
        'password': password,
      },
      baseUrlOverride: _authBaseUrl,
    );
    return response;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _apiService.postData(
      'auth/register',
      {
        'username': username,
        'email': email,
        'password': password,
      },
      baseUrlOverride: _authBaseUrl,
    );
  }

  Future<void> logout() async {
    // Assumendo un endpoint di logout che invalida il token sul server
    await _apiService.postData('auth/logout', {});
    // Qui dovresti cancellare il token salvato localmente.
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _apiService.postData('auth/request-password-reset', {
      'email': email,
    });
  }

  // Potrebbe essere necessario un metodo per ottenere lo stato di autenticazione
  // controllando la validità del token salvato.
  Future<bool> isAuthenticated() async {
    // Esempio: controlla se un token è salvato e non è scaduto.
    // Potresti anche avere un endpoint /auth/me o /auth/user per verificarlo.
    try {
      await _apiService.fetchData('auth/me');
      return true;
    } catch (e) {
      return false;
    }
  }
}
