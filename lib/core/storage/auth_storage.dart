import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/models/support_user.dart';

class AuthStorage {
  AuthStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const _sessionKey = 'authenticatedSession';

  Future<void> save(SupportUser user) =>
      _storage.write(key: _sessionKey, value: jsonEncode(user.toSessionJson()));
  Future<SupportUser?> restore() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;
    try {
      final map = (jsonDecode(raw) as Map).map(
        (key, value) => MapEntry('$key', '$value'),
      );
      final user = SupportUser.fromSessionJson(map);
      return user.backendUserId.isEmpty || user.username.isEmpty ? null : user;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
