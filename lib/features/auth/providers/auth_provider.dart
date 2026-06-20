import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/auth_storage.dart';
import '../data/local_authenticator.dart';
import '../models/support_user.dart';

class AuthState {
  const AuthState({this.user, this.initialized = false, this.busy = false});
  final SupportUser? user;
  final bool initialized;
  final bool busy;
  bool get isAuthenticated => user != null;
  AuthState copyWith({
    SupportUser? user,
    bool? initialized,
    bool? busy,
    bool clearUser = false,
  }) => AuthState(
    user: clearUser ? null : user ?? this.user,
    initialized: initialized ?? this.initialized,
    busy: busy ?? this.busy,
  );
}

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());
final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late AuthStorage _storage;
  @override
  AuthState build() {
    _storage = ref.read(authStorageProvider);
    return const AuthState();
  }

  Future<void> initialize() async {
    final user = await _storage.restore();
    state = AuthState(user: user, initialized: true);
  }

  Future<String?> login(String identity, String password) async {
    if (identity.trim().isEmpty || password.isEmpty) {
      return 'Username and password are required.';
    }
    state = state.copyWith(busy: true);
    final match = authenticateStaticUser(identity, password);
    if (match == null) {
      state = state.copyWith(busy: false);
      return 'Invalid username or password.';
    }
    await _storage.save(match);
    state = AuthState(user: match, initialized: true);
    return null;
  }

  Future<void> logout() async {
    await _storage.clear();
    state = const AuthState(initialized: true);
  }
}
