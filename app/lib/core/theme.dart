import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Arabic app theme configuration
class AppTheme {
  // ============================================
  // BRAND COLORS - Deep Teal & Gold (Modern Arabic)
  // ============================================

  /// Primary color - Deep Teal (Legacy of Islamic Art)
  static const Color primaryTeal = Color(0xFF00695C);

  /// Darker Teal for AppBars/Headers
  static const Color darkTeal = Color(0xFF004D40);

  /// Light Teal for accents
  static const Color lightTeal = Color(0xFF4DB6AC);

  /// Gold for Premium Highlights
  static const Color goldAccent = Color(0xFFFFD700);

  /// Deep Charcoal Background
  static const Color deepCharcoal = Color(0xFF121212);

  /// Surface Color (Slightly Lighter for Cards)
  static const Color surfaceColor = Color(0xFF1E1E1E);

  /// Success color
  static const Color successColor = Color(0xFF4CAF50);

  /// Warning amber
  static const Color warningColor = Color(0xFFFFC107);

  /// Error red
  static const Color errorColor = Color(0xFFE53935);

  // ============================================
  // MODERN ARABIC THEME
  // ============================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepCharcoal,
      fontFamily: GoogleFonts.cairo().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        onPrimary: Colors.white,
        secondary: goldAccent,
        onSecondary: Colors.black,
        surface: surfaceColor,
        onSurface: Colors.white,
        error: errorColor,
        onError: Colors.white,
        outline: Colors.white24,
      ),

      // App Bar - Elegant & Modern
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: deepCharcoal,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: goldAccent),
      ),

      // Cards - Glass-like Modern Feel
      cardTheme: CardThemeData(
        elevation: 4,
        color: surfaceColor,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),

      // Elevated Buttons - Teal with Gold Glow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 6,
          shadowColor: primaryTeal.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: const BorderSide(color: goldAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Input Fields - Modern & Spacious
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: goldAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white38),
        prefixIconColor: goldAccent,
        suffixIconColor: goldAccent,
      ),

      // FAB - Floating Gold
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldAccent,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: CircleBorder(),
      ),

      // Bottom Navigation - Clean & Sharp
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: deepCharcoal,
        selectedItemColor: goldAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),

      // Icons
      iconTheme: const IconThemeData(color: goldAccent, size: 26),

      // List Tiles
      listTileTheme: ListTileThemeData(
        tileColor: surfaceColor.withOpacity(0.5),
        iconColor: goldAccent,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Light theme - redirects to dark for consistency (App is Dark Mode only for now)
  static ThemeData get lightTheme => darkTheme;
}

/// Currency formatting utility for EGP
class CurrencyFormatter {
  /// Format amount as Egyptian Pounds (EGP/LE) -> ج.م
  static String formatEGP(double amount) {
    return '${amount.toStringAsFixed(2)} ج.م';
  }

  /// Alias for formatEGP (Strictly Arabic)
  static String format(double amount) {
    return formatEGP(amount);
  }
}
