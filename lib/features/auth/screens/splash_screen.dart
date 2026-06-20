import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../notifications/services/battery_optimization_service.dart';
import '../../notifications/services/local_notification_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await LocalNotificationService.instance.requestPermissionIfNeeded();
      await BatteryOptimizationService.requestExemptionIfNeeded();
      await ref.read(authProvider.notifier).initialize();
      if (!mounted) return;
      context.go(
        ref.read(authProvider).isAuthenticated ? '/dashboard' : '/login',
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent, size: 64, color: AppColors.gold),
            SizedBox(height: 18),
            Text(
              'AETRAM',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 5,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'TICKET SUPPORT',
              style: TextStyle(color: AppColors.gold, letterSpacing: 2),
            ),
            SizedBox(height: 28),
            SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
