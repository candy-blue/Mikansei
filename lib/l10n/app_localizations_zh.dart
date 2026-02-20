// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Mikansei Flutter';

  @override
  String get home => '首页';

  @override
  String get search => '搜索';

  @override
  String get favorites => '收藏';

  @override
  String get settings => '设置';

  @override
  String get latestPosts => '最新帖子';

  @override
  String get searchHint => '搜索帖子或标签';

  @override
  String get appLanguage => '界面语言';

  @override
  String get tagLanguage => 'Tag 语言';

  @override
  String get followAppLanguage => '跟随界面';

  @override
  String get english => '英文';

  @override
  String get chinese => '中文';

  @override
  String get inspiredBy => '参考 uragiristereo/Mikansei';

  @override
  String get ratingSafe => '安全';

  @override
  String get ratingQuestionable => '存疑';

  @override
  String get loadingPosts => '正在从 Danbooru 加载帖子...';

  @override
  String get postLoadError => '从 Danbooru API 加载帖子失败。';

  @override
  String get retry => '重试';

  @override
  String get searchAction => '搜索';

  @override
  String get noPostsFound => '没有找到帖子';

  @override
  String activeTagFilter(String tags) {
    return '筛选：$tags';
  }

  @override
  String get noMorePosts => '没有更多帖子了';

  @override
  String get loadMoreFailed => '加载更多帖子失败';

  @override
  String get settingsLoading => '正在加载设置...';

  @override
  String get danbooruCredentials => 'Danbooru 账号配置';

  @override
  String get danbooruApiBaseUrl => 'Danbooru API 地址';

  @override
  String get danbooruLogin => 'Danbooru 登录名';

  @override
  String get danbooruApiKey => 'Danbooru API Key';

  @override
  String get recentSearches => '最近搜索';

  @override
  String get clear => '清除';

  @override
  String get searchPrompt => '输入标签后开始搜索';

  @override
  String get loadingFavorites => '正在加载收藏...';

  @override
  String get noFavoritesYet => '还没有收藏内容';

  @override
  String get apiEndpointHint => '你可以在设置中修改 API 地址或凭据。';

  @override
  String get addFavorite => '添加收藏';

  @override
  String get removeFavorite => '取消收藏';

  @override
  String get safeMode => '安全模式';

  @override
  String get safeModeDescription => '当你未填写 rating 过滤时，自动附加 rating:safe。';

  @override
  String get save => '保存';

  @override
  String get savedSettings => '设置已保存';

  @override
  String get saveFailed => '设置保存失败';

  @override
  String get authConfigured => '已启用认证请求。';

  @override
  String get authNotConfigured => '未配置 login/api_key。';

  @override
  String comingSoon(String feature) {
    return '$feature 功能即将上线';
  }
}
