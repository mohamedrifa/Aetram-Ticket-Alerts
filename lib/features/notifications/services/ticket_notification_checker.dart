import 'package:shared_preferences/shared_preferences.dart';

import '../../tickets/models/ticket_model.dart';
import '../../tickets/models/ticket_status.dart';
import '../utils/ticket_count_detector.dart';
import 'local_notification_service.dart';
import 'seen_ticket_store.dart';

Future<void> processTicketSnapshot({
  required int userId,
  required Iterable<TicketModel> tickets,
}) async {
  final unique = <int, TicketModel>{
    for (final ticket in tickets) ticket.ticketId: ticket,
  };
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final countKey = 'ticketCount_$userId';
  final storedCount = prefs.getInt(countKey);
  final seenStore = SeenTicketStore();
  final seen = await seenStore.read(userId);

  if (storedCount == null || seen == null) {
    await prefs.setInt(countKey, unique.length);
    await seenStore.write(userId, unique.keys);
    return;
  }

  if (hasTicketCountIncreased(storedCount, unique.length)) {
    final newOpenTickets = unique.values
        .where(
          (ticket) =>
              ticket.status == TicketStatus.open &&
              !seen.contains(ticket.ticketId),
        )
        .toList();
    await LocalNotificationService.instance.showNewTickets(newOpenTickets);
  }

  await prefs.setInt(countKey, unique.length);
  await seenStore.write(userId, {...seen, ...unique.keys});
}
