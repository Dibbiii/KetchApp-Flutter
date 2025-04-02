import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isPasswordInvisible = true;
  bool isCheckboxChecked = false;

  String? user;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    _usernameController.addListener(() {
      if (_usernameController.text.length > 7) {
        _passwordController.text = "";
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Verticale
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300, // ! Limita la larghezza del TextFormField
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: "Inserisci l'username",
                    icon: Icon(
                      Icons.person,
                    ), //icon in the left of the text field
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un username'; //se non inserisci nulla e schiacci invia ti appare questo
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300, // ! Limita la larghezza del TextFormField
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: "mario.rossi@gmail.com",
                    icon: Icon(
                      Icons.email,
                    ), //icon in the left of the text field
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Inserisci una email valida';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300, // ! Limita la larghezza del TextFormField
                child: TextFormField(
                  controller: _passwordController,
                  obscureText:
                      isPasswordInvisible, //se true il testo è nascosto
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: "Inserisci la password",
                    icon: const Icon(
                      Icons.lock,
                    ), //icon in the left of the text field
                    suffixIcon: InkWell(
                      child: Icon(
                        isPasswordInvisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onTap: () {
                        setState(() {
                          isPasswordInvisible = !isPasswordInvisible;
                        });
                      },
                    ), //icon in the right of the text field
                  ), //label: placeholder
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'Inserisci una password di almeno 8 caratteri)'; //se non inserisci nulla e schiacci invia ti appare questo
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: isPasswordInvisible, //se true il testo è nascosto
                  decoration: InputDecoration(
                    labelText: 'Conferma',
                    hintText: "Conferma la password",
                    icon: const Icon(
                      Icons.lock,
                    ), //icon in the left of the text field
                    suffixIcon: InkWell(
                      child: Icon(
                        isPasswordInvisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onTap: () {
                        setState(() {
                          isPasswordInvisible = !isPasswordInvisible;
                        });
                      },
                    ), //icon in the right of the text field
                  ), //label: placeholder
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Conferma la tua password';
                    }
                    if (value != _passwordController.text) {
                      return 'Le Password non combaciano';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          //width: 200,
          child: ElevatedButton(
            onPressed: () {
              print("Registrati premuto");
            },
            style: ElevatedButton.styleFrom(
              //backgroundColor: const Color.fromARGB(255, 172, 215, 250),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            child: const Text("Registrati"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              print("Accedi premuto");
            },
            child: RichText(
              text: TextSpan(
                text: "Or register with ",
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: "Google",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
