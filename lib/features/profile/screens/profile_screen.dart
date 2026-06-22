import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/services/android_alarm_ticket_service.dart';
import '../../tickets/providers/ticket_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.logout, color: AppColors.error),
                SizedBox(width: 10),
                Text('Sign out?'),
              ],
            ),
            content: const Text(
              'Your secure login session will be cleared. You will need to sign in again using Firebase credentials.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _signingOut = true);
    try {
      ref.read(ticketProvider.notifier).clearForLogout();
      await AndroidAlarmTicketService.cancel();
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Unable to sign out. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              user.username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Support user',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gold),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Username'),
                subtitle: Text(user.username),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const Key('signOutButton'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: _signingOut ? null : _signOut,
              icon: _signingOut
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(_signingOut ? 'Signing out...' : 'Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
