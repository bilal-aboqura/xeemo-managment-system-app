import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/login_screen.dart';
import '../screens/create_ticket_screen.dart';
import '../screens/worker_home_screen.dart';
import '../screens/product_management_screen.dart';
import '../screens/tickets_dashboard_screen.dart';
import '../screens/ticket_detail_screen.dart';
import '../providers/auth_provider.dart';

/// Router provider for GoRouter with auth-based redirects
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/worker-home',
        name: 'workerHome',
        builder: (context, state) => const WorkerHomeScreen(),
      ),
      GoRoute(
        path: '/create-ticket',
        name: 'createTicket',
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/ticket/:id',
        name: 'ticketDetail',
        builder: (context, state) {
          final ticketId = state.pathParameters['id']!;
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductManagementScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const TicketsDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoading =
          authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.unknown;
      final isAuthenticated = authState.isAuthenticated;
      final isOnLoginPage = state.matchedLocation == '/login';

      // Don't redirect while loading auth state
      if (isLoading) return null;

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      // If authenticated and on login page, redirect based on role
      if (isAuthenticated && isOnLoginPage) {
        if (authState.user?.isManager == true) {
          return '/dashboard';
        } else {
          return '/worker-home';
        }
      }

      return null;
    },
  );
});

/// Notifier to refresh router when auth state changes
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
