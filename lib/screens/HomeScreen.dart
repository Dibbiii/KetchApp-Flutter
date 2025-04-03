import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/components/footer.dart';
import 'package:http/http.dart' as http;
import 'package:ketchapp_flutter/models/cat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late Future<List<cat>> futurecat;

  @override
  void initState() {
    super.initState();
    futurecat = fetchcat(); // Fetch the list of cat facts when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(
          255,
          228,
          242,
          248,
        ), // Light blue background for the entire page
        child: Column(
          children: [
            Expanded(
              flex: 2, // Occupies 2/3 of the page
              child: Container(
                alignment: Alignment.center,
                child: FutureBuilder<List<cat>>(
                  future: futurecat,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          ...snapshot.data!.map((cat) => Column(
                                children: [
                                  Text("id: " + cat.id.toString()),
                                  Text("name: " + cat.name),
                                ],
                              )),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1, // Occupies 1/3 of the page
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 0, 109, 198),
                        width: 2,
                      ), // Blue border
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 109, 198),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space between buttons
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 83, 81, 81),
                        width: 2,
                      ), // Black border
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 83, 81, 81),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}

Future<List<cat>> fetchcat() async {
  final response = await http.get(Uri.parse('http://localhost:8080/welcome'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList.map((json) => cat.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load cat');
  }
}
