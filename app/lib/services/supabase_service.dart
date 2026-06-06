import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Logger instance for consistent logging
final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);

/// Supabase service for database operations
class SupabaseService {
  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (!AppConfig.isSupabaseConfigured) {
      throw StateError(
        'Supabase is not configured. Please set SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return Supabase.instance.client;
  }

  /// Check if Supabase is available and properly configured
  static bool get isAvailable => AppConfig.isSupabaseConfigured;

  /// Get current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  static Stream<AuthState> get authStateStream => client.auth.onAuthStateChange;

  /// Log debug message
  static void logDebug(String message) => _logger.d(message);

  /// Log info message
  static void logInfo(String message) => _logger.i(message);

  /// Log warning message
  static void logWarning(String message) => _logger.w(message);

  /// Log error message
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
