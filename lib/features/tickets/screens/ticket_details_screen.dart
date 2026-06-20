import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/environment_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/attachment_utils.dart';
import '../../../core/widgets/gold_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';
import '../providers/ticket_provider.dart';
import '../widgets/status_badge.dart';
import '../utils/ticket_validation.dart';

class TicketDetailsScreen extends ConsumerWidget {
  const TicketDetailsScreen({super.key, required this.ticketId});
  final int ticketId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketProvider);
    final ticket = state.byId(ticketId);
    if (ticket == null)
      return Scaffold(
        appBar: AppBar(title: Text('Ticket #$ticketId')),
        body: Center(
          child: state.initialLoading
              ? const CircularProgressIndicator(color: AppColors.gold)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ticket not found.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(ticketProvider.notifier).load(refresh: true),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
        ),
      );
    final user = ref.watch(authProvider).user!;
    final assignedToCurrent =
        ticket.pickedBy?.trim().toLowerCase() ==
        user.username.trim().toLowerCase();
    final mutating = state.mutatingTicketId == ticket.ticketId;
    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${ticket.ticketId}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ticket.subject,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: ticket.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Info(label: 'Category', value: ticket.subCategoryName),
                  _Info(label: 'Raised by', value: ticket.raisedBy),
                  _Info(
                    label: 'Assigned to',
                    value: ticket.isUnassigned
                        ? 'Not assigned'
                        : ticket.pickedBy!,
                  ),
                  _Info(
                    label: 'Created',
                    value: ticket.createdAt == null
                        ? 'Unknown time'
                        : DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(ticket.createdAt!.toLocal()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Description',
              child: ticket.description.trim().isEmpty
                  ? const Text(
                      'No description provided.',
                      style: TextStyle(color: AppColors.secondaryText),
                    )
                  : Html(
                      data: ticket.description,
                      style: {
                        'body': Style(
                          color: AppColors.primaryText,
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                      },
                    ),
            ),
            const SizedBox(height: 14),
            _Attachment(ticket: ticket),
            const SizedBox(height: 18),
            if (ticket.status == TicketStatus.open && ticket.isUnassigned)
              GoldButton(
                label: 'Take Ticket',
                icon: Icons.assignment_ind_outlined,
                loading: mutating,
                onPressed: () =>
                    _confirmTake(context, ref, ticket, user.username),
              )
            else if (ticket.status.isActive && assignedToCurrent)
              GoldButton(
                label: 'Close Ticket',
                icon: Icons.task_alt,
                loading: mutating,
                onPressed: () => _showCloseSheet(context, ref, ticket),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  ticket.status == TicketStatus.closed
                      ? 'This ticket is closed and read-only.'
                      : ticket.isUnassigned
                      ? 'No actions are available for this status.'
                      : 'Assigned to ${ticket.pickedBy}. Only that user can close it.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmTake(
    BuildContext context,
    WidgetRef ref,
    TicketModel ticket,
    String name,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Take this ticket?'),
            content: Text(
              'Ticket #${ticket.ticketId} will be assigned to $name.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Take Ticket'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final error = await ref.read(ticketProvider.notifier).take(ticket);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Ticket taken successfully.')),
    );
  }

  Future<void> _showCloseSheet(
    BuildContext context,
    WidgetRef ref,
    TicketModel ticket,
  ) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CloseTicketSheet(ticket: ticket),
    );
    if (success == true && context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket closed successfully.')),
      );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.goldLight,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _Attachment extends StatelessWidget {
  const _Attachment({required this.ticket});
  final TicketModel ticket;
  @override
  Widget build(BuildContext context) {
    final url = buildAttachmentUrl(
      ticket.fullFilePath,
      EnvironmentConfig.apiBaseUrl,
    );
    if (url == null)
      return const _Section(
        title: 'Attachment',
        child: Text(
          'No attachment.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    return _Section(
      title: 'Attachment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isImageUrl(url))
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                height: 210,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 100,
                  child: Center(child: Text('Attachment preview unavailable.')),
                ),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri == null ||
                  !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attachment could not be opened.'),
                    ),
                  );
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open attachment'),
          ),
        ],
      ),
    );
  }
}

class _CloseTicketSheet extends ConsumerStatefulWidget {
  const _CloseTicketSheet({required this.ticket});
  final TicketModel ticket;
  @override
  ConsumerState<_CloseTicketSheet> createState() => _CloseTicketSheetState();
}

class _CloseTicketSheetState extends ConsumerState<_CloseTicketSheet> {
  final controller = TextEditingController();
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final validation = validateResolutionComment(controller.text);
    if (validation != null) {
      setState(() => error = validation);
      return;
    }
    final result = await ref
        .read(ticketProvider.notifier)
        .close(widget.ticket, controller.text);
    if (!mounted) return;
    if (result == null)
      Navigator.pop(context, true);
    else
      setState(() => error = result);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user!;
    final busy =
        ref.watch(ticketProvider).mutatingTicketId == widget.ticket.ticketId;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Close Ticket',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '#${widget.ticket.ticketId} • Closed by ${user.username}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 18),
            TextField(
              key: const Key('resolutionField'),
              controller: controller,
              minLines: 4,
              maxLines: 7,
              enabled: !busy,
              decoration: InputDecoration(
                labelText: 'Resolution comment',
                hintText: 'Describe how the issue was resolved.',
                errorText: error,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GoldButton(
                    label: 'Close Ticket',
                    icon: Icons.task_alt,
                    loading: busy,
                    onPressed: busy ? null : submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
