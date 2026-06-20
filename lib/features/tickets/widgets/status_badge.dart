import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/ticket_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final TicketStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TicketStatus.open => AppColors.gold,
      TicketStatus.inProgress => AppColors.goldLight,
      TicketStatus.closed => AppColors.success,
      TicketStatus.unknown => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        border: Border.all(color: color.withValues(alpha: .6)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: .4,
        ),
      ),
    );
  }
}
