import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserData({
    required String token,
    required int userId,
    required String email,
    required String name,
  }) async {
    await _prefs.setString(AppConstants.tokenKey, token);
    await _prefs.setInt(AppConstants.userIdKey, userId);
    await _prefs.setString(AppConstants.userEmailKey, email);
    await _prefs.setString(AppConstants.userNameKey, name);
    await _prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  static Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userIdKey);
    await _prefs.remove(AppConstants.userEmailKey);
    await _prefs.remove(AppConstants.userNameKey);
    await _prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  static String? get token => _prefs.getString(AppConstants.tokenKey);
  static int? get userId => _prefs.getInt(AppConstants.userIdKey);
  static String? get userEmail => _prefs.getString(AppConstants.userEmailKey);
  static String? get userName => _prefs.getString(AppConstants.userNameKey);
  static bool get isLoggedIn => _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
}