import 'package:aetram_ticket_alerts/features/auth/data/firebase_login_service.dart';
import 'package:aetram_ticket_alerts/features/auth/models/support_user.dart';
import 'package:aetram_ticket_alerts/features/auth/providers/auth_provider.dart';
import 'package:aetram_ticket_alerts/core/storage/auth_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthStorage implements AuthStorage {
  SupportUser? savedUser;
  bool cleared = false;

  @override
  Future<void> save(SupportUser user) async => savedUser = user;

  @override
  Future<SupportUser?> restore() async => savedUser;

  @override
  Future<void> clear() async {
    cleared = true;
    savedUser = null;
  }
}

class FakeLoginService implements LoginService {
  FakeLoginService(this.result);
  final SupportUser? result;

  @override
  Future<SupportUser?> authenticate(String username, String password) async =>
      result;
}

void main() {
  const firebaseRecord = {
    'user_76': {
      'backendUserId': '76',
      'username': 'gopinath',
      'password': 'Gopinath@123',
    },
  };

  test('validates credentials returned by Firebase', () async {
    final service = FirebaseLoginService(lookup: (_) async => firebaseRecord);
    final user = await service.authenticate(' Gopinath ', 'Gopinath@123');
    expect(user?.backendUserId, '76');
    expect(user?.username, 'gopinath');
  });

  test(
    'validates credentials when Firebase stores users as an array',
    () async {
      final service = FirebaseLoginService(
        lookup: (_) async => [
          {
            'backendUserId': '121',
            'username': 'hemalatha',
            'password': 'Hemalatha@123',
          },
          {
            'backendUserId': '76',
            'username': 'gopinath',
            'password': 'Gopinath@123',
          },
        ],
      );
      final user = await service.authenticate('gopinath', 'Gopinath@123');
      expect(user?.backendUserId, '76');
    },
  );

  test('rejects an incorrect password', () async {
    final service = FirebaseLoginService(lookup: (_) async => firebaseRecord);
    expect(await service.authenticate('gopinath', 'wrong'), isNull);
  });

  test('rejects malformed Firebase records', () async {
    final service = FirebaseLoginService(
      lookup: (_) async => {
        'bad': {'username': 'gopinath', 'password': 'Gopinath@123'},
      },
    );
    expect(await service.authenticate('gopinath', 'Gopinath@123'), isNull);
  });

  test('secure session representation never contains password', () {
    const user = SupportUser(backendUserId: '76', username: 'gopinath');
    expect(user.toSessionJson(), {
      'backendUserId': '76',
      'username': 'gopinath',
    });
    expect(user.toSessionJson().containsKey('password'), isFalse);
  });

  test(
    'successful login saves and restores only the minimal session',
    () async {
      final storage = FakeAuthStorage();
      const firebaseUser = SupportUser(
        backendUserId: '76',
        username: 'gopinath',
      );
      final container = ProviderContainer(
        overrides: [
          authStorageProvider.overrideWithValue(storage),
          loginServiceProvider.overrideWithValue(
            FakeLoginService(firebaseUser),
          ),
        ],
      );
      addTearDown(container.dispose);

      final error = await container
          .read(authProvider.notifier)
          .login('gopinath', 'Gopinath@123');
      expect(error, isNull);
      expect(storage.savedUser?.toSessionJson(), {
        'backendUserId': '76',
        'username': 'gopinath',
      });

      await container.read(authProvider.notifier).initialize();
      expect(container.read(authProvider).isAuthenticated, isTrue);
    },
  );

  test('logout clears the restored session', () async {
    final storage = FakeAuthStorage()
      ..savedUser = const SupportUser(
        backendUserId: '76',
        username: 'gopinath',
      );
    final container = ProviderContainer(
      overrides: [authStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.notifier).initialize();
    await container.read(authProvider.notifier).logout();
    expect(storage.cleared, isTrue);
    expect(container.read(authProvider).isAuthenticated, isFalse);
  });
}
