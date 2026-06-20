import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../models/ticket_model.dart';
import 'status_badge.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.ticketId,
    required this.onTap,
  });
  final TicketModel ticket;
  final int ticketId;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final created = ticket.createdAt == null
        ? 'Unknown time'
        : DateFormat(
            'dd MMM yyyy, hh:mm a',
          ).format(ticket.createdAt!.toLocal());
    return Semantics(
      button: true,
      label: 'View ticket $ticketId',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          key: Key('ticketCard_$ticketId'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ticket ID: $ticketId',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stripHtml(ticket.description).isEmpty
                      ? 'No description provided.'
                      : stripHtml(ticket.description),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Meta(
                      icon: Icons.category_outlined,
                      text: ticket.subCategoryName,
                    ),
                    _Meta(
                      icon: Icons.person_outline,
                      text: 'Raised by ${ticket.raisedBy}',
                    ),
                    _Meta(
                      icon: Icons.support_agent,
                      text: ticket.isUnassigned
                          ? 'Not assigned'
                          : ticket.pickedBy!,
                    ),
                    if (ticket.fullFilePath != null)
                      const _Meta(icon: Icons.attach_file, text: 'Attachment'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        created,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Text(
                      'VIEW',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.gold,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AppColors.goldDark),
      const SizedBox(width: 5),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 210),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
      ),
    ],
  );
}
