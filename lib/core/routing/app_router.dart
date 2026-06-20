import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/tickets/screens/dashboard_screen.dart';
import '../../features/tickets/screens/ticket_details_screen.dart';
import '../../features/tickets/screens/my_tickets_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (!auth.initialized) return path == '/splash' ? null : '/splash';
      if (!auth.isAuthenticated) return path == '/login' ? null : '/login';
      if (path == '/login' || path == '/splash') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(
        path: '/tickets/:ticketId',
        builder: (_, state) => TicketDetailsScreen(
          ticketId: int.tryParse(state.pathParameters['ticketId'] ?? '') ?? 0,
        ),
      ),
      GoRoute(path: '/my-tickets', builder: (_, __) => const MyTicketsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
