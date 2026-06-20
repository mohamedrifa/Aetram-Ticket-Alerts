import 'ticket_status.dart';

class TicketModel {
  const TicketModel({
    required this.ticketId,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.subCategoryName,
    required this.commentId,
    required this.raisedBy,
    required this.pickedBy,
    required this.fullFilePath,
    required this.status,
  });
  final int ticketId;
  final String subject;
  final String description;
  final DateTime? createdAt;
  final String subCategoryName;
  final int? commentId;
  final String raisedBy;
  final String? pickedBy;
  final String? fullFilePath;
  final TicketStatus status;

  bool get isUnassigned => pickedBy == null || pickedBy!.trim().isEmpty;
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      for (final entry in json.entries) entry.key.toLowerCase(): entry.value,
    };
    Object? value(String key) => normalized[key.toLowerCase()];
    int? integer(Object? value) =>
        value is int ? value : int.tryParse('${value ?? ''}');
    String text(String key, [String fallback = 'Not available']) {
      final result = '${value(key) ?? ''}'.trim();
      return result.isEmpty ? fallback : result;
    }

    String? optional(String key) {
      final result = '${value(key) ?? ''}'.trim();
      return result.isEmpty || result.toLowerCase() == 'null' ? null : result;
    }

    return TicketModel(
      ticketId: integer(value('TicketId')) ?? 0,
      subject: text('Subject', 'Untitled ticket'),
      description: text('Description', ''),
      createdAt: DateTime.tryParse('${value('CreatedAt') ?? ''}'),
      subCategoryName: text('SubCategoryName'),
      commentId: integer(value('CommentId')),
      raisedBy: text('RaisedBy'),
      pickedBy: optional('PickedBy'),
      fullFilePath: optional('FullFilePath'),
      status: normalizeTicketStatus(value('Status')),
    );
  }
}
