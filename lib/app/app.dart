import 'dart:io' show Platform;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/router.dart';
import 'package:ketchapp_flutter/app/themes/app_theme.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingBloc>(
          create: (context) => RankingBloc(apiService: ApiService()),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          final ThemeData lightAppTheme;
          final ThemeData darkAppTheme;
          if (kIsWeb) {
            lightAppTheme = lightTheme;
            darkAppTheme = darkTheme;
          } else if (Platform.isAndroid) {
            lightAppTheme = ThemeData(
              colorScheme: lightDynamic,
              brightness: Brightness.light,
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                },
              ),
            );
            darkAppTheme = ThemeData(
              colorScheme: darkDynamic,
              brightness: Brightness.dark,
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                },
              ),
            );
          } else {
            lightAppTheme = lightTheme;
            darkAppTheme = darkTheme;
          }
          return MaterialApp.router(
            title: 'Ketchapp',
            theme: lightAppTheme,
            darkTheme: darkAppTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
