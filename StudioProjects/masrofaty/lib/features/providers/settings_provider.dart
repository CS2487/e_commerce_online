import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  // ==================== الإعدادات ====================
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get dailyReminderTime => _dailyReminderTime;

  bool _dailyReminder = false;
  bool get dailyReminder => _dailyReminder;

  String _currency = "ريال يمني";
  String get currency => _currency;

  final Map<String, double> _budgets = {
    "ريال يمني": 100000,
    "ريال سعودي": 1500,
    "دولار": 200,
  };
  Map<String, double> get budgets => _budgets;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ==================== التحميل ====================
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final savedTheme = prefs.getInt("theme_mode");
    if (savedTheme != null) _themeMode = ThemeMode.values[savedTheme];

    // Reminder
    _dailyReminder = prefs.getBool("daily_reminder") ?? false;
    final h = prefs.getInt("daily_reminder_hour") ?? 20;
    final m = prefs.getInt("daily_reminder_minute") ?? 0;
    _dailyReminderTime = TimeOfDay(hour: h, minute: m);

    // Currency
    _currency = prefs.getString("currency") ?? "ريال يمني";

    // Budgets
    for (var key in _budgets.keys) {
      final saved = prefs.getDouble("budget_$key");
      if (saved != null) _budgets[key] = saved;
    }

    // Schedule reminder if enabled
    if (_dailyReminder) {
      await NotificationService().scheduleDaily(_dailyReminderTime);
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ==================== الثيم ====================
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("theme_mode", mode.index);
    notifyListeners();
  }

  // ==================== التذكير اليومي ====================
  Future<void> setDailyReminder(bool enabled) async {
    _dailyReminder = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("daily_reminder", enabled);

    if (enabled) {
      await NotificationService().scheduleDaily(_dailyReminderTime);
    } else {
      await NotificationService().cancelDaily();
    }

    notifyListeners();
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("daily_reminder_hour", time.hour);
    await prefs.setInt("daily_reminder_minute", time.minute);

    if (_dailyReminder) {
      await NotificationService().scheduleDaily(_dailyReminderTime);
    }

    notifyListeners();
  }

  String reminderTimeText(BuildContext context) {
    return _dailyReminder ? _dailyReminderTime.format(context) : "غير مفعل";
  }

  // ==================== الميزانية ====================
  Future<void> setBudget(String currency, double value) async {
    if (_budgets.containsKey(currency)) {
      _budgets[currency] = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("budget_$currency", value);
      notifyListeners();
    }
  }
}
