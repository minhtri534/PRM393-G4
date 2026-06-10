import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme matching the web frontend color scheme
class AppTheme {
  // Brand colors (matching Tailwind config)
  static const Color primaryColor = Color(0xFF2563eb); // Blue
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryDark = Color(0xFF1e40af);
  
  static const Color secondaryColor = Color(0xFF22d3ee); // Cyan
  static const Color tertiaryColor = Color(0xFF7c3aed); // Violet
  
  // Semantic colors
  static const Color successColor = Color(0xFF10b981); // Emerald
  static const Color warningColor = Color(0xFFF59e0b); // Amber
  static const Color errorColor = Color(0xFFF43f5e); // Rose
  static const Color infoColor = Color(0xFF22d3ee); // Cyan
  
  // Surface colors
  static const Color backgroundColor = Color(0xFFffffff); // White
  static const Color surfaceSoftColor = Color(0xFFF8FAFC); // Slate soft
  
  // Text colors
  static const Color textPrimaryColor = Color(0xFF1e293b);
  static const Color textSecondaryColor = Color(0xFF64748b);
  static const Color textHintColor = Color(0xFF94a3b8);
  
  // Border and divider
  static const Color borderColor = Color(0xFFe2e8f0);
  static const Color dividerColor = Color(0xFFf1f5f9);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: backgroundColor,
        error: errorColor,
        outline: borderColor,
      ),
      
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoftColor,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textHintColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoftColor,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 16,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,
      
      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearMinHeight: 4,
      ),
    );
  }
}
