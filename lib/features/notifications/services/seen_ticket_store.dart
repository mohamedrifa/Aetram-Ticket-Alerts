import 'package:shared_preferences/shared_preferences.dart';

class SeenTicketStore {
  Future<Set<int>?> read(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'seenTicketIds_$userId';
    if (!prefs.containsKey(key)) return null;
    return (prefs.getStringList(key) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> write(int userId, Iterable<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'seenTicketIds_$userId',
      ids.map((id) => '$id').toList(),
    );
  }
}
