import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../utils/ticket_search.dart';
import '../widgets/ticket_card.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
    final state = ref.watch(ticketProvider);
    final tickets = ticketsPickedByUser(state.all, user.username);
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () =>
              ref.read(ticketProvider.notifier).load(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment_ind_outlined,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${tickets.length} assigned ticket${tickets.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.initialLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                )
              else if (tickets.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_ind_outlined,
                            size: 52,
                            color: AppColors.goldDark,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'No Assigned Tickets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tickets picked by this user will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return TicketCard(
                        ticket: ticket,
                        ticketId: ticket.ticketId,
                        onTap: () =>
                            context.push('/tickets/${ticket.ticketId}'),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
