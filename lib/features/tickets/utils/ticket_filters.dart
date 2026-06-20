import '../models/ticket_model.dart';
import '../models/ticket_status.dart';

List<TicketModel> filterOpenTickets(Iterable<TicketModel> tickets) {
  final values = tickets.where((ticket) => ticket.status.isActive).toList();
  values.sort((a, b) {
    final aRank = a.status == TicketStatus.open && a.isUnassigned ? 0 : 1;
    final bRank = b.status == TicketStatus.open && b.isUnassigned ? 0 : 1;
    if (aRank != bRank) return aRank.compareTo(bRank);
    return (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
      a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  });
  return values;
}

List<TicketModel> filterClosedTickets(Iterable<TicketModel> tickets) =>
    _newest(tickets.where((ticket) => ticket.status == TicketStatus.closed));
List<TicketModel> sortAllTickets(Iterable<TicketModel> tickets) =>
    _newest(tickets);
List<TicketModel> _newest(Iterable<TicketModel> tickets) =>
    tickets.toList()..sort(
      (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
