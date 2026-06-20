class SupportUser {
  const SupportUser({
    required this.backendUserId,
    required this.employeeCode,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
  });
  final int backendUserId;
  final String employeeCode;
  final String username;
  final String password;
  final String fullName;
  final String role;

  Map<String, String> toSessionJson() => {
    'backendUserId': '$backendUserId',
    'employeeCode': employeeCode,
    'username': username,
    'fullName': fullName,
    'role': role,
  };

  factory SupportUser.fromSessionJson(Map<String, String> json) => SupportUser(
    backendUserId: int.tryParse(json['backendUserId'] ?? '') ?? 0,
    employeeCode: json['employeeCode'] ?? '',
    username: json['username'] ?? '',
    password: '',
    fullName: json['fullName'] ?? '',
    role: json['role'] ?? '',
  );
}
