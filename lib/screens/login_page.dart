import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth

// Assumiamo che le funzioni signIn e signUp siano in un file auth_service.dart
// import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Istanza di FirebaseAuth (o usa un service separato)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Funzioni di Autenticazione (spostale in un service per pulizia) ---
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Il wrapper gestirà il cambio pagina automaticamente
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code); // Funzione helper per messaggi user-friendly
        });
      } catch (e) {
         setState(() {
          _errorMessage = 'Errore generico: $e';
        });
      } finally {
        if (mounted) { // Controlla se il widget è ancora nell'albero
           setState(() { _isLoading = false; });
        }
      }
    }
  }

  Future<void> _signUp() async {
     if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
         // Il wrapper gestirà il cambio pagina automaticamente (se vuoi login automatico post-registrazione)
         // Oppure mostra un messaggio "Registrazione completata, effettua il login"
      } on FirebaseAuthException catch (e) {
         setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } catch (e) {
         setState(() {
          _errorMessage = 'Errore generico: $e';
        });
      } finally {
         if (mounted) {
           setState(() { _isLoading = false; });
        }
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password': return 'La password è troppo debole.';
      case 'email-already-in-use': return 'Email già in uso. Prova ad accedere.';
      case 'user-not-found': return 'Nessun utente trovato con questa email.';
      case 'wrong-password': return 'Password errata.';
      case 'invalid-email': return 'Formato email non valido.';
      case 'user-disabled': return 'Questo account è stato disabilitato.';
      default: return 'Si è verificato un errore. Riprova. ($code)';
    }
  }
 // --- Fine Funzioni di Autenticazione ---


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accedi o Registrati')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Inserisci una email valida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'La password deve avere almeno 6 caratteri';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Accedi'),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _signUp,
                  child: Text('Registrati'),
                ),
              ],
              SizedBox(height: 15),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}