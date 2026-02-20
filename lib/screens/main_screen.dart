import 'dart:async';

import 'package:flutter/material.dart';

import '../data/danbooru_post_repository.dart';
import '../data/favorites_repository.dart';
import '../data/local_settings_repository.dart';
import '../l10n/app_localizations.dart';
import '../localization/tag_localizer.dart';
import '../models/app_settings.dart';
import '../models/danbooru_auth.dart';
import '../models/post_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.repository,
    required this.settingsRepository,
    required this.favoritesRepository,
    required this.locale,
    required this.tagLanguageMode,
    required this.onLocaleChanged,
    required this.onTagLanguageChanged,
  });

  final DanbooruPostRepository repository;
  final LocalSettingsRepository settingsRepository;
  final FavoritesRepository favoritesRepository;
  final Locale locale;
  final TagLanguageMode tagLanguageMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<TagLanguageMode> onTagLanguageChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _settingsLoaded = false;
  bool _favoritesLoaded = false;
  AppSettings _settings = const AppSettings.defaults();
  Map<int, PostItem> _favoritesById = const {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadFavorites();
  }

  Future<void> _loadSettings() async {
    try {
      final loaded = await widget.settingsRepository.loadSettings();
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = loaded;
        _settingsLoaded = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _settingsLoaded = true;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final loaded = await widget.favoritesRepository.loadFavorites();
      if (!mounted) {
        return;
      }
      setState(() {
        _favoritesById = {for (final post in loaded) post.id: post};
        _favoritesLoaded = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _favoritesLoaded = true;
      });
    }
  }

  Future<bool> _saveSettings(AppSettings nextSettings) async {
    final previous = _settings;
    setState(() {
      _settings = nextSettings;
    });

    try {
      await widget.settingsRepository.saveSettings(nextSettings);
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      setState(() {
        _settings = previous;
      });
      return false;
    }
  }

  void _rememberSearch(String rawQuery) {
    final normalized = rawQuery.trim();
    if (normalized.isEmpty) {
      return;
    }

    final nextHistory = [
      normalized,
      ..._settings.recentSearches.where((value) => value != normalized),
    ].take(12).toList(growable: false);

    unawaited(_saveSettings(_settings.copyWith(recentSearches: nextHistory)));
  }

  void _clearRecentSearches() {
    unawaited(_saveSettings(_settings.copyWith(recentSearches: const [])));
  }

  bool _isFavorited(int postId) {
    return _favoritesById.containsKey(postId);
  }

  void _toggleFavorite(PostItem post) {
    final hadPost = _favoritesById.containsKey(post.id);
    final previous = _favoritesById;
    final next = Map<int, PostItem>.from(_favoritesById);

    if (hadPost) {
      next.remove(post.id);
    } else {
      next[post.id] = post;
    }

    setState(() {
      _favoritesById = next;
    });

    unawaited(_persistFavorites(previous));
  }

  Future<void> _persistFavorites(Map<int, PostItem> rollback) async {
    try {
      final snapshot = _favoritesById.values.toList(growable: false);
      await widget.favoritesRepository.saveFavorites(snapshot);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _favoritesById = rollback;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritePosts = _favoritesById.values.toList(growable: false)
      ..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l10n.appLanguage,
            onSelected: widget.onLocaleChanged,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: const Locale('en'),
                  child: Text('${l10n.english} (EN)'),
                ),
                PopupMenuItem(
                  value: const Locale('zh'),
                  child: Text('${l10n.chinese} (ZH)'),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 6),
                  Text(
                    widget.locale.languageCode.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<TagLanguageMode>(
            tooltip: l10n.tagLanguage,
            initialValue: widget.tagLanguageMode,
            onSelected: widget.onTagLanguageChanged,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: TagLanguageMode.followApp,
                  child: Text(l10n.followAppLanguage),
                ),
                PopupMenuItem(
                  value: TagLanguageMode.english,
                  child: Text(l10n.english),
                ),
                PopupMenuItem(
                  value: TagLanguageMode.chinese,
                  child: Text(l10n.chinese),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag),
                  const SizedBox(width: 6),
                  Text(
                    _tagModeLabel(context, widget.tagLanguageMode),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            repository: widget.repository,
            locale: widget.locale,
            tagLanguageMode: widget.tagLanguageMode,
            settings: _settings,
            onToggleFavorite: _toggleFavorite,
            isFavorited: _isFavorited,
          ),
          _SearchTab(
            repository: widget.repository,
            locale: widget.locale,
            tagLanguageMode: widget.tagLanguageMode,
            settings: _settings,
            onToggleFavorite: _toggleFavorite,
            isFavorited: _isFavorited,
            onSearchCommitted: _rememberSearch,
            onClearRecentSearches: _clearRecentSearches,
          ),
          _FavoritesTab(
            isLoading: !_favoritesLoaded,
            posts: favoritePosts,
            locale: widget.locale,
            tagLanguageMode: widget.tagLanguageMode,
            onToggleFavorite: _toggleFavorite,
          ),
          _SettingsTab(
            isLoading: !_settingsLoaded,
            settings: _settings,
            onSave: _saveSettings,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.favorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  String _tagModeLabel(BuildContext context, TagLanguageMode mode) {
    final l10n = AppLocalizations.of(context)!;
    return switch (mode) {
      TagLanguageMode.followApp => l10n.followAppLanguage,
      TagLanguageMode.english => 'EN',
      TagLanguageMode.chinese => 'ZH',
    };
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({
    required this.isLoading,
    required this.settings,
    required this.onSave,
  });

  final bool isLoading;
  final AppSettings settings;
  final Future<bool> Function(AppSettings settings) onSave;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late final TextEditingController _loginController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _apiBaseUrlController;
  late bool _safeModeEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.settings.auth.login);
    _apiKeyController = TextEditingController(
      text: widget.settings.auth.apiKey,
    );
    _apiBaseUrlController = TextEditingController(
      text: widget.settings.apiBaseUrl,
    );
    _safeModeEnabled = widget.settings.safeModeEnabled;
  }

  @override
  void didUpdateWidget(covariant _SettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSaving) {
      return;
    }
    if (oldWidget.settings.auth.login != widget.settings.auth.login) {
      _loginController.text = widget.settings.auth.login;
    }
    if (oldWidget.settings.auth.apiKey != widget.settings.auth.apiKey) {
      _apiKeyController.text = widget.settings.auth.apiKey;
    }
    if (oldWidget.settings.apiBaseUrl != widget.settings.apiBaseUrl) {
      _apiBaseUrlController.text = widget.settings.apiBaseUrl;
    }
    if (oldWidget.settings.safeModeEnabled != widget.settings.safeModeEnabled) {
      _safeModeEnabled = widget.settings.safeModeEnabled;
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _apiKeyController.dispose();
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final nextSettings = AppSettings(
      auth: DanbooruAuth(
        login: _loginController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
      ),
      safeModeEnabled: _safeModeEnabled,
      apiBaseUrl: _apiBaseUrlController.text.trim(),
      recentSearches: widget.settings.recentSearches,
    );
    final success = await widget.onSave(nextSettings);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.savedSettings : l10n.saveFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(l10n.settingsLoading),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.danbooruCredentials,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apiBaseUrlController,
          decoration: InputDecoration(
            labelText: l10n.danbooruApiBaseUrl,
            hintText: 'https://danbooru.donmai.us',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginController,
          decoration: InputDecoration(
            labelText: l10n.danbooruLogin,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apiKeyController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.danbooruApiKey,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.settings.auth.isConfigured
              ? l10n.authConfigured
              : l10n.authNotConfigured,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _safeModeEnabled,
          title: Text(l10n.safeMode),
          subtitle: Text(l10n.safeModeDescription),
          onChanged: (value) {
            setState(() {
              _safeModeEnabled = value;
            });
          },
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(l10n.save),
        ),
      ],
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({
    required this.repository,
    required this.locale,
    required this.tagLanguageMode,
    required this.settings,
    required this.onToggleFavorite,
    required this.isFavorited,
  });

  final DanbooruPostRepository repository;
  final Locale locale;
  final TagLanguageMode tagLanguageMode;
  final AppSettings settings;
  final ValueChanged<PostItem> onToggleFavorite;
  final bool Function(int postId) isFavorited;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const int _pageSize = 30;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PostItem> _posts = const [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _nextPage = 1;
  String _activeTags = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshPosts();
  }

  @override
  void didUpdateWidget(covariant _HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.auth != widget.settings.auth ||
        oldWidget.settings.safeModeEnabled != widget.settings.safeModeEnabled ||
        oldWidget.settings.apiBaseUrl != widget.settings.apiBaseUrl) {
      _refreshPosts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _refreshPosts({String? tags}) async {
    await _loadPosts(reset: true, tags: tags ?? _activeTags);
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) {
      return;
    }
    await _loadPosts(reset: false);
  }

  Future<void> _loadPosts({required bool reset, String? tags}) async {
    final queryTags = (tags ?? _activeTags).trim();

    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
        _nextPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final page = reset ? 1 : _nextPage;
    try {
      final loadedPosts = await widget.repository.fetchPosts(
        baseUrl: widget.settings.apiBaseUrl,
        tags: queryTags,
        page: page,
        limit: _pageSize,
        auth: widget.settings.auth,
        safeModeEnabled: widget.settings.safeModeEnabled,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = reset ? loadedPosts : _mergePosts(_posts, loadedPosts);
        _activeTags = queryTags;
        _nextPage = page + 1;
        _hasMore = loadedPosts.length >= _pageSize;
        _errorMessage = null;
      });
    } on DanbooruApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (reset) {
        setState(() {
          _errorMessage = error.message;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loadMoreFailed)));
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (reset) {
        setState(() {
          _errorMessage = 'network_or_access';
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loadMoreFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (reset) {
            _isInitialLoading = false;
          } else {
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  List<PostItem> _mergePosts(List<PostItem> current, List<PostItem> incoming) {
    final seenIds = current.map((post) => post.id).toSet();
    final merged = current.toList(growable: true);
    for (final post in incoming) {
      if (seenIds.add(post.id)) {
        merged.add(post);
      }
    }
    return merged;
  }

  void _onSearch() {
    _refreshPosts(tags: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _isInitialLoading ? null : _onSearch,
                tooltip: l10n.searchAction,
                icon: const Icon(Icons.arrow_forward),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isInitialLoading ? null : _refreshPosts,
                tooltip: l10n.retry,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_activeTags.isNotEmpty)
                Chip(label: Text(l10n.activeTagFilter(_activeTags))),
              if (widget.settings.safeModeEnabled)
                Chip(label: Text(l10n.safeMode)),
            ],
          ),
        ),
        Expanded(
          child: _PostGrid(
            isLoading: _isInitialLoading,
            isLoadingMore: _isLoadingMore,
            hasMore: _hasMore,
            posts: _posts,
            locale: widget.locale,
            errorMessage: _errorMessage,
            tagLanguageMode: widget.tagLanguageMode,
            onRetry: _refreshPosts,
            onRefresh: _refreshPosts,
            scrollController: _scrollController,
            emptyText: l10n.noPostsFound,
            isFavorited: widget.isFavorited,
            onToggleFavorite: widget.onToggleFavorite,
          ),
        ),
      ],
    );
  }
}

class _SearchTab extends StatefulWidget {
  const _SearchTab({
    required this.repository,
    required this.locale,
    required this.tagLanguageMode,
    required this.settings,
    required this.onToggleFavorite,
    required this.isFavorited,
    required this.onSearchCommitted,
    required this.onClearRecentSearches,
  });

  final DanbooruPostRepository repository;
  final Locale locale;
  final TagLanguageMode tagLanguageMode;
  final AppSettings settings;
  final ValueChanged<PostItem> onToggleFavorite;
  final bool Function(int postId) isFavorited;
  final ValueChanged<String> onSearchCommitted;
  final VoidCallback onClearRecentSearches;

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  static const int _pageSize = 30;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _suggestionDebounce;

  List<PostItem> _posts = const [];
  List<String> _suggestions = const [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _isSuggestionLoading = false;
  bool _hasMore = true;
  int _nextPage = 1;
  String _activeTags = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void didUpdateWidget(covariant _SearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.auth != widget.settings.auth ||
        oldWidget.settings.safeModeEnabled != widget.settings.safeModeEnabled ||
        oldWidget.settings.apiBaseUrl != widget.settings.apiBaseUrl) {
      if (_activeTags.isNotEmpty) {
        _refreshPosts(tags: _activeTags);
      }
    }
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _suggestionDebounce?.cancel();
      if (_suggestions.isNotEmpty || _isSuggestionLoading) {
        setState(() {
          _suggestions = const [];
          _isSuggestionLoading = false;
        });
      }
      return;
    }

    _suggestionDebounce?.cancel();
    _suggestionDebounce = Timer(const Duration(milliseconds: 280), () {
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSuggestionLoading = true;
    });

    final suggestions = await widget.repository.fetchTagSuggestions(
      baseUrl: widget.settings.apiBaseUrl,
      query: query,
      auth: widget.settings.auth,
    );

    if (!mounted) {
      return;
    }
    if (_searchController.text.trim() != query) {
      return;
    }

    setState(() {
      _isSuggestionLoading = false;
      _suggestions = suggestions;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _refreshPosts({String? tags}) async {
    final nextTags = (tags ?? _activeTags).trim();
    if (nextTags.isEmpty) {
      setState(() {
        _activeTags = '';
        _posts = const [];
        _errorMessage = null;
        _isInitialLoading = false;
        _hasMore = false;
        _nextPage = 1;
      });
      return;
    }
    await _loadPosts(reset: true, tags: nextTags);
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _activeTags.isEmpty) {
      return;
    }
    await _loadPosts(reset: false);
  }

  Future<void> _loadPosts({required bool reset, String? tags}) async {
    final queryTags = (tags ?? _activeTags).trim();
    if (queryTags.isEmpty) {
      return;
    }

    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
        _nextPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final page = reset ? 1 : _nextPage;
    try {
      final loadedPosts = await widget.repository.fetchPosts(
        baseUrl: widget.settings.apiBaseUrl,
        tags: queryTags,
        page: page,
        limit: _pageSize,
        auth: widget.settings.auth,
        safeModeEnabled: widget.settings.safeModeEnabled,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = reset ? loadedPosts : _mergePosts(_posts, loadedPosts);
        _activeTags = queryTags;
        _nextPage = page + 1;
        _hasMore = loadedPosts.length >= _pageSize;
        _errorMessage = null;
      });
    } on DanbooruApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (reset) {
        setState(() {
          _errorMessage = error.message;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loadMoreFailed)));
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (reset) {
        setState(() {
          _errorMessage = 'network_or_access';
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loadMoreFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (reset) {
            _isInitialLoading = false;
          } else {
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  List<PostItem> _mergePosts(List<PostItem> current, List<PostItem> incoming) {
    final seenIds = current.map((post) => post.id).toSet();
    final merged = current.toList(growable: true);
    for (final post in incoming) {
      if (seenIds.add(post.id)) {
        merged.add(post);
      }
    }
    return merged;
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    widget.onSearchCommitted(query);
    setState(() {
      _suggestions = const [];
    });
    _refreshPosts(tags: query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasQuery = _activeTags.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _onSearch,
                tooltip: l10n.searchAction,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        if (_isSuggestionLoading || _suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_isSuggestionLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ..._suggestions.take(12).map((entry) {
                    return ActionChip(
                      label: Text(entry),
                      onPressed: () {
                        _searchController.text = entry;
                        _onSearch();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        if (widget.settings.recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.recentSearches,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onClearRecentSearches,
                      child: Text(l10n.clear),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.settings.recentSearches.map((entry) {
                    return ActionChip(
                      label: Text(entry),
                      onPressed: () {
                        _searchController.text = entry;
                        _onSearch();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        if (!hasQuery && !_isInitialLoading)
          Expanded(
            child: Center(
              child: Text(
                l10n.searchPrompt,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          Expanded(
            child: _PostGrid(
              isLoading: _isInitialLoading,
              isLoadingMore: _isLoadingMore,
              hasMore: _hasMore,
              posts: _posts,
              locale: widget.locale,
              errorMessage: _errorMessage,
              tagLanguageMode: widget.tagLanguageMode,
              onRetry: () => _refreshPosts(tags: _activeTags),
              onRefresh: () => _refreshPosts(tags: _activeTags),
              scrollController: _scrollController,
              emptyText: l10n.noPostsFound,
              isFavorited: widget.isFavorited,
              onToggleFavorite: widget.onToggleFavorite,
            ),
          ),
      ],
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.isLoading,
    required this.posts,
    required this.locale,
    required this.tagLanguageMode,
    required this.onToggleFavorite,
  });

  final bool isLoading;
  final List<PostItem> posts;
  final Locale locale;
  final TagLanguageMode tagLanguageMode;
  final ValueChanged<PostItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(l10n.loadingFavorites),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Text(
          l10n.noFavoritesYet,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = _computeColumns(width);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostCard(
          post: post,
          locale: locale,
          tagLanguageMode: tagLanguageMode,
          isFavorited: true,
          onToggleFavorite: onToggleFavorite,
        );
      },
    );
  }
}

class _PostGrid extends StatelessWidget {
  const _PostGrid({
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.posts,
    required this.locale,
    required this.errorMessage,
    required this.tagLanguageMode,
    required this.onRetry,
    required this.onRefresh,
    required this.scrollController,
    required this.emptyText,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final List<PostItem> posts;
  final Locale locale;
  final String? errorMessage;
  final TagLanguageMode tagLanguageMode;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;
  final String emptyText;
  final bool Function(int postId) isFavorited;
  final ValueChanged<PostItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(l10n.loadingPosts),
          ],
        ),
      );
    }

    if (errorMessage != null && posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40),
              const SizedBox(height: 12),
              Text(l10n.postLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.apiEndpointHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = _computeColumns(width);
    final showFooter = isLoadingMore || !hasMore;
    final totalCount = posts.length + (showFooter ? 1 : 0);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: totalCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            if (isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                l10n.noMorePosts,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            );
          }

          final post = posts[index];
          return _PostCard(
            post: post,
            locale: locale,
            tagLanguageMode: tagLanguageMode,
            isFavorited: isFavorited(post.id),
            onToggleFavorite: onToggleFavorite,
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.locale,
    required this.tagLanguageMode,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  final PostItem post;
  final Locale locale;
  final TagLanguageMode tagLanguageMode;
  final bool isFavorited;
  final ValueChanged<PostItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ratingText = post.rating == PostRating.safe
        ? l10n.ratingSafe
        : l10n.ratingQuestionable;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.previewUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x99000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: isFavorited ? Colors.redAccent : Colors.white,
              ),
              tooltip: isFavorited ? l10n.removeFavorite : l10n.addFavorite,
              onPressed: () => onToggleFavorite(post),
              icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_outline),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${post.id}  $ratingText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags.take(3).map((tag) {
                    final translatedTag = TagLocalizer.translate(
                      rawTag: tag,
                      languageMode: tagLanguageMode,
                      appLocale: locale,
                    );
                    return _TagChip(label: translatedTag);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xAA121212),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

int _computeColumns(double width) {
  return width >= 1200
      ? 5
      : width >= 900
      ? 4
      : width >= 700
      ? 3
      : 2;
}
