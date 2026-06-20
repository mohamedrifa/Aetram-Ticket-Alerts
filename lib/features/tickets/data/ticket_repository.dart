import '../models/ticket_model.dart';
import '../models/ticket_response.dart';
import 'ticket_api_service.dart';

abstract interface class TicketRepository {
  Future<List<TicketModel>> getTickets();
  Future<TicketActionResult> submit(TicketResponseRequest request);
}

class ApiTicketRepository implements TicketRepository {
  ApiTicketRepository(this._api);
  final TicketApiService _api;
  @override
  Future<List<TicketModel>> getTickets() => _api.getTickets();
  @override
  Future<TicketActionResult> submit(TicketResponseRequest request) =>
      _api.submit(request);
}
