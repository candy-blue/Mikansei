import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/danbooru_post_repository.dart';
import 'data/favorites_repository.dart';
import 'data/local_settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'localization/tag_localizer.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MikanseiApp());
}

class MikanseiApp extends StatefulWidget {
  const MikanseiApp({super.key});

  @override
  State<MikanseiApp> createState() => _MikanseiAppState();
}

class _MikanseiAppState extends State<MikanseiApp> {
  final DanbooruPostRepository _repository = DanbooruPostRepository();
  final LocalSettingsRepository _settingsRepository = LocalSettingsRepository();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();
  Locale _locale = const Locale('en');
  TagLanguageMode _tagLanguageMode = TagLanguageMode.followApp;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0E9AA7),
      ),
      home: MainScreen(
        repository: _repository,
        settingsRepository: _settingsRepository,
        favoritesRepository: _favoritesRepository,
        locale: _locale,
        tagLanguageMode: _tagLanguageMode,
        onLocaleChanged: (locale) {
          setState(() {
            _locale = locale;
          });
        },
        onTagLanguageChanged: (mode) {
          setState(() {
            _tagLanguageMode = mode;
          });
        },
      ),
    );
  }
}
