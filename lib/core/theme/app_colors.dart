import 'package:flutter/material.dart';

/// Central color palette for ایزی‌استاک (EasyStock).
/// Supports both a dark fintech look and a light look - toggle [isDark]
/// (driven by ThemeModeController) and every AppColors.* getter updates.
/// Widgets read AppColors.xxx directly (not Theme.of(context)), so the
/// whole app repaints correctly as long as the widget tree rebuilds when
/// isDark changes (main.dart forces that via a Key on MaterialApp).
class AppColors {
  AppColors._();

  static bool isDark = true;

  // Base surfaces
  static Color get background => isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FA);
  static Color get surface => isDark ? const Color(0xFF0C1526) : const Color(0xFFFFFFFF);
  static Color get card => isDark ? const Color(0xFF131C31) : const Color(0xFFFFFFFF);
  static Color get cardElevated => isDark ? const Color(0xFF1A2440) : const Color(0xFFF0F2F6);
  static Color get divider => isDark ? const Color(0xFF223052) : const Color(0xFFE2E6ED);

  // Brand / semantic (kept consistent across themes for brand recognition)
  static const Color neonGreen = Color(0xFF00C767); // gains / buy
  static const Color red = Color(0xFFE8453C); // losses / sell
  static const Color gold = Color(0xFFC98A0A); // highlight / premium
  static const Color blue = Color(0xFF1E88C7); // info / links / index

  // Text
  static Color get textPrimary => isDark ? const Color(0xFFF5F7FA) : const Color(0xFF101828);
  static Color get textSecondary => isDark ? const Color(0xFF9AA7C2) : const Color(0xFF5B6472);
  static Color get textMuted => isDark ? const Color(0xFF5C6987) : const Color(0xFF94A0B2);

  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF29B6F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get glassOverlay => isDark
      ? const LinearGradient(
          colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  /// Slightly brighter neon-green tuned for dark backgrounds only, used
  /// where the plain [neonGreen] would be too muted against pure black
  /// (kept for backward-compat call sites).
  static Color get neonGreenBright => isDark ? const Color(0xFF00E676) : neonGreen;

  /// Returns [neonGreen] for positive change, [red] for negative, [textMuted] for zero.
  static Color changeColor(num change) {
    if (change > 0) return neonGreen;
    if (change < 0) return red;
    return textMuted;
  }
}
