enum TicketStatus { open, inProgress, closed, unknown }

TicketStatus normalizeTicketStatus(Object? value) {
  final normalized = '${value ?? ''}'.trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]+'),
    '',
  );
  return switch (normalized) {
    'open' => TicketStatus.open,
    'inprogress' => TicketStatus.inProgress,
    'closed' => TicketStatus.closed,
    _ => TicketStatus.unknown,
  };
}

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
    TicketStatus.open => 'Open',
    TicketStatus.inProgress => 'In Progress',
    TicketStatus.closed => 'Closed',
    TicketStatus.unknown => 'Unknown',
  };
  bool get isActive =>
      this == TicketStatus.open || this == TicketStatus.inProgress;
}
