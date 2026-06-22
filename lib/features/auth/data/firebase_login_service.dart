import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/support_user.dart';

typedef FirebaseUserLookup = Future<Object?> Function(String username);

class LoginServiceException implements Exception {
  const LoginServiceException(this.message);
  final String message;
}

abstract interface class LoginService {
  Future<SupportUser?> authenticate(String username, String password);
}

class FirebaseLoginService implements LoginService {
  FirebaseLoginService({FirebaseDatabase? database, FirebaseUserLookup? lookup})
    : _database = database,
      _lookup = lookup;

  final FirebaseDatabase? _database;
  final FirebaseUserLookup? _lookup;

  @override
  Future<SupportUser?> authenticate(String username, String password) async {
    final normalizedUsername = username.trim().toLowerCase();
    try {
      final rawUsers = await (_lookup != null
          ? _lookup(normalizedUsername)
          : _queryFirebase(normalizedUsername));
      return validateFirebaseCredentials(
        rawUsers: rawUsers,
        username: normalizedUsername,
        password: password,
      );
    } on LoginServiceException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const LoginServiceException(
          'Firebase database access was denied. Check its rules.',
        );
      }
      throw const LoginServiceException(
        'Unable to reach the login service. Please try again.',
      );
    } catch (_) {
      throw const LoginServiceException(
        'Unable to reach the login service. Please try again.',
      );
    }
  }

  Future<Object?> _queryFirebase(String username) async {
    if (Firebase.apps.isEmpty) {
      throw const LoginServiceException(
        'Firebase is not configured on this device.',
      );
    }
    final database = _database ?? FirebaseDatabase.instance;
    final snapshot = await database
        .ref('supportUsers')
        .orderByChild('username')
        .equalTo(username)
        .limitToFirst(1)
        .get();
    return snapshot.value;
  }
}

SupportUser? validateFirebaseCredentials({
  required Object? rawUsers,
  required String username,
  required String password,
}) {
  final Iterable<Object?> records;
  if (rawUsers is Map) {
    records = rawUsers.values;
  } else if (rawUsers is List) {
    records = rawUsers;
  } else {
    return null;
  }
  final normalizedUsername = username.trim().toLowerCase();
  for (final value in records) {
    if (value is! Map) continue;
    final record = <String, Object?>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
    final storedUsername = '${record['username'] ?? ''}'.trim().toLowerCase();
    final storedPassword = '${record['password'] ?? ''}';
    final backendUserId = '${record['backendUserId'] ?? ''}'.trim();
    if (storedUsername == normalizedUsername &&
        storedPassword == password &&
        backendUserId.isNotEmpty &&
        int.tryParse(backendUserId) != null) {
      return SupportUser(
        backendUserId: backendUserId,
        username: storedUsername,
      );
    }
  }
  return null;
}
