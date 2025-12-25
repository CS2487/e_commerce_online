import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masareefk/app.dart';
import 'package:masareefk/shared/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'core/Database/database_helper.dart';
import 'features/providers/category_provider.dart';
import 'features/providers/expense_provider.dart';
import 'features/providers/settings_provider.dart';
import 'features/providers/statistics_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize timezone
  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation("UTC"));
  }

  // Initialize notifications
  await NotificationService().init();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child:  const MyApp(),
    ),
  );
}
