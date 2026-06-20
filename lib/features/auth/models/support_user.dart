class SupportUser {
  const SupportUser({
    required this.backendUserId,
    required this.username,
    required this.password,
  });

  final String backendUserId;
  final String username;
  final String password;

  int get numericBackendUserId => int.parse(backendUserId);

  Map<String, String> toSessionJson() => {
    'backendUserId': backendUserId,
    'username': username,
  };

  factory SupportUser.fromSessionJson(Map<String, String> json) => SupportUser(
    backendUserId: json['backendUserId'] ?? '',
    username: json['username'] ?? '',
    password: '',
  );
}
