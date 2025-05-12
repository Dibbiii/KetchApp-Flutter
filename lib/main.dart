import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/summary_state.dart';
import 'package:ketchapp_flutter/app/app.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Use clean URLs without hash (#) in the web
  usePathUrlStrategy();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run app with providers
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthBloc>(
          create: (_) => AuthBloc(firebaseAuth: FirebaseAuth.instance),
        ),
        ChangeNotifierProvider(create: (_) => SummaryState()),
      ],
      child: const MyApp(),
    ),
  );
}
