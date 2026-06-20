import 'package:aetram_ticket_alerts/core/network/api_exception.dart';
import 'package:aetram_ticket_alerts/features/tickets/data/ticket_api_service.dart';
import 'package:aetram_ticket_alerts/features/tickets/models/ticket_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late TicketApiService service;
  setUp(() {
    dio = MockDio();
    service = TicketApiService(dio);
  });
  test('builds the documented ticket response request', () {
    const request = TicketResponseRequest(
      ticketId: 143,
      pickedBy: 121,
      status: '5',
      comment: 'Issue has been investigated and assigned.',
      commentId: 12,
    );
    expect(request.toJson(), {
      'TicketId': 143,
      'PickedBy': 121,
      'Status': '5',
      'Comment': 'Issue has been investigated and assigned.',
      'CommentId': 12,
    });
  });

  test('parses camelCase submission responses', () {
    final result = TicketActionResult.fromJson({
      'statusCode': 200,
      'status': 'Success',
      'message': 'Ticket response saved.',
    });
    expect(result.isSuccess, isTrue);
    expect(result.message, 'Ticket response saved.');
  });
  test('parses a successful API response', () async {
    when(() => dio.get<dynamic>(TicketApiService.getTicketsPath)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: [
          {'TicketId': 1, 'Status': 'Open'},
        ],
      ),
    );
    final result = await service.getTickets();
    expect(result, hasLength(1));
    expect(result.first.ticketId, 1);
  });
  test('deduplicates repeated ticket rows using the newest comment', () async {
    when(() => dio.get<dynamic>(TicketApiService.getTicketsPath)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: [
          {'ticketId': 143, 'commentId': 178, 'status': 'Closed'},
          {'ticketId': 143, 'commentId': 179, 'status': 'Closed'},
        ],
      ),
    );
    final result = await service.getTickets();
    expect(result, hasLength(1));
    expect(result.single.commentId, 179);
  });
  test('maps an API error response', () async {
    when(() => dio.get<dynamic>(TicketApiService.getTicketsPath)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'Message': 'Invalid request'},
        ),
      ),
    );
    expect(
      service.getTickets(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Invalid request',
        ),
      ),
    );
  });
}
