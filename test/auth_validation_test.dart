import 'package:aetram_ticket_alerts/features/auth/data/local_authenticator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates username and employee-code login credentials', () {
    expect(
      authenticateStaticUser('support1', 'Support@123')?.backendUserId,
      95,
    );
    expect(
      authenticateStaticUser(' emp002 ', 'Support@456')?.backendUserId,
      96,
    );
  });

  test('rejects invalid login credentials', () {
    expect(authenticateStaticUser('support1', 'wrong'), isNull);
    expect(authenticateStaticUser('unknown', 'Support@123'), isNull);
  });
}
