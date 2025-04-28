import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:ketchapp_flutter/app/themes/theme_provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'firebase_options.dart';
import 'package:ketchapp_flutter/app/app.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthBloc>(create: (_) => AuthBloc(firebaseAuth: FirebaseAuth.instance)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // altri provider...
      ],
      child: const MyApp(),
    ),
  );
}