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
    if (ticket == null) {
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
    }
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
            if (ticket.status == TicketStatus.closed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: .45),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.task_alt, color: AppColors.success),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Closed',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'This ticket is closed and cannot be updated.',
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              _TicketResponseForm(ticket: ticket),
          ],
        ),
      ),
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
      EnvironmentConfig.attachmentBaseUrl,
    );
    if (url == null) {
      return const _Section(
        title: 'Attachment',
        child: Text(
          'No attachment.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }
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
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox(
                  height: 210,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, color: AppColors.error),
                      SizedBox(height: 8),
                      Text('Attachment preview unavailable.'),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri == null ||
                  !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attachment could not be opened.'),
                    ),
                  );
                }
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

class _StatusOption {
  const _StatusOption(this.id, this.label);
  final String id;
  final String label;
}

const _statusOptions = <_StatusOption>[
  _StatusOption('1', 'Open'),
  _StatusOption('2', 'In Progress'),
  _StatusOption('3', 'On Hold'),
  _StatusOption('4', 'Escalated'),
  _StatusOption('5', 'Resolved'),
  _StatusOption('6', 'Closed'),
  _StatusOption('7', 'Reopened'),
  _StatusOption('8', 'Cancelled'),
];

class _TicketResponseForm extends ConsumerStatefulWidget {
  const _TicketResponseForm({required this.ticket});
  final TicketModel ticket;

  @override
  ConsumerState<_TicketResponseForm> createState() =>
      _TicketResponseFormState();
}

class _TicketResponseFormState extends ConsumerState<_TicketResponseForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  String? _selectedStatusId;

  @override
  void initState() {
    super.initState();
    _selectedStatusId = switch (widget.ticket.status) {
      TicketStatus.open => '1',
      TicketStatus.inProgress => '2',
      TicketStatus.closed => '6',
      TicketStatus.unknown => null,
    };
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final statusId = _selectedStatusId;
    if (statusId == null) return;
    final result = await ref
        .read(ticketProvider.notifier)
        .submitResponse(
          ticket: widget.ticket,
          statusId: statusId,
          comment: _commentController.text,
        );
    if (!mounted) return;
    if (result.success) _commentController.clear();
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.success
            ? AppColors.success.withValues(alpha: .95)
            : AppColors.error.withValues(alpha: .95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.black,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.message,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        ref.watch(ticketProvider).mutatingTicketId == widget.ticket.ticketId;
    return _Section(
      title: 'Submit Ticket Response',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              key: const Key('ticketStatusDropdown'),
              initialValue: _selectedStatusId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _statusOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.id,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: busy
                  ? null
                  : (value) => setState(() => _selectedStatusId = value),
              validator: (value) =>
                  value == null ? 'Please select a status.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('ticketResponseComment'),
              controller: _commentController,
              enabled: !busy,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comment',
                hintText: 'Enter the ticket response or resolution details.',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 72),
                  child: Icon(Icons.comment_outlined),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GoldButton(
              label: 'Submit',
              icon: Icons.send_rounded,
              loading: busy,
              onPressed: busy ? null : _submit,
            ),
          ],
        ),
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
    if (result == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => error = result);
    }
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
