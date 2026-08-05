import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Single builder that reflects [AppColors.isDark] at call time.
  /// main.dart calls this for BOTH the `theme:` and `darkTheme:` slots
  /// (with themeMode forced) so there's only ever one ThemeData built per
  /// frame - avoids a light/dark construction race, since our custom
  /// widgets read AppColors.* directly rather than via Theme.of(context).
  static ThemeData build(Locale locale) {
    final isFa = locale.languageCode == 'fa';
    final isDark = AppColors.isDark;

    final baseTextTheme = isFa
        ? GoogleFonts.vazirmatnTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme)
        : GoogleFonts.interTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme);
    TextStyle fontStyle({FontWeight? weight, double? size}) => isFa
        ? GoogleFonts.vazirmatn(fontWeight: weight, fontSize: size)
        : GoogleFonts.inter(fontWeight: weight, fontSize: size);

    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: AppColors.neonGreen,
              secondary: AppColors.blue,
              tertiary: AppColors.gold,
              error: AppColors.red,
              surface: AppColors.surface,
            )
          : ColorScheme.light(
              primary: AppColors.neonGreen,
              secondary: AppColors.blue,
              tertiary: AppColors.gold,
              error: AppColors.red,
              surface: AppColors.surface,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: fontStyle(weight: FontWeight.w700, size: 18).copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.neonGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: fontStyle(weight: FontWeight.w700, size: 16),
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.divider,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
