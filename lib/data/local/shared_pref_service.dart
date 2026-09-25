import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SharedPrefService {
  final SharedPreferences _prefs;

  SharedPrefService(this._prefs);

  static Future<SharedPrefService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefService(prefs);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs.setBool(AppConstants.themeKey, isDarkMode);
  }

  bool isDarkMode() {
    return _prefs.getBool(AppConstants.themeKey) ?? false;
  }

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.roleKey, role);
  }

  String? getUserRole() {
    return _prefs.getString(AppConstants.roleKey);
  }

  Future<void> clearRole() async {
    await _prefs.remove(AppConstants.roleKey);
  }
}
