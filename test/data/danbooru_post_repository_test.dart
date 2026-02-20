import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mikansei/data/danbooru_post_repository.dart';
import 'package:mikansei/models/danbooru_auth.dart';

void main() {
  group('DanbooruPostRepository auth behavior', () {
    test('adds login/api_key query params for posts when auth is configured', () async {
      late Uri captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'preview_file_url': 'https://cdn.test/1.jpg',
              'tag_string': 'test',
              'rating': 's',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = DanbooruPostRepository(httpClient: client);
      await repository.fetchPosts(
        baseUrl: 'https://danbooru.donmai.us',
        auth: const DanbooruAuth(login: 'alice', apiKey: 'secret-key'),
      );

      expect(captured.path, '/posts.json');
      expect(captured.queryParameters['login'], 'alice');
      expect(captured.queryParameters['api_key'], 'secret-key');
    });

    test('adds login/api_key query params for tag suggestions when auth is configured', () async {
      late Uri captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode([
            {'name': 'cat'},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = DanbooruPostRepository(httpClient: client);
      await repository.fetchTagSuggestions(
        baseUrl: 'https://danbooru.donmai.us',
        query: 'ca',
        auth: const DanbooruAuth(login: 'alice', apiKey: 'secret-key'),
      );

      expect(captured.path, '/tags.json');
      expect(captured.queryParameters['login'], 'alice');
      expect(captured.queryParameters['api_key'], 'secret-key');
    });

    test('does not forward auth to fallback hosts', () async {
      final captured = <Uri>[];
      final authHeaders = <String?>[];
      final client = MockClient((request) async {
        captured.add(request.url);
        authHeaders.add(request.headers['authorization']);
        if (request.url.host == 'danbooru.donmai.us') {
          return http.Response('temporary failure', 500);
        }
        return http.Response(
          jsonEncode([
            {
              'id': 2,
              'preview_file_url': 'https://cdn.test/2.jpg',
              'tag_string': 'test',
              'rating': 's',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = DanbooruPostRepository(httpClient: client);
      await repository.fetchPosts(
        baseUrl: 'https://danbooru.donmai.us',
        auth: const DanbooruAuth(login: 'alice', apiKey: 'secret-key'),
      );

      expect(captured.length, 2);
      expect(captured.first.host, 'danbooru.donmai.us');
      expect(captured.first.queryParameters['login'], 'alice');
      expect(captured.first.queryParameters['api_key'], 'secret-key');
      expect(authHeaders.first, isNotNull);

      expect(captured.last.host, 'safebooru.donmai.us');
      expect(captured.last.queryParameters.containsKey('login'), isFalse);
      expect(captured.last.queryParameters.containsKey('api_key'), isFalse);
      expect(authHeaders.last, isNull);
    });

  });
}

