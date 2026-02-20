class DanbooruAuth {
  const DanbooruAuth({required this.login, required this.apiKey});

  const DanbooruAuth.empty() : login = '', apiKey = '';

  final String login;
  final String apiKey;

  bool get isConfigured => login.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  DanbooruAuth copyWith({String? login, String? apiKey}) {
    return DanbooruAuth(
      login: login ?? this.login,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DanbooruAuth &&
        other.login == login &&
        other.apiKey == apiKey;
  }

  @override
  int get hashCode => Object.hash(login, apiKey);
}
