import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mikansei Flutter'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @latestPosts.
  ///
  /// In en, this message translates to:
  /// **'Latest Posts'**
  String get latestPosts;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts or tags'**
  String get searchHint;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @tagLanguage.
  ///
  /// In en, this message translates to:
  /// **'Tag language'**
  String get tagLanguage;

  /// No description provided for @followAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Follow app'**
  String get followAppLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @inspiredBy.
  ///
  /// In en, this message translates to:
  /// **'Inspired by uragiristereo/Mikansei'**
  String get inspiredBy;

  /// No description provided for @ratingSafe.
  ///
  /// In en, this message translates to:
  /// **'safe'**
  String get ratingSafe;

  /// No description provided for @ratingQuestionable.
  ///
  /// In en, this message translates to:
  /// **'questionable'**
  String get ratingQuestionable;

  /// No description provided for @loadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Loading posts from Danbooru...'**
  String get loadingPosts;

  /// No description provided for @postLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts from Danbooru API.'**
  String get postLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// No description provided for @activeTagFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter: {tags}'**
  String activeTagFilter(String tags);

  /// No description provided for @noMorePosts.
  ///
  /// In en, this message translates to:
  /// **'No more posts'**
  String get noMorePosts;

  /// No description provided for @loadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more posts'**
  String get loadMoreFailed;

  /// No description provided for @settingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get settingsLoading;

  /// No description provided for @danbooruCredentials.
  ///
  /// In en, this message translates to:
  /// **'Danbooru Credentials'**
  String get danbooruCredentials;

  /// No description provided for @danbooruApiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Danbooru API base URL'**
  String get danbooruApiBaseUrl;

  /// No description provided for @danbooruLogin.
  ///
  /// In en, this message translates to:
  /// **'Danbooru login'**
  String get danbooruLogin;

  /// No description provided for @danbooruApiKey.
  ///
  /// In en, this message translates to:
  /// **'Danbooru API key'**
  String get danbooruApiKey;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter tags and search'**
  String get searchPrompt;

  /// No description provided for @loadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Loading favorites...'**
  String get loadingFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @apiEndpointHint.
  ///
  /// In en, this message translates to:
  /// **'You can change API endpoint or credentials in Settings.'**
  String get apiEndpointHint;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @safeMode.
  ///
  /// In en, this message translates to:
  /// **'Safe mode'**
  String get safeMode;

  /// No description provided for @safeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Append rating:safe if no rating filter is set.'**
  String get safeModeDescription;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savedSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get savedSettings;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get saveFailed;

  /// No description provided for @authConfigured.
  ///
  /// In en, this message translates to:
  /// **'Authenticated requests are enabled.'**
  String get authConfigured;

  /// No description provided for @authNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'No login/api_key configured.'**
  String get authNotConfigured;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon'**
  String comingSoon(String feature);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
