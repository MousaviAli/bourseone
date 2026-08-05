import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

/// Drives light/dark mode. Because our custom widgets read AppColors.*
/// directly (not Theme.of(context)), this also flips AppColors.isDark as
/// a side effect - the actual visual switch happens when main.dart forces
/// a full subtree rebuild (via a Key tied to this state) so every widget's
/// build() re-reads the now-updated colors.
class ThemeModeController extends StateNotifier<bool> {
  ThemeModeController() : super(true) {
    _load();
  }

  static const _prefKey = 'is_dark_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? true;
    AppColors.isDark = isDark;
    state = isDark;
  }

  Future<void> setDark(bool isDark) async {
    AppColors.isDark = isDark;
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isDark);
  }

  Future<void> toggle() => setDark(!state);
}

final isDarkModeProvider = StateNotifierProvider<ThemeModeController, bool>((ref) {
  return ThemeModeController();
});
