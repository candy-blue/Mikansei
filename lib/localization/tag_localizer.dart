import 'dart:ui';

enum TagLanguageMode { followApp, english, chinese }

extension TagLanguageModeX on TagLanguageMode {
  String resolveLanguageCode(Locale appLocale) {
    return switch (this) {
      TagLanguageMode.followApp => appLocale.languageCode,
      TagLanguageMode.english => 'en',
      TagLanguageMode.chinese => 'zh',
    };
  }
}

class TagTranslation {
  const TagTranslation({
    required this.en,
    this.zh,
    this.extraTranslations = const {
      'ja': null,
      'ko': null,
      'es': null,
      'fr': null,
    },
  });

  final String en;
  final String? zh;

  // Reserved slots for future non-English tag translation expansion.
  final Map<String, String?> extraTranslations;

  String? valueFor(String languageCode) {
    if (languageCode == 'en') {
      return en;
    }
    if (languageCode == 'zh') {
      return zh;
    }
    return extraTranslations[languageCode];
  }
}

class TagLocalizer {
  static const Map<String, TagTranslation> _catalog = {
    '1girl': TagTranslation(en: '1girl', zh: '单个女孩'),
    'solo': TagTranslation(en: 'solo', zh: '单人'),
    'smile': TagTranslation(en: 'smile', zh: '微笑'),
    'night_sky': TagTranslation(en: 'night sky', zh: '夜空'),
    'city_lights': TagTranslation(en: 'city lights', zh: '城市灯光'),
    'school_uniform': TagTranslation(en: 'school uniform', zh: '校服'),
    'looking_at_viewer': TagTranslation(en: 'looking at viewer', zh: '看向观众'),
    'long_hair': TagTranslation(en: 'long hair', zh: '长发'),
    'landscape': TagTranslation(en: 'landscape', zh: '风景'),
    'sunset': TagTranslation(en: 'sunset', zh: '日落'),
  };

  static String translate({
    required String rawTag,
    required TagLanguageMode languageMode,
    required Locale appLocale,
  }) {
    final key = rawTag.toLowerCase();
    final translation = _catalog[key];

    if (translation == null) {
      return _toReadable(rawTag);
    }

    final targetCode = languageMode.resolveLanguageCode(appLocale);
    final localized = translation.valueFor(targetCode) ?? translation.en;
    return _toReadable(localized);
  }

  static String _toReadable(String value) {
    return value.replaceAll('_', ' ');
  }
}
