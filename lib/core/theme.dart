import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Brown Palette
  static const Color primary = Color(0xFF3D2B1F); // Dark Brown
  static const Color primaryDark = Color(0xFF2A1D15); // Darker brown
  static const Color secondary = Color(0xFFD4C4B5); // Light beige/cream
  static const Color secondaryDark = Color(0xFFC4B4A5); // Slightly darker beige
  
  static const Color background = Color(0xFFFDFAF6); // Warm Off-White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF5F5F5);
  
  // Overlay colors for coral backgrounds
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryMuted = Color(0xB3FFFFFF); // 70% white
  
  // Modal/Dialog colors
  static const Color modalBackground = Color(0xFFFFFFFF);
  static const Color buttonDark = Color(0xFF1A1A1A);
  static const Color buttonOutline = Color(0xFFE0E0E0);

  // Text colors
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textSub = Color(0xFF757575);
  static const Color textOnCoral = Color(0xFFFFFFFF);
  static const Color textOnCoralMuted = Color(0xCCFFFFFF);
  
  // Status colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00C853);
  
  // Legacy pastel colors (kept for compatibility)
  static const Color pastelGreen = Color(0xFFE6FFF0);
  static const Color pastelPurple = Color(0xFFF0E6FF);
  static const Color pastelOrange = Color(0xFFFFF7E6);
  static const Color pastelBlue = Color(0xFFE6F4FF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.textMain,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.textMain,
        displayColor: AppColors.textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMain,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          minimumSize: const Size(120, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          side: const BorderSide(color: AppColors.buttonOutline, width: 1.5),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.buttonDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          minimumSize: const Size(120, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        hintStyle: TextStyle(
          color: AppColors.textSub.withOpacity(0.6),
          fontSize: 16,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.modalBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
