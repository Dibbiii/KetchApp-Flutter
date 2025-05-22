import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/features/plan/presentation/pages/automatic/summary_state.dart';
import 'package:ketchapp_flutter/app/app.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/features/profile/bloc/profile_bloc.dart'; // Added import
import 'package:firebase_storage/firebase_storage.dart'; // Added import
import 'package:image_picker/image_picker.dart'; // Added import

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
        Provider<ApiService>(
          // Ensure ApiService is provided before AuthBloc
          create: (_) => ApiService(),
        ),
        Provider<AuthBloc>(
          create:
              (context) => AuthBloc(
                firebaseAuth: FirebaseAuth.instance,
                apiService: Provider.of<ApiService>(
                  context,
                  listen: false,
                ), // Pass ApiService
              ),
        ),
        Provider<ProfileBloc>(
          // Added ProfileBloc provider
          create:
              (_) => ProfileBloc(
                firebaseAuth: FirebaseAuth.instance,
                firebaseStorage: FirebaseStorage.instance,
                imagePicker: ImagePicker(),
              ),
        ),
        ChangeNotifierProvider(create: (_) => SummaryState()),
      ],
      child: const MyApp(),
    ),
  );
}
