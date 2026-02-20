import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/danbooru_auth.dart';
import '../models/post_item.dart';

class DanbooruApiException implements Exception {
  const DanbooruApiException(this.message);

  final String message;

  @override
  String toString() => 'DanbooruApiException($message)';
}

class DanbooruPostRepository {
  DanbooruPostRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _defaultBaseUrl = 'https://danbooru.donmai.us';
  static const String _fallbackBaseUrl = 'https://safebooru.donmai.us';

  Future<List<PostItem>> fetchPosts({
    required String baseUrl,
    String tags = '',
    int page = 1,
    int limit = 30,
    DanbooruAuth auth = const DanbooruAuth.empty(),
    bool safeModeEnabled = true,
  }) async {
    final normalizedTags = _normalizeTags(
      rawTags: tags,
      safeModeEnabled: safeModeEnabled,
    );
    final normalizedLimit = limit.clamp(1, 200).toInt();
    final bases = _buildBaseCandidates(baseUrl);
    final errors = <String>[];

    for (final base in bases) {
      final requestUri = _buildPostsUri(
        base: base,
        page: page,
        limit: normalizedLimit,
        tags: normalizedTags,
        auth: auth,
      );

      try {
        final response = await _httpClient.get(
          requestUri,
          headers: _buildHeaders(auth),
        );

        if (response.statusCode != 200) {
          errors.add('${requestUri.host}: HTTP ${response.statusCode}');
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          errors.add('${requestUri.host}: invalid JSON payload');
          continue;
        }

        return decoded
            .whereType<Map<String, dynamic>>()
            .map((raw) => _mapPost(raw, requestUri))
            .whereType<PostItem>()
            .toList(growable: false);
      } catch (error) {
        errors.add('${requestUri.host}: $error');
      }
    }

    throw DanbooruApiException(
      'Unable to load posts. Tried ${bases.join(', ')}. ${errors.join(' | ')}',
    );
  }

  Future<List<String>> fetchTagSuggestions({
    required String baseUrl,
    required String query,
    DanbooruAuth auth = const DanbooruAuth.empty(),
    int limit = 12,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final normalizedLimit = limit.clamp(1, 30).toInt();
    final bases = _buildBaseCandidates(baseUrl);

    for (final base in bases) {
      final requestUri = _buildTagsUri(
        base: base,
        query: normalizedQuery,
        limit: normalizedLimit,
        auth: auth,
      );

      try {
        final response = await _httpClient.get(
          requestUri,
          headers: _buildHeaders(auth),
        );
        if (response.statusCode != 200) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          continue;
        }

        final suggestions = <String>[];
        for (final item in decoded.whereType<Map<String, dynamic>>()) {
          final name = (item['name'] as String?)?.trim();
          if (name == null || name.isEmpty) {
            continue;
          }
          suggestions.add(name);
        }

        final unique = <String>{};
        final filtered = suggestions
            .where((name) {
              final key = name.toLowerCase();
              if (!key.startsWith(normalizedQuery)) {
                return false;
              }
              return unique.add(key);
            })
            .toList(growable: false);

        if (filtered.isNotEmpty) {
          return filtered;
        }
      } catch (_) {
        continue;
      }
    }

    return const [];
  }

  Uri _buildPostsUri({
    required String base,
    required int page,
    required int limit,
    required String tags,
    required DanbooruAuth auth,
  }) {
    final baseUri = _normalizeBaseUri(base);
    final normalizedPath = _normalizePathWithSuffix(
      baseUri.path,
      '/posts.json',
    );

    final query = <String, String>{
      'limit': '$limit',
      'page': '$page',
      if (tags.isNotEmpty) 'tags': tags,
    };
    _appendAuthQuery(query, auth);

    return baseUri.replace(path: normalizedPath, queryParameters: query);
  }

  Uri _buildTagsUri({
    required String base,
    required String query,
    required int limit,
    required DanbooruAuth auth,
  }) {
    final baseUri = _normalizeBaseUri(base);
    final normalizedPath = _normalizePathWithSuffix(baseUri.path, '/tags.json');
    final queryParams = <String, String>{
      'limit': '$limit',
      'search[order]': 'count',
      'search[name_matches]': '$query*',
    };
    _appendAuthQuery(queryParams, auth);
    return baseUri.replace(path: normalizedPath, queryParameters: queryParams);
  }

  void _appendAuthQuery(Map<String, String> query, DanbooruAuth auth) {
    if (!auth.isConfigured) {
      return;
    }
    query['login'] = auth.login.trim();
    query['api_key'] = auth.apiKey.trim();
  }

  List<String> _buildBaseCandidates(String rawBase) {
    final input = rawBase.trim();
    final candidates = <String>[
      if (input.isNotEmpty) input,
      _defaultBaseUrl,
      _fallbackBaseUrl,
    ];
    final deduped = <String>[];
    final seen = <String>{};
    for (final candidate in candidates) {
      final key = candidate.toLowerCase();
      if (seen.add(key)) {
        deduped.add(candidate);
      }
    }
    return deduped;
  }

  Uri _normalizeBaseUri(String base) {
    final normalized = base.contains('://') ? base : 'https://$base';
    final uri = Uri.parse(normalized);
    if (uri.host.isEmpty) {
      throw DanbooruApiException('Invalid API base URL: $base');
    }
    return uri;
  }

  String _normalizePathWithSuffix(String currentPath, String suffix) {
    final path = currentPath.trim();
    if (path.isEmpty || path == '/') {
      return suffix;
    }
    final trimmed = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    return '$trimmed$suffix';
  }

  Map<String, String> _buildHeaders(DanbooruAuth auth) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'MikanseiFlutter/0.2 (by local-user)',
    };
    if (auth.isConfigured) {
      headers['Authorization'] = _buildBasicAuth(auth);
    }
    return headers;
  }

  String _buildBasicAuth(DanbooruAuth auth) {
    final raw = '${auth.login.trim()}:${auth.apiKey.trim()}';
    return 'Basic ${base64Encode(utf8.encode(raw))}';
  }

  String _normalizeTags({
    required String rawTags,
    required bool safeModeEnabled,
  }) {
    final tokens = rawTags
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: true);

    if (!safeModeEnabled) {
      return tokens.join(' ');
    }

    final hasRatingFilter = tokens.any(
      (token) => token.toLowerCase().startsWith('rating:'),
    );
    if (!hasRatingFilter) {
      tokens.add('rating:safe');
    }
    return tokens.join(' ');
  }

  PostItem? _mapPost(Map<String, dynamic> raw, Uri requestUri) {
    final id = raw['id'];
    if (id is! int) {
      return null;
    }

    final previewUrl = _normalizeImageUrl(
      raw['preview_file_url'] as String? ??
          raw['large_file_url'] as String? ??
          raw['file_url'] as String?,
      requestUri,
    );
    if (previewUrl == null) {
      return null;
    }

    final tagString = (raw['tag_string'] as String?)?.trim() ?? '';
    final tags = tagString.isEmpty
        ? const <String>[]
        : tagString.split(RegExp(r'\s+'));

    final ratingRaw = (raw['rating'] as String? ?? 'q').toLowerCase();
    final rating = ratingRaw == 's' ? PostRating.safe : PostRating.questionable;

    return PostItem(id: id, previewUrl: previewUrl, tags: tags, rating: rating);
  }

  String? _normalizeImageUrl(String? value, Uri requestUri) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return '${requestUri.scheme}:$value';
    }
    if (value.startsWith('/')) {
      return requestUri.replace(path: value, query: null).toString();
    }
    return null;
  }
}
