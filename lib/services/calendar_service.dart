import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/googleapis_auth.dart' as gapi_auth;
import 'package:http/http.dart' as http;

const List<String> _calendarScopes = <String>[
  cal.CalendarApi.calendarScope,
];

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _calendarScopes);

  Future<cal.CalendarApi?> getCalendarApi() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    gapi_auth.AccessCredentials? credentials;
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null) {
        throw Exception('Google Sign-In access token is null');
      }
      credentials = gapi_auth.AccessCredentials(
        gapi_auth.AccessToken(
          "Bearer",
          googleAuth.accessToken!,
          DateTime.now().toUtc().add(const Duration(minutes: 55)),
        ),
        null,
        _calendarScopes,
      );
    } catch (e) {
      return null;
    }

    final httpClient = gapi_auth.authenticatedClient(
        http.Client(),
        credentials,
        closeUnderlyingClient: true,
    );

    return cal.CalendarApi(httpClient);
  }

  Future<List<cal.Event>> getEvents() async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) {
      return [];
    }

    try {
      final now = DateTime.now();
      final timeMin = DateTime(now.year, now.month, 1).toUtc();
      final timeMax = DateTime(now.year, now.month + 1, 1).toUtc();

      final cal.Events eventsResult = await calendarApi.events.list(
        'primary',
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: 'startTime',
      );
      return eventsResult.items ?? [];
    } catch (e) {
      if (e is cal.DetailedApiRequestError) {
      } else {
      }
      return [];
    }
  }

  Future<void> addEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) {
      return;
    }
  }
}

