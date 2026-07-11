import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Colors per v3 Warm Cream & Coral System
  static const Color primaryCoral = AppColors.heroGradientStart;
  static const Color primaryPurple = primaryCoral;
  static const Color backgroundLight = Color(0xFFF8F6F0);
  static const Color backgroundDark = Color(0xFF1C1917);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF262220);
  static const Color textDark = Color(0xFF1C1917);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8C827A);
  static const Color textGrayLight = Color(0xFF70665E);
  static const Color textGrayDark = Color(0xFFA89F96);

  // Category colors mirror AppColors
  static const Color groceries = AppColors.categoryGroceries;
  static const Color travel = AppColors.categoryTravel;
  static const Color car = AppColors.categoryCar;
  static const Color home = AppColors.categoryHome;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryCoral,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: primaryCoral,
      secondary: AppColors.darkAccent,
      surface: cardLight,
      onSurface: textDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Outfit',
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryCoral,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: primaryCoral,
      secondary: AppColors.lightCreamAccent,
      surface: cardDark,
      onSurface: textLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightCreamAccent,
        foregroundColor: textDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Outfit',
      ),
    ),
  );

  // Replacement for glassmorphism decoration per v3 specification: flat neutral card with soft shallow shadow
  static BoxDecoration softDecoration({
    Color? color,
    double borderRadius = 20.0,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: color ?? (isDark ? cardDark : cardLight),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.06),
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Deprecated shim method pointing to softDecoration to prevent broken compilation while migrating call sites
  static BoxDecoration glassmorphism({
    Color? color,
    double opacity = 1.0,
    double blur = 0,
  }) {
    return softDecoration(color: color);
  }

  // Hero Gradient for the single authoritative hero surface (HomeScreen Speedometer)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient coralHeroGradient = heroGradient;
  static const LinearGradient purpleGradient = heroGradient;

  // Input Decoration per v3 specification
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.black12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.darkAccent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
