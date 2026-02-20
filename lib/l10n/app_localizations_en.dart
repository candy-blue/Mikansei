// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mikansei Flutter';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get latestPosts => 'Latest Posts';

  @override
  String get searchHint => 'Search posts or tags';

  @override
  String get appLanguage => 'App language';

  @override
  String get tagLanguage => 'Tag language';

  @override
  String get followAppLanguage => 'Follow app';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get inspiredBy => 'Inspired by uragiristereo/Mikansei';

  @override
  String get ratingSafe => 'safe';

  @override
  String get ratingQuestionable => 'questionable';

  @override
  String get loadingPosts => 'Loading posts from Danbooru...';

  @override
  String get postLoadError => 'Failed to load posts from Danbooru API.';

  @override
  String get retry => 'Retry';

  @override
  String get searchAction => 'Search';

  @override
  String get noPostsFound => 'No posts found';

  @override
  String activeTagFilter(String tags) {
    return 'Filter: $tags';
  }

  @override
  String get noMorePosts => 'No more posts';

  @override
  String get loadMoreFailed => 'Failed to load more posts';

  @override
  String get settingsLoading => 'Loading settings...';

  @override
  String get danbooruCredentials => 'Danbooru Credentials';

  @override
  String get danbooruApiBaseUrl => 'Danbooru API base URL';

  @override
  String get danbooruLogin => 'Danbooru login';

  @override
  String get danbooruApiKey => 'Danbooru API key';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clear => 'Clear';

  @override
  String get searchPrompt => 'Enter tags and search';

  @override
  String get loadingFavorites => 'Loading favorites...';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get apiEndpointHint => 'You can change API endpoint or credentials in Settings.';

  @override
  String get addFavorite => 'Add favorite';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get safeMode => 'Safe mode';

  @override
  String get safeModeDescription => 'Append rating:safe if no rating filter is set.';

  @override
  String get save => 'Save';

  @override
  String get savedSettings => 'Settings saved';

  @override
  String get saveFailed => 'Failed to save settings';

  @override
  String get authConfigured => 'Authenticated requests are enabled.';

  @override
  String get authNotConfigured => 'No login/api_key configured.';

  @override
  String comingSoon(String feature) {
    return '$feature is coming soon';
  }
}
