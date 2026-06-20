import '../../tickets/models/ticket_model.dart';
import '../../tickets/models/ticket_status.dart';

List<TicketModel> detectNewOpenTickets(
  Iterable<TicketModel> current,
  Set<int> seenIds,
) => current
    .where(
      (ticket) =>
          ticket.status == TicketStatus.open &&
          !seenIds.contains(ticket.ticketId),
    )
    .toList();
