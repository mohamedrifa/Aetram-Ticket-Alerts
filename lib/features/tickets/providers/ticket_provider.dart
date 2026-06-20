import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/services/local_notification_service.dart';
import '../../notifications/services/seen_ticket_store.dart';
import '../../notifications/utils/new_ticket_detector.dart';
import '../data/ticket_api_service.dart';
import '../data/ticket_repository.dart';
import '../models/ticket_model.dart';
import '../models/ticket_response.dart';
import '../utils/ticket_filters.dart';
import '../utils/ticket_validation.dart';

class TicketState {
  const TicketState({
    this.tickets = const [],
    this.initialLoading = false,
    this.refreshing = false,
    this.mutatingTicketId,
    this.error,
    this.lastUpdated,
  });
  final List<TicketModel> tickets;
  final bool initialLoading;
  final bool refreshing;
  final int? mutatingTicketId;
  final String? error;
  final DateTime? lastUpdated;
  List<TicketModel> get open => filterOpenTickets(tickets);
  List<TicketModel> get closed => filterClosedTickets(tickets);
  List<TicketModel> get all => sortAllTickets(tickets);
  TicketModel? byId(int id) {
    for (final ticket in tickets) {
      if (ticket.ticketId == id) return ticket;
    }
    return null;
  }

  TicketState copyWith({
    List<TicketModel>? tickets,
    bool? initialLoading,
    bool? refreshing,
    int? mutatingTicketId,
    bool clearMutation = false,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) => TicketState(
    tickets: tickets ?? this.tickets,
    initialLoading: initialLoading ?? this.initialLoading,
    refreshing: refreshing ?? this.refreshing,
    mutatingTicketId: clearMutation
        ? null
        : mutatingTicketId ?? this.mutatingTicketId,
    error: clearError ? null : error ?? this.error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

final ticketRepositoryProvider = Provider<TicketRepository>(
  (ref) => ApiTicketRepository(TicketApiService(ref.watch(dioProvider))),
);
final ticketProvider = NotifierProvider<TicketController, TicketState>(
  TicketController.new,
);

class TicketController extends Notifier<TicketState> {
  Timer? _timer;
  late TicketRepository _repository;
  final _seenStore = SeenTicketStore();
  @override
  TicketState build() {
    _repository = ref.watch(ticketRepositoryProvider);
    ref.onDispose(() => _timer?.cancel());
    return const TicketState();
  }

  Future<void> load({bool refresh = false}) async {
    if (state.initialLoading || state.refreshing) return;
    state = state.copyWith(
      initialLoading: state.tickets.isEmpty,
      refreshing: refresh && state.tickets.isNotEmpty,
      clearError: true,
    );
    try {
      final tickets = await _repository.getTickets();
      await _detectNewTickets(tickets);
      state = TicketState(tickets: tickets, lastUpdated: DateTime.now());
    } catch (error) {
      state = state.copyWith(
        initialLoading: false,
        refreshing: false,
        error: error is ApiException
            ? error.message
            : 'Unable to load tickets.',
      );
    }
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: EnvironmentConfig.pollingSeconds),
      (_) => load(refresh: true),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _detectNewTickets(List<TicketModel> tickets) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    final seen = await _seenStore.read(user.backendUserId);
    if (seen == null) {
      await _seenStore.write(
        user.backendUserId,
        tickets.map((e) => e.ticketId),
      );
      return;
    }
    await LocalNotificationService.instance.showNewTickets(
      detectNewOpenTickets(tickets, seen),
    );
    await _seenStore.write(user.backendUserId, {
      ...seen,
      ...tickets.map((e) => e.ticketId),
    });
  }

  Future<String?> take(TicketModel ticket) async {
    final user = ref.read(authProvider).user;
    if (user == null || state.mutatingTicketId != null)
      return 'Unable to identify the current user.';
    state = state.copyWith(mutatingTicketId: ticket.ticketId, clearError: true);
    try {
      await _repository.submit(
        TicketResponseRequest(
          ticketId: ticket.ticketId,
          pickedBy: user.backendUserId,
          status: 'In Progress',
          comment: 'Ticket taken by ${user.fullName}.',
          commentId: ticket.commentId ?? 0,
        ),
      );
      state = state.copyWith(clearMutation: true);
      await load(refresh: true);
      return null;
    } catch (error) {
      state = state.copyWith(clearMutation: true);
      await load(refresh: true);
      return error is ApiException
          ? error.message
          : 'Unable to take this ticket.';
    }
  }

  Future<String?> close(TicketModel ticket, String comment) async {
    final user = ref.read(authProvider).user;
    final validation = validateResolutionComment(comment);
    if (validation != null) return validation;
    if (user == null ||
        ticket.pickedBy?.trim().toLowerCase() !=
            user.fullName.trim().toLowerCase())
      return 'Only the assigned support user can close this ticket.';
    if (state.mutatingTicketId != null)
      return 'Another ticket action is already in progress.';
    state = state.copyWith(mutatingTicketId: ticket.ticketId, clearError: true);
    try {
      await _repository.submit(
        TicketResponseRequest(
          ticketId: ticket.ticketId,
          pickedBy: user.backendUserId,
          status: 'Closed',
          comment: comment.trim(),
          commentId: ticket.commentId ?? 0,
        ),
      );
      state = state.copyWith(clearMutation: true);
      await load(refresh: true);
      return null;
    } catch (error) {
      state = state.copyWith(clearMutation: true);
      await load(refresh: true);
      return error is ApiException
          ? error.message
          : 'Unable to close this ticket.';
    }
  }
}
