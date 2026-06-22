import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../models/ticket_model.dart';
import '../models/ticket_response.dart';

class TicketApiService {
  TicketApiService(this._dio);
  final Dio _dio;
  static const getTicketsPath = '/api/Ticket/GetTicketDetail';
  static const insertResponsePath = '/api/Ticket/InsertTicketResponse';

  Future<List<TicketModel>> getTickets() async {
    try {
      final response = await _dio.get<dynamic>(getTicketsPath);
      final body = response.data;
      dynamic raw = body;
      if (body is Map) {
        raw = body['Data'] ?? body['data'] ?? body['Result'] ?? body['result'];
      }
      if (raw is! List) {
        throw const ApiException(
          'The ticket service returned an unexpected response.',
        );
      }
      final parsed = raw
          .whereType<Map>()
          .map((item) => TicketModel.fromJson(Map<String, dynamic>.from(item)))
          .where((ticket) => ticket.ticketId > 0)
          .toList();
      final unique = <int, TicketModel>{};
      for (final ticket in parsed) {
        final previous = unique[ticket.ticketId];
        if (previous == null ||
            (ticket.commentId ?? 0) >= (previous.commentId ?? 0)) {
          unique[ticket.ticketId] = ticket;
        }
      }
      return unique.values.toList();
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<TicketActionResult> submit(TicketResponseRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        insertResponsePath,
        data: request.toJson(),
      );
      if (response.data is! Map) {
        throw const ApiException(
          'The ticket service returned an unexpected response.',
        );
      }
      final result = TicketActionResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      if (!result.isSuccess) {
        throw ApiException(
          result.message.isEmpty
              ? 'The ticket could not be updated.'
              : result.message,
        );
      }
      return result;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  ApiException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      String? message;
      for (final entry in data.entries) {
        if ('${entry.key}'.toLowerCase() == 'message') {
          message = '${entry.value}';
          break;
        }
      }
      if (message != null && message.trim().isNotEmpty) {
        return ApiException(message);
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException('The request timed out. Please try again.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'No network connection. Check your connection and retry.',
      );
    }
    if ((error.response?.statusCode ?? 0) >= 500) {
      return const ApiException(
        'The ticket service is temporarily unavailable.',
      );
    }
    return const ApiException('Unable to contact the ticket service.');
  }
}
