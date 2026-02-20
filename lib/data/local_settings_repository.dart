import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/danbooru_auth.dart';

class LocalSettingsRepository {
  static const String _loginKey = 'danbooru_login';
  static const String _apiKeyKey = 'danbooru_api_key';
  static const String _safeModeKey = 'safe_mode_enabled';
  static const String _apiBaseUrlKey = 'danbooru_api_base_url';
  static const String _recentSearchesKey = 'recent_searches';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      auth: DanbooruAuth(
        login: prefs.getString(_loginKey) ?? '',
        apiKey: prefs.getString(_apiKeyKey) ?? '',
      ),
      safeModeEnabled: prefs.getBool(_safeModeKey) ?? true,
      apiBaseUrl:
          prefs.getString(_apiBaseUrlKey) ?? AppSettings.defaults().apiBaseUrl,
      recentSearches:
          prefs
              .getStringList(_recentSearchesKey)
              ?.where(_isValidTag)
              .toList() ??
          const [],
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginKey, settings.auth.login.trim());
    await prefs.setString(_apiKeyKey, settings.auth.apiKey.trim());
    await prefs.setBool(_safeModeKey, settings.safeModeEnabled);
    await prefs.setString(_apiBaseUrlKey, settings.apiBaseUrl.trim());
    await prefs.setStringList(
      _recentSearchesKey,
      settings.recentSearches
          .where(_isValidTag)
          .take(12)
          .toList(growable: false),
    );
  }

  static bool _isValidTag(String value) {
    return value.trim().isNotEmpty;
  }
}
