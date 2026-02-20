import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/post_item.dart';

class FavoritesRepository {
  static const String _favoritesKey = 'favorite_posts_json';

  Future<List<PostItem>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_tryMapPost)
          .whereType<PostItem>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveFavorites(List<PostItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonText = jsonEncode(
      favorites.map((item) => item.toJson()).toList(growable: false),
    );
    await prefs.setString(_favoritesKey, jsonText);
  }

  PostItem? _tryMapPost(Map<String, dynamic> raw) {
    try {
      return PostItem.fromJson(raw);
    } catch (_) {
      return null;
    }
  }
}
