import '../models/support_user.dart';
import 'static_users.dart';

SupportUser? authenticateStaticUser(String identity, String password) {
  final lookup = identity.trim().toLowerCase();
  for (final user in staticSupportUsers) {
    final identityMatches = user.username.toLowerCase() == lookup;
    if (identityMatches && user.password == password) return user;
  }
  return null;
}
