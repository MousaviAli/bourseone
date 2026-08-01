import 'package:flutter/material.dart';

/// Central color palette for بورس تک (Boors Tech / Takvan Plus).
/// Dark fintech aesthetic inspired by TradingView / Bloomberg terminal style.
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color background = Color(0xFF08111F);
  static const Color surface = Color(0xFF0C1526);
  static const Color card = Color(0xFF131C31);
  static const Color cardElevated = Color(0xFF1A2440);
  static const Color divider = Color(0xFF223052);

  // Brand / semantic
  static const Color neonGreen = Color(0xFF00E676); // gains / buy
  static const Color red = Color(0xFFFF5252); // losses / sell
  static const Color gold = Color(0xFFFFC107); // highlight / premium
  static const Color blue = Color(0xFF29B6F6); // info / links / index

  // Text
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF9AA7C2);
  static const Color textMuted = Color(0xFF5C6987);

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

  static const LinearGradient glassOverlay = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns [neonGreen] for positive change, [red] for negative, [textMuted] for zero.
  static Color changeColor(num change) {
    if (change > 0) return neonGreen;
    if (change < 0) return red;
    return textMuted;
  }
}
