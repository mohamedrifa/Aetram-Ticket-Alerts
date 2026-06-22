class SupportUser {
  const SupportUser({required this.backendUserId, required this.username});

  final String backendUserId;
  final String username;

  int get numericBackendUserId => int.parse(backendUserId);

  Map<String, String> toSessionJson() => {
    'backendUserId': backendUserId,
    'username': username,
  };

  factory SupportUser.fromSessionJson(Map<String, String> json) => SupportUser(
    backendUserId: json['backendUserId'] ?? '',
    username: json['username'] ?? '',
  );
}
