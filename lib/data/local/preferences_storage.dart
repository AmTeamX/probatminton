import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  static const _localeKey = 'locale';

  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'en';
  }
}
