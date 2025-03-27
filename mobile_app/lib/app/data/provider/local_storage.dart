import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const KEY_LANGUAGE_APP = 'KEY_LANGUAGE_APP';

  Future setLanguageApp(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_LANGUAGE_APP, value);
  }

  Future<String> getLanguageApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? result = prefs.getString(KEY_LANGUAGE_APP);
    return result ?? '';
  }
}
