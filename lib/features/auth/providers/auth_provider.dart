import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/auth_storage.dart';
import '../data/firebase_login_service.dart';
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
final loginServiceProvider = Provider<LoginService>(
  (ref) => FirebaseLoginService(),
);
final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late AuthStorage _storage;
  late LoginService _loginService;
  @override
  AuthState build() {
    _storage = ref.read(authStorageProvider);
    _loginService = ref.read(loginServiceProvider);
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
    try {
      final match = await _loginService.authenticate(identity, password);
      if (match == null) {
        state = state.copyWith(busy: false);
        return 'Invalid username or password.';
      }
      await _storage.save(match);
      state = AuthState(user: match, initialized: true);
      return null;
    } on LoginServiceException catch (error) {
      state = state.copyWith(busy: false);
      return error.message;
    } catch (_) {
      state = state.copyWith(busy: false);
      return 'Unable to reach the login service. Please try again.';
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = const AuthState(initialized: true);
  }
}
