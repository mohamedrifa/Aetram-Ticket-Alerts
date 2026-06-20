import 'package:aetram_ticket_alerts/features/notifications/utils/ticket_count_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects only a stored ticket-count increase', () {
    expect(hasTicketCountIncreased(null, 4), isFalse);
    expect(hasTicketCountIncreased(4, 4), isFalse);
    expect(hasTicketCountIncreased(5, 4), isFalse);
    expect(hasTicketCountIncreased(4, 5), isTrue);
  });
}
