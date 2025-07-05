import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ketchapp_flutter/features/plan/models/plan_model.dart';
import 'package:ketchapp_flutter/models/tomato.dart';
import 'package:ketchapp_flutter/models/activity_action.dart';
import 'package:ketchapp_flutter/models/achievement.dart';
import './api_exceptions.dart';
import 'package:ketchapp_flutter/services/calendar_service.dart';
import 'package:ketchapp_flutter/services/notification_service.dart';
import 'package:ketchapp_flutter/models/activity.dart';
import 'package:ketchapp_flutter/models/activity_type.dart';

class ApiService {
  final String _baseUrl = "http://192.168.43.22:8081/api";

  Future<dynamic> _processResponse(http.Response response) {
    final body = response.body;
    dynamic decodedJson;
    try {
      decodedJson = json.decode(body);
    } catch (e) {
      decodedJson = body;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return Future.value(decodedJson);
      case 400:
        throw BadRequestException(decodedJson is Map ? decodedJson['message'] ?? 'Richiesta non valida' : 'Richiesta non valida');
      case 401:
        throw UnauthorizedException(decodedJson is Map ? decodedJson['message'] ?? 'Non autorizzato' : 'Non autorizzato');
      case 403:
        throw ForbiddenException(decodedJson is Map ? decodedJson['message'] ?? 'Accesso negato' : 'Accesso negato');
      case 404:
        throw NotFoundException(decodedJson is Map ? decodedJson['message'] ?? 'Risorsa non trovata' : 'Risorsa non trovata');
      case 409:
        throw UserAlreadyExistsException(decodedJson is Map ? decodedJson['message'] ?? 'L\'utente esiste già.' : 'L\'utente esiste già.');
      case 500:
        throw InternalServerErrorException(decodedJson is Map ? decodedJson['message'] ?? 'Errore interno del server' : 'Errore interno del server');
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code: ${response.statusCode}');
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

    return _processResponse(response);
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
    try {
      final response = await postData('plans', planData);

      if (response != null && response['subjects'] != null) {
        for (final subject in response['subjects']) {
          final subjectName = subject['name'] ?? 'Pomodoro';
          if (subject['tomatoes'] != null) {
            for (final tomato in subject['tomatoes']) {
              final startAt = tomato['start_at'];
              final endAt = tomato['end_at'];
              if (startAt != null && endAt != null) {
                final start = DateTime.parse(startAt);
                final notificationStart = start.subtract(const Duration(minutes: 15));
                final end = DateTime.parse(endAt);
                await CalendarService().addEvent(
                  title: subjectName,
                  start: start,
                  end: end,
                  description: 'Sessione Pomodoro creata da KetchApp',
                );
                await NotificationService.schedulePomodoroNotification(subjectName, notificationStart);
              }
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await fetchData('users/firebase/$firebaseUid');
      return response as Map<String, dynamic>;
    } catch (e) {
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
    final today = DateTime.now().toUtc();
    final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final response = await fetchData('users/$userUuid/tomatoes?date=$todayStr');
    final List<dynamic> tomatoesJson = response as List<dynamic>;
    List<Tomato> tomatoes = tomatoesJson.map((json) => Tomato.fromJson(json)).toList();

    for (var tomato in tomatoes) {
      tomato.activities = await getTomatoActivities(tomato.id);
    }

    return tomatoes;
  }

  Future<List<Activity>> getTomatoActivities(int tomatoId) async {
    final response = await fetchData('tomatoes/$tomatoId/activities');
    final List<dynamic> activitiesJson = response as List<dynamic>;
    return activitiesJson.map((json) => Activity.fromJson(json)).toList();
  }

  Future<List<Achievement>> getUserAchievements(String userUuid) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$userUuid/achievements'));
    final decodedJson = await _processResponse(response);
    return (decodedJson as List).map((e) => Achievement.fromJson(e)).toList();
  }


  Future<List<dynamic>> getAllAchievements() async {
    final response = await fetchData('achievements');
    return response as List<dynamic>;
  }


  Future<List<dynamic>> getAchievements(String userUuid) async {
    final response = await fetchData('users/$userUuid/achievements');
    return response as List<dynamic>;
  }

  Future<Tomato> getTomatoById(int tomatoId) async {
    final response = await fetchData('tomatoes/$tomatoId');
    return Tomato.fromJson(response);
  }

  Future<void> createActivity(
      String userUUID, int tomatoId, ActivityAction action, ActivityType type) async {
    try {
      await postData('activities', {
        'userUUID': userUUID,
        'tomatoId': tomatoId,
        'type': type.name,
        'action': action.name,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Tomato>> getTomatoChain(int firstTomatoId) async {
    final List<Tomato> chain = [];
    int? currentId = firstTomatoId;
    while (currentId != null) {
      final tomato = await getTomatoById(currentId);
      chain.add(tomato);
      currentId = tomato.nextTomatoId;
    }
    return chain;
  }
}
