import 'package:aetram_ticket_alerts/core/utils/attachment_utils.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_model.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_status.dart';
import 'package:aetram_ticket_alerts/features/tickets/utils/ticket_filters.dart';
import 'package:aetram_ticket_alerts/features/tickets/utils/ticket_validation.dart';
import 'package:flutter_test/flutter_test.dart';

TicketModel ticket(
  int id,
  TicketStatus status, {
  String? pickedBy,
  int day = 1,
}) => TicketModel(
  ticketId: id,
  subject: 'Subject $id',
  description: '<b>Details</b>',
  createdAt: DateTime(2026, 6, day),
  subCategoryName: 'Access',
  commentId: null,
  raisedBy: 'Requester',
  pickedBy: pickedBy,
  fullFilePath: null,
  status: status,
);

void main() {
  test('parses ticket JSON defensively', () {
    final value = TicketModel.fromJson({
      'TicketId': '143',
      'Subject': ' Login ',
      'Description': '<p>Help</p>',
      'CreatedAt': '2026-06-20T09:13:00Z',
      'SubCategoryName': 'Access',
      'CommentId': '25',
      'RaisedBy': 'Reeta',
      'PickedBy': null,
      'FullFilePath': 'file:/UploadedFiles/Tickets/a.png',
      'Status': ' In Progress ',
    });
    expect(value.ticketId, 143);
    expect(value.commentId, 25);
    expect(value.status, TicketStatus.inProgress);
    expect(value.isUnassigned, isTrue);
  });
  test('parses the API camelCase response', () {
    final value = TicketModel.fromJson({
      'ticketId': 148,
      'subject': 'Mobile ticket',
      'description': '<p>Test</p>',
      'createdAt': '2026-06-20T12:50:31.4042618',
      'subCategoryName': 'eKYC',
      'commentId': 186,
      'raisedBy': 'Reeta',
      'pickedBy': 'Hemalatha',
      'fullFilePath': null,
      'status': 'Closed',
    });
    expect(value.ticketId, 148);
    expect(value.subject, 'Mobile ticket');
    expect(value.status, TicketStatus.closed);
  });
  test('normalizes supported and unknown statuses', () {
    expect(normalizeTicketStatus('OPEN'), TicketStatus.open);
    expect(normalizeTicketStatus('in_progress'), TicketStatus.inProgress);
    expect(normalizeTicketStatus('closed '), TicketStatus.closed);
    expect(normalizeTicketStatus('waiting'), TicketStatus.unknown);
  });
  test('filters open and closed from a single collection', () {
    final values = [
      ticket(1, TicketStatus.closed),
      ticket(2, TicketStatus.inProgress, pickedBy: 'Support User 1'),
      ticket(3, TicketStatus.open),
    ];
    expect(filterOpenTickets(values).map((e) => e.ticketId), [3, 2]);
    expect(filterClosedTickets(values).map((e) => e.ticketId), [1]);
  });
  test('converts attachment paths safely', () {
    expect(
      buildAttachmentUrl(
        'file:/UploadedFiles/Tickets/a.png',
        'https://example.com',
      ),
      'https://example.com/UploadedFiles/Tickets/a.png',
    );
    expect(
      buildAttachmentUrl(
        'file://172.16.56.66/inetpub/wwwroot/UploadedFiles/Tickets/a.png',
        'https://example.com',
      ),
      'https://example.com/UploadedFiles/Tickets/a.png',
    );
    expect(
      buildAttachmentUrl(
        'https://cdn.example.com/a.pdf',
        'https://example.com',
      ),
      'https://cdn.example.com/a.pdf',
    );
    expect(buildAttachmentUrl(null, 'https://example.com'), isNull);
  });
  test('requires a close resolution comment', () {
    expect(
      validateResolutionComment('  '),
      'A resolution comment is required.',
    );
    expect(validateResolutionComment('Resolved'), isNull);
  });
}
