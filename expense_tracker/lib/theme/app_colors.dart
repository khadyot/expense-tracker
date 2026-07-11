import 'package:flutter/material.dart';

class AppColors {
  // Base HSL Colors per v3 Warm Cream & Coral System
  static const HSLColor backgroundLightHsl =
      HSLColor.fromAHSL(1.0, 30.0, 0.25, 0.97); // #F8F6F0
  static const HSLColor backgroundDarkHsl =
      HSLColor.fromAHSL(1.0, 20.0, 0.15, 0.10); // #1C1917

  // Hero Gradient (warm orange-to-coral radial/diagonal gradient)
  static const Color heroGradientStart =
      Color(0xFFF96326); // roughly hsl(20, 85%, 55%)
  static const Color heroGradientEnd =
      Color(0xFFE63920); // roughly hsl(5, 80%, 50%)

  // High-contrast accent: near-black
  static const Color darkAccent =
      Color(0xFF211E1C); // roughly hsl(20, 10%, 12%)
  static const Color lightCreamAccent = Color(0xFFFDFCF7);

  // Category Accent Dot Palette (4-5 distinct saturated hues, documented mapping)
  // Groceries -> Pink
  static const Color categoryGroceries = Color(0xFFEC4899);
  // Travel -> Amber
  static const Color categoryTravel = Color(0xFFF59E0B);
  // Car -> Indigo
  static const Color categoryCar = Color(0xFF6366F1);
  // Home -> Green
  static const Color categoryHome = Color(0xFF10B981);
  // Entertainment / General / Other -> Teal
  static const Color categoryGeneral = Color(0xFF14B8A6);

  static Color getCategoryDotColor(String? categoryName) {
    if (categoryName == null) return categoryGeneral;
    final lower = categoryName.toLowerCase();
    if (lower.contains('grocer') ||
        lower.contains('food') ||
        lower.contains('dining') ||
        lower.contains('restaurant')) {
      return categoryGroceries;
    } else if (lower.contains('travel') ||
        lower.contains('flight') ||
        lower.contains('hotel') ||
        lower.contains('transit')) {
      return categoryTravel;
    } else if (lower.contains('car') ||
        lower.contains('auto') ||
        lower.contains('gas') ||
        lower.contains('shell')) {
      return categoryCar;
    } else if (lower.contains('home') ||
        lower.contains('rent') ||
        lower.contains('utilit') ||
        lower.contains('bill')) {
      return categoryHome;
    }
    return categoryGeneral;
  }

  // Semantic Colors (flat, non-glass)
  static const HSLColor successHsl = HSLColor.fromAHSL(1.0, 145.0, 0.60, 0.45);
  static const HSLColor warningHsl = HSLColor.fromAHSL(1.0, 40.0, 0.95, 0.55);
  static const HSLColor dangerHsl = HSLColor.fromAHSL(1.0, 0.0, 0.80, 0.55);
  static const HSLColor infoHsl = HSLColor.fromAHSL(1.0, 210.0, 0.85, 0.55);

  // Flat Opaque Semantic Borders & Surfaces
  static Color get warningBorder => warningHsl.withLightness(0.60).toColor();
  static Color get warningSurfaceDark => const Color(0xFF3B2D1D);
  static Color get warningSurfaceLight => const Color(0xFFFEF9C3);

  static Color get successBorder => successHsl.withLightness(0.50).toColor();
  static Color get successSurface => const Color(0xFFD1FAE5);

  static Color get dangerBorder => dangerHsl.withLightness(0.60).toColor();
  static Color get dangerSurfaceDark => const Color(0xFF3F1D1D);
  static Color get dangerSurfaceLight => const Color(0xFFFEE2E2);

  static Color get infoBorder => infoHsl.withLightness(0.60).toColor();
  static Color get infoSurfaceDark => const Color(0xFF1E293B);
  static Color get infoSurfaceLight => const Color(0xFFDBEAFE);
}
