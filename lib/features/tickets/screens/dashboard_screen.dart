import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/services/local_notification_service.dart';
import '../../notifications/services/android_alarm_ticket_service.dart';
import '../models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(ticketProvider.notifier)
        ..load()
        ..startPolling();
      final user = ref.read(authProvider).user;
      if (user != null) {
        AndroidAlarmTicketService.schedule(user.numericBackendUserId);
      }
    });
    LocalNotificationService.onTicketTap = (id) {
      if (mounted) context.go('/tickets/$id');
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(ticketProvider.notifier).stopPolling();
    LocalNotificationService.onTicketTap = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(ticketProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      controller.load(refresh: true);
      controller.startPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user!;
    final state = ref.watch(ticketProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: const LinearGradient(
                          colors: [AppColors.goldLight, AppColors.goldDark],
                        ),
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AETRAM SUPPORT',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            user.username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh tickets',
                      onPressed: state.refreshing
                          ? null
                          : () => ref
                                .read(ticketProvider.notifier)
                                .load(refresh: true),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ticket alerts are active when permission is enabled.',
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none),
                    ),
                    IconButton(
                      tooltip: 'Profile',
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(Icons.account_circle_outlined),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _Summary(
                        label: 'OPEN',
                        value: state.open.length,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Summary(
                        label: 'CLOSED',
                        value: state.closed.length,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Summary(
                        label: 'TOTAL',
                        value: state.all.length,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Updated ${DateFormat('hh:mm a').format(state.lastUpdated!)}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const TabBar(
                indicatorColor: AppColors.gold,
                labelColor: AppColors.goldLight,
                unselectedLabelColor: AppColors.secondaryText,
                tabs: [
                  Tab(text: 'Open'),
                  Tab(text: 'Closed'),
                  Tab(text: 'All'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TicketList(
                      tickets: state.open,
                      state: state,
                      emptyTitle: 'No Open Tickets',
                      emptyMessage: 'All support requests have been handled.',
                    ),
                    _TicketList(
                      tickets: state.closed,
                      state: state,
                      emptyTitle: 'No Closed Tickets',
                      emptyMessage: 'Resolved tickets will appear here.',
                    ),
                    _TicketList(
                      tickets: state.all,
                      state: state,
                      emptyTitle: 'No Tickets Available',
                      emptyMessage:
                          'Tickets will appear after a successful refresh.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  );
}

class _TicketList extends ConsumerWidget {
  const _TicketList({
    required this.tickets,
    required this.state,
    required this.emptyTitle,
    required this.emptyMessage,
  });
  final List<TicketModel> tickets;
  final TicketState state;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.initialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => ref.read(ticketProvider.notifier).load(refresh: true),
      child: CustomScrollView(
        key: PageStorageKey(emptyTitle),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state.error != null)
            SliverToBoxAdapter(child: _ErrorCard(message: state.error!)),
          if (tickets.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.goldDark,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        emptyTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              sliver: SliverList.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return TicketCard(
                    ticket: ticket,
                    onTap: () => context.push('/tickets/${ticket.ticketId}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withValues(alpha: .5)),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off, color: AppColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
        TextButton(
          onPressed: () =>
              ref.read(ticketProvider.notifier).load(refresh: true),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
