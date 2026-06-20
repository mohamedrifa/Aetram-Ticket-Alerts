import '../../../core/utils/html_utils.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';

List<TicketModel> searchTickets(Iterable<TicketModel> tickets, String query) {
  final value = query.trim().toLowerCase();
  if (value.isEmpty) return tickets.toList();
  return tickets.where((ticket) {
    final searchable = <String>[
      '${ticket.ticketId}',
      ticket.subject,
      stripHtml(ticket.description),
      ticket.subCategoryName,
      ticket.raisedBy,
      ticket.pickedBy ?? '',
      ticket.status.label,
    ].join(' ').toLowerCase();
    return searchable.contains(value);
  }).toList();
}

List<TicketModel> ticketsPickedByUser(
  Iterable<TicketModel> tickets,
  String username,
) {
  final value = username.trim().toLowerCase();
  return tickets
      .where((ticket) => ticket.pickedBy?.trim().toLowerCase() == value)
      .toList();
}
