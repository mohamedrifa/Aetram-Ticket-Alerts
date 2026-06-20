import 'package:aetram_ticket_alerts/features/auth/data/local_authenticator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates the three configured login credentials', () {
    expect(
      authenticateStaticUser('hemalatha', 'Hemalatha@123')?.backendUserId,
      '121',
    );
    expect(
      authenticateStaticUser(' gopinath ', 'Gopinath@123')?.backendUserId,
      '76',
    );
    expect(authenticateStaticUser('vimal', 'Vimal@123')?.backendUserId, '31');
  });

  test('rejects invalid login credentials', () {
    expect(authenticateStaticUser('hemalatha', 'wrong'), isNull);
    expect(authenticateStaticUser('unknown', 'Vimal@123'), isNull);
  });
}
