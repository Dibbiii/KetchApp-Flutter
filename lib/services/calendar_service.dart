import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/googleapis_auth.dart' as gapi_auth;
import 'package:http/http.dart' as http;

const List<String> _calendarScopes = <String>[
  cal.CalendarApi.calendarReadonlyScope,
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
      // L'utente non è loggato o ha rifiutato i permessi
      print('CalendarService: GoogleUser is null. Utente non loggato o permessi rifiutati.');
      return null;
    }

    gapi_auth.AccessCredentials? credentials;
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null) {
        print('CalendarService: Google Sign-In access token is null.');
        throw Exception('Google Sign-In access token is null');
      }
      credentials = gapi_auth.AccessCredentials(
        gapi_auth.AccessToken(
          "Bearer",
          googleAuth.accessToken!,
          DateTime.now().toUtc().add(const Duration(minutes: 55)), // Stima leggermente inferiore a 1 ora
        ),
        null,
        _calendarScopes,
      );
    } catch (e) {
      print('CalendarService: Errore durante il recupero delle credenziali: $e');
      return null;
    }

    if (credentials == null) {
      print('CalendarService: Credenziali non ottenute.');
      return null;
    }

    final httpClient = gapi_auth.authenticatedClient(
        http.Client(), // Un client HTTP di base
        credentials,
        closeUnderlyingClient: true, // Chiude http.Client() quando httpClient viene chiuso
    );

    return cal.CalendarApi(httpClient);
  }

  Future<List<cal.Event>> getEvents() async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) {
      print('CalendarService: CalendarApi non disponibile, impossibile recuperare eventi.');
      return [];
    }

    try {
      // Calcola l'inizio del mese corrente e l'inizio del mese successivo
      final now = DateTime.now();
      final timeMin = DateTime(now.year, now.month, 1).toUtc();
      final timeMax = DateTime(now.year, now.month + 1, 1).toUtc(); // Inizio del mese successivo
      print('CalendarService: Richiesta eventi da $timeMin a $timeMax');

      final cal.Events eventsResult = await calendarApi.events.list(
        'primary',
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: 'startTime',
      );
      print('CalendarService: Eventi recuperati: ${eventsResult.items?.length ?? 0}');
      return eventsResult.items ?? [];
    } catch (e) {
      print('CalendarService: Errore nel recuperare gli eventi: $e');
      if (e is cal.DetailedApiRequestError) {
        print('CalendarService: Dettagli DetailedApiRequestError: ${e.message}, Status: ${e.status}, Errors: ${e.errors}');
      } else {
        print('CalendarService: Tipo errore non specifico: ${e.runtimeType}');
      }
      return [];
    }
  }
}