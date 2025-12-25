import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static PrefsService? _instance;
  static SharedPreferences? _prefs;

  PrefsService._internal();

  static Future<PrefsService> getInstance() async {
    if (_instance == null) {
      _instance = PrefsService._internal();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  bool getSeenOnboarding() => _prefs?.getBool('seen_onboarding') ?? false;

  Future<void> setSeenOnboarding(bool value) async {
    await _prefs?.setBool('seen_onboarding', value);
  }
}
