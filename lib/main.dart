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
import 'package:ketchapp_flutter/features/profile/bloc/profile_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/features/profile/bloc/achievement_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize date formatting for the Italian locale
  await initializeDateFormatting('it_IT', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            firebaseAuth: FirebaseAuth.instance,
            firebaseStorage: FirebaseStorage.instance,
            imagePicker: ImagePicker(),
            apiService: context.read<ApiService>(),
            authBloc: BlocProvider.of<AuthBloc>(context),
          ),
        ),
        BlocProvider<AchievementBloc>(
          create: (context) => AchievementBloc(
            apiService: context.read<ApiService>(),
            authBloc: BlocProvider.of<AuthBloc>(context),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SummaryState()),
      ],
      child: const MyApp(),
    ),
  );
}