import 'package:flutter/material.dart';

class AppColors {
  // Base HSL Colors per design-aesthetics skill
  static const HSLColor primaryHsl =
      HSLColor.fromAHSL(1.0, 255.0, 0.88, 0.66); // #7C5BF6 equivalent
  static const HSLColor successHsl = HSLColor.fromAHSL(
      1.0, 145.0, 0.60, 0.45); // Income / under-budget / high confidence
  static const HSLColor warningHsl = HSLColor.fromAHSL(
      1.0, 40.0, 0.95, 0.55); // Near-limit / uncertain field review
  static const HSLColor dangerHsl =
      HSLColor.fromAHSL(1.0, 0.0, 0.80, 0.55); // Over-budget / error

  // Generated Lightness Variants
  static Color get warningBorder => warningHsl.withLightness(0.50).toColor();
  static Color get warningSurfaceDark =>
      warningHsl.withLightness(0.20).toColor().withValues(alpha: 0.15);
  static Color get warningSurfaceLight =>
      warningHsl.withLightness(0.90).toColor().withValues(alpha: 0.35);

  static Color get successBorder => successHsl.withLightness(0.45).toColor();
  static Color get successSurface =>
      successHsl.withLightness(0.45).toColor().withValues(alpha: 0.12);

  static Color get dangerBorder => dangerHsl.withLightness(0.55).toColor();
  static Color get dangerSurfaceDark =>
      dangerHsl.withLightness(0.25).toColor().withValues(alpha: 0.15);
  static Color get dangerSurfaceLight =>
      dangerHsl.withLightness(0.90).toColor().withValues(alpha: 0.35);

  static const HSLColor infoHsl =
      HSLColor.fromAHSL(1.0, 210.0, 0.85, 0.55); // Informational / platform notice
  static Color get infoBorder => infoHsl.withLightness(0.55).toColor();
  static Color get infoSurfaceDark =>
      infoHsl.withLightness(0.25).toColor().withValues(alpha: 0.15);
  static Color get infoSurfaceLight =>
      infoHsl.withLightness(0.90).toColor().withValues(alpha: 0.35);
}
