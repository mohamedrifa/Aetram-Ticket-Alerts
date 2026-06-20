import 'package:aetram_ticket_alerts/features/notifications/utils/new_ticket_detector.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_model.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_status.dart';
import 'package:flutter_test/flutter_test.dart';

TicketModel item(int id, TicketStatus status) => TicketModel(
  ticketId: id,
  subject: 'S',
  description: '',
  createdAt: null,
  subCategoryName: '',
  commentId: null,
  raisedBy: '',
  pickedBy: null,
  fullFilePath: null,
  status: status,
);
void main() {
  test('detects only unseen Open tickets', () {
    final result = detectNewOpenTickets(
      [
        item(1, TicketStatus.open),
        item(2, TicketStatus.closed),
        item(3, TicketStatus.inProgress),
      ],
      {2, 3},
    );
    expect(result.map((e) => e.ticketId), [1]);
  });
}
