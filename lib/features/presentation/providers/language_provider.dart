import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale;
  final SharedPreferences prefs;
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // الإنجليزية
    Locale('ar', 'AE'), // العربية
    Locale('fr', 'FR'), // الفرنسية
    Locale('es', 'ES'), // الإسبانية
    Locale('de', 'DE'), // الألمانية
  ];

  LanguageProvider(this.prefs)
      : _locale = Locale(prefs.getString('language_code') ?? 'en') {
    _loadLocale();
  }

  Locale get locale => _locale;
  Future<void> _loadLocale() async {
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = _getLocaleByLanguageCode(languageCode);
    notifyListeners();
  }

  Locale _getLocaleByLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'), // افتراضي الإنجليزية
    );
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('ar', 'AE'));
    } else {
      setLocale(const Locale('en', 'US'));
    }
  }

  void setLocale(Locale locale) {
    if (!_isLocaleSupported(locale)) return; // التحقق إذا كانت اللغة مدعومة
    if (_locale == locale) return; // تجنب التحديث إذا كانت نفس اللغة
    _locale = locale;
    prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
  bool _isLocaleSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }
}
