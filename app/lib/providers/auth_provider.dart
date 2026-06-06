import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart' as app_models;
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../config/app_config.dart';

/// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state enum for tracking authentication status
enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

/// Auth state class holding current auth status and user
class AuthState {
  final AuthStatus status;
  final app_models.User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  AuthState copyWith({
    AuthStatus? status,
    app_models.User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isWorker => user?.isWorker ?? false;
  bool get isManager => user?.isManager ?? false;
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  /// Initialize auth state
  Future<void> _init() async {
    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured, skipping auth init');
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authService.getCurrentUser();

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      SupabaseService.logError('Auth init failed', e);
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, error: null);

      final user = await _authService.signIn(email: email, password: password);

      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.message);
      rethrow;
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      rethrow;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider for current user
final currentUserProvider = Provider<app_models.User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for checking if user is a worker
final isWorkerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isWorker;
});

/// Provider for checking if user is a manager
final isManagerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isManager;
});

/// Provider to fetch worker name by user ID from profiles table
final workerNameProvider = FutureProvider.family<String, String>((
  ref,
  userId,
) async {
  if (!AppConfig.isSupabaseConfigured) {
    return 'غير متوفر';
  }

  try {
    final response = await SupabaseService.client
        .from('profiles')
        .select('name')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null && response['name'] != null) {
      return response['name'] as String;
    }
    return 'غير متوفر';
  } catch (e) {
    SupabaseService.logError('Failed to fetch worker name', e);
    return 'غير متوفر';
  }
});
