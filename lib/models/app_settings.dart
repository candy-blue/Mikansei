import 'danbooru_auth.dart';

class AppSettings {
  const AppSettings({
    required this.auth,
    required this.safeModeEnabled,
    required this.apiBaseUrl,
    required this.recentSearches,
  });

  const AppSettings.defaults()
    : auth = const DanbooruAuth.empty(),
      safeModeEnabled = true,
      apiBaseUrl = 'https://danbooru.donmai.us',
      recentSearches = const [];

  final DanbooruAuth auth;
  final bool safeModeEnabled;
  final String apiBaseUrl;
  final List<String> recentSearches;

  AppSettings copyWith({
    DanbooruAuth? auth,
    bool? safeModeEnabled,
    String? apiBaseUrl,
    List<String>? recentSearches,
  }) {
    return AppSettings(
      auth: auth ?? this.auth,
      safeModeEnabled: safeModeEnabled ?? this.safeModeEnabled,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}
