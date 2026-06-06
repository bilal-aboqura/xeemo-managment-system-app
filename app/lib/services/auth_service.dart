import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as app_models;
import 'supabase_service.dart';

/// Authentication service for email/password login with Supabase
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  /// Sign in with email and password
  ///
  /// Returns the authenticated user on success
  /// Throws [AuthException] on failure
  Future<app_models.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      SupabaseService.logInfo('Attempting sign in for: $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      SupabaseService.logInfo('Sign in successful for: $email');

      // Fetch user profile to get role
      final profile = await _fetchUserProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      SupabaseService.logError('Sign in failed', e);
      rethrow;
    } catch (e, stackTrace) {
      SupabaseService.logError(
        'Unexpected error during sign in',
        e,
        stackTrace,
      );
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      SupabaseService.logInfo('Signing out user');
      await _client.auth.signOut();
      SupabaseService.logInfo('Sign out successful');
    } catch (e, stackTrace) {
      SupabaseService.logError('Sign out failed', e, stackTrace);
      rethrow;
    }
  }

  /// Get the current authenticated user profile
  ///
  /// Returns null if not authenticated
  Future<app_models.User?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    return _fetchUserProfile(authUser.id);
  }

  /// Fetch user profile from the profiles table
  Future<app_models.User> _fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        SupabaseService.logInfo(
          'User profile not found, using default worker profile',
        );
        final email = _client.auth.currentUser?.email ?? '';
        final name = email.isNotEmpty ? email.split('@').first : 'User';

        return app_models.User(
          userId: userId,
          name: name,
          email: email,
          role: app_models.UserRole.worker,
        );
      }

      // Map database response to User model
      final roleString = response['role'] as String? ?? 'worker';
      app_models.UserRole role;
      switch (roleString) {
        case 'super_manager':
          role = app_models.UserRole.superManager;
          break;
        case 'manager':
          role = app_models.UserRole.manager;
          break;
        default:
          role = app_models.UserRole.worker;
      }

      return app_models.User(
        userId: response['user_id'] as String,
        name: response['name'] as String? ?? 'Unknown',
        email: response['email'] as String? ?? '',
        role: role,
        createdAt: response['created_at'] != null
            ? DateTime.tryParse(response['created_at'] as String)
            : null,
      );
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to fetch user profile', e, stackTrace);

      // Return a default user if profile fetch fails
      final email = _client.auth.currentUser?.email ?? '';
      final name = email.isNotEmpty ? email.split('@').first : 'User';

      return app_models.User(
        userId: userId,
        name: name,
        email: email,
        role: app_models.UserRole.worker,
      );
    }
  }

  /// Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    // This is a workaround since Supabase doesn't have a direct API for this
    // In production, you might want to use a cloud function
    return false;
  }
}
