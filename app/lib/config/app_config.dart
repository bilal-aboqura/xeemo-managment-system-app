/// Environment configuration for the app.
///
/// This class holds all environment-specific configuration values.
/// In production, these should be loaded from environment variables
/// or a secure configuration source.
class AppConfig {
  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ootxctnlnajwwszgdcrf.supabase.co',
  );

  /// Supabase anonymous key for public API access
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vdHhjdG5sbmFqd3dzemdkY3JmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MDE0NDgsImV4cCI6MjA4NTI3NzQ0OH0.WYbsLeYU2M1ZANmrRVcWTUC-FDHn6ghncG8pPnvJwX4',
  );

  /// App name
  static const String appName = 'Xeemo Mandoob';

  /// App version
  static const String appVersion = '1.0.0';

  /// Check if Supabase is configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Validate configuration and throw if invalid
  static void validate() {
    if (!isSupabaseConfigured) {
      throw Exception(
        'Supabase configuration is missing. '
        'Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }
  }
}
