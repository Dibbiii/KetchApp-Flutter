import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn(); // Crea istanza GoogleSignIn

// ... (le funzioni signUpWithEmailPassword e signInWithEmailPassword rimangono)

// Funzione per il Login con Google
Future<User?> signInWithGoogle() async {
  try {
    // 1. Avvia il flusso di accesso di Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Se l'utente annulla il flusso
    if (googleUser == null) {
      print('Accesso Google annullato dall\'utente.');
      return null;
    }

    // 2. Ottieni i dettagli di autenticazione dalla richiesta
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Crea una credenziale Firebase con i token di Google
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Accedi a Firebase usando la credenziale
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    print('Accesso Google riuscito: ${user?.uid}');
    return user;

  } on FirebaseAuthException catch (e) {
    print('Errore FirebaseAuth durante accesso Google: ${e.message} (codice: ${e.code})');
    // Potresti voler gestire codici specifici come 'account-exists-with-different-credential'
    return null;
  } catch (e) {
    print('Errore generico durante accesso Google: $e');
    return null;
  }
}

// Funzione SignOut (già presente ma la riporto per completezza)
Future<void> signOut() async {
  try {
    // Importante: Fai il sign out anche da Google per permettere cambio account
    await _googleSignIn.signOut();
    await _auth.signOut();
    print('Disconnessione riuscita');
  } catch (e) {
    print('Errore durante la disconnessione: $e');
  }
}