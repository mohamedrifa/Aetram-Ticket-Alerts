class TicketResponseRequest {
  const TicketResponseRequest({
    required this.ticketId,
    required this.pickedBy,
    required this.status,
    required this.comment,
    required this.commentId,
  });
  final int ticketId;
  final int pickedBy;
  final String status;
  final String comment;
  final int commentId;
  Map<String, dynamic> toJson() => {
    'TicketId': ticketId,
    'PickedBy': pickedBy,
    'Status': status,
    'Comment': comment,
    'CommentId': commentId,
  };
}

class TicketActionResult {
  const TicketActionResult({
    required this.statusCode,
    required this.status,
    required this.message,
  });
  final int statusCode;
  final String status;
  final String message;
  bool get isSuccess =>
      statusCode >= 200 && statusCode < 300 ||
      status.toLowerCase() == 'success';
  factory TicketActionResult.fromJson(Map<String, dynamic> json) =>
      TicketActionResult(
        statusCode: json['StatusCode'] is int
            ? json['StatusCode'] as int
            : int.tryParse('${json['StatusCode'] ?? ''}') ?? 0,
        status: '${json['Status'] ?? ''}',
        message: '${json['Message'] ?? 'Request completed.'}',
      );
}
