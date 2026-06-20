import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tickets/providers/ticket_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.goldDark,
              child: Icon(Icons.person, size: 46, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            Text(
              user.role,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Employee code'),
                    subtitle: Text(user.employeeCode),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: const Text('Username'),
                    subtitle: Text(user.username),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Backend user ID'),
                    subtitle: Text('${user.backendUserId}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final ok =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text(
                          'Your local session will be cleared. Ticket notification history is kept for this user.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (!ok) return;
                ref.read(ticketProvider.notifier).stopPolling();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
