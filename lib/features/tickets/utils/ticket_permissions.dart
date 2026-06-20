import '../models/ticket_model.dart';

bool canUserUpdateTicket({
  required TicketModel ticket,
  required String username,
  required String backendUserId,
}) {
  if (ticket.isUnassigned) return true;
  final assignee = ticket.pickedBy!.trim().toLowerCase();
  return assignee == username.trim().toLowerCase() ||
      assignee == backendUserId.trim().toLowerCase();
}
