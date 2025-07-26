import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ketchapp_flutter/features/auth/bloc/api_auth_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/api_profile_bloc.dart';
import 'package:ketchapp_flutter/services/api_auth_service.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/app/app.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await initializeDateFormatting('it_IT', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  final apiService = ApiService();
  await apiService.loadToken(); // Assicurati che il token venga caricato all'avvio

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => apiService,
        ),
        Provider<ApiAuthService>(
          create: (context) => ApiAuthService(context.read<ApiService>()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            apiService: context.read<ApiService>(),
          ),
        ),
        BlocProvider<ApiAuthBloc>(
          create: (context) => ApiAuthBloc(
            apiAuthService: context.read<ApiAuthService>(),
            apiService: context.read<ApiService>(),
          )..add(ApiAuthCheckRequested()), // Controlla lo stato dell'auth all'avvio
        ),
        BlocProvider<ApiProfileBloc>(
          create: (context) => ApiProfileBloc(
            apiService: context.read<ApiService>(),
            apiAuthBloc: context.read<ApiAuthBloc>(),
            imagePicker: ImagePicker(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
