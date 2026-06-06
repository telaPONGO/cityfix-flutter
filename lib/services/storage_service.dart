import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _keyCurrentUserEmail = 'current_user_email';
  static const _keyCurrentUserData = 'current_user_data';
  static const _keyCurrentUserToken = 'current_user_token';
  static const _keySelectedCity = 'selected_city';
  static const _keyThemeDark = 'theme_dark';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setCurrentUserEmail(String email) async {
    await _prefs.setString(_keyCurrentUserEmail, email);
  }

  static String? getCurrentUserEmail() {
    return _prefs.getString(_keyCurrentUserEmail);
  }

  static Future<void> setCurrentUserData(String json) async {
    await _prefs.setString(_keyCurrentUserData, json);
  }

  static String? getCurrentUserData() {
    return _prefs.getString(_keyCurrentUserData);
  }

  static Future<void> setCurrentUserToken(String token) async {
    await _prefs.setString(_keyCurrentUserToken, token);
  }

  static String? getCurrentUserToken() {
    return _prefs.getString(_keyCurrentUserToken);
  }

  static Future<void> clearUser() async {
    await _prefs.remove(_keyCurrentUserEmail);
    await _prefs.remove(_keyCurrentUserData);
    await _prefs.remove(_keyCurrentUserToken);
  }

  static Future<void> setCity(String city) async {
    await _prefs.setString(_keySelectedCity, city);
  }

  static String? getCity() {
    return _prefs.getString(_keySelectedCity);
  }

  static Future<void> setThemeMode(bool darkMode) async {
    await _prefs.setBool(_keyThemeDark, darkMode);
  }

  static bool getThemeMode() {
    return _prefs.getBool(_keyThemeDark) ?? false;
  }
}
