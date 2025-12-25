import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masareefk/shared/app_theme.dart';
import 'package:provider/provider.dart';
import 'core/utils/splash_screen.dart';
import 'features/providers/settings_provider.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, ThemeMode>(
      selector: (_, settings) => settings.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}

