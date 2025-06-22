import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ketchapp_flutter/features/plan/models/plan_model.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/models/achievement.dart';
import './api_exceptions.dart';

class ApiService {
  final String _baseUrl = "http://192.168.1.22:8081/api";

  Future<dynamic> _processResponse(http.Response response) {
    final body = response.body;
    dynamic decodedJson;
    try {
      decodedJson = json.decode(body);
    } catch (e) {
      // TODO: Se il corpo non è JSON valido o è vuoto per alcuni successi (es. 204 No Content)
      // gestisci di conseguenza. Per ora, se non è 2xx, lanciamo un errore.
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return Future.value(decodedJson ?? body); 
      case 400:
        throw BadRequestException(decodedJson?['message'] ?? 'Richiesta non valida');
      case 401:
        throw UnauthorizedException(decodedJson?['message'] ?? 'Non autorizzato');
      case 403:
        throw ForbiddenException(decodedJson?['message'] ?? 'Accesso negato');
      case 404:
        throw NotFoundException(decodedJson?['message'] ?? 'Risorsa non trovata');
      case 409: // Conflict
        throw UserAlreadyExistsException(decodedJson?['message'] ?? 'L\'utente esiste già.');
      case 500:
        throw InternalServerErrorException(decodedJson?['message'] ?? 'Errore interno del server');
      default:
        throw ApiException(
            'Errore durante la comunicazione con il server: ${response.statusCode}',
            response.statusCode);
    }
  }

  Future<dynamic> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint')); 
    return _processResponse(response);
  }

  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async { 
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 409) { // HTTP 409 Conflict - Gestione personalizzata per postData
      final responseBody = json.decode(response.body);
      // Supponiamo che il backend restituisca un campo 'error_code' o 'message'
      // per distinguere il tipo di conflitto.
      final String? errorCode = responseBody['error_code'] as String?;
      final String message = responseBody['message'] as String? ?? 'Risorsa già esistente.';

      if (errorCode == 'USERNAME_TAKEN' || message.toLowerCase().contains('username')) {
        throw UsernameAlreadyExistsException(message);
      } else if (errorCode == 'EMAIL_TAKEN_BACKEND' || message.toLowerCase().contains('email')) {
        throw EmailAlreadyExistsInBackendException(message);
      }
      // Se è un 409 ma non specificamente username/email duplicato, lancia una ConflictException generica
      throw ConflictException(message);
    } else {
      // Per tutti gli altri stati di errore, usa il metodo generico _processResponse
      return _processResponse(response);
    }
  }

  Future<dynamic> deleteData(String endpoint) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$endpoint'));
    return _processResponse(response);
  }

  Future<dynamic> findEmailByUsername(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/email/$username'));
    return _processResponse(response);
  }

  Future<String> getUserUUIDByFirebaseUid(String firebaseUid) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/users/firebase/$firebaseUid'));
    final responseData = await _processResponse(response);
    return responseData.toString();
  }

  Future<void> createPlan(PlanModel plan) async {
    final planData = plan.toJson();
    // ignore: avoid_print
    print('Creating plan with data: ${json.encode(planData)}');
    try {
      final response = await postData('plans', planData);
      print('Response from createPlan: $response');
    } catch (e) {
      // ignore: avoid_print
      print('Error in createPlan: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserByFirebaseUid(String firebaseUid) async {
    // ignore: avoid_print
    print('Fetching user by Firebase UID: $firebaseUid');
    try {
      final response = await fetchData('users/firebase/$firebaseUid');
      // Assumendo che la risposta sia un JSON object con i dati dell'utente
      return response as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('Error in getUserByFirebaseUid: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getUsersForRanking() async {
    final response =  await fetchData("users");
    return response as List<dynamic>;
  }

  Future<Future> getGlobalRanking() async {
    final response = await http.get(Uri.parse('$_baseUrl/users/ranking/global'));
    return _processResponse(response);
  }

  Future<List<Tomato>> getTodaysTomatoes(String userUuid) async {
    // ignore: avoid_print
    print('Fetching tomatoes for user: $userUuid');
    final response = await fetchData('users/$userUuid/tomatoes/today');
    final List<dynamic> tomatoesJson = response as List<dynamic>;
    return tomatoesJson.map((json) => Tomato.fromJson(json)).toList();
  }

  Future<List<Achievement>> getAchievements(String userUuid) async {
    final response = await fetchData('users/$userUuid/achievements');
    final List<dynamic> achievementsJson = response as List<dynamic>;
    return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
  }

  Future<Tomato> getTomatoById(int tomatoId) async {
    // ignore: avoid_print
    print('Fetching tomato with id: $tomatoId');
    final response = await fetchData('tomatoes/$tomatoId');
    return Tomato.fromJson(response);
  }

  Future<void> createActivity(
      String userUUID, int tomatoId, ActivityAction action) async {
    try {
      await postData('activities', {
        'userUUID': userUUID,
        'tomatoId': tomatoId,
        'type': 'TIMER',
        'action': action.name,
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error creating activity: $e');
      rethrow;
    }
  }


  // Implementa metodi simili per PUT, DELETE, ecc., usando _processResponse
}