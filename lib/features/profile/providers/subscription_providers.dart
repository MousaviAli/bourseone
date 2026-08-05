import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../authentication/providers/auth_providers.dart';

/// Enforces: free users can open full details for at most
/// [AppConfig.freeSymbolDetailLimit] distinct symbols (ever, per device).
/// Premium users (checked via authControllerProvider's user.isPremium)
/// bypass the limit entirely.
class ViewedSymbolsController extends StateNotifier<Set<String>> {
  ViewedSymbolsController() : super({}) {
    _load();
  }

  static const _prefKey = 'viewed_symbols';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_prefKey) ?? []).toSet();
  }

  Future<void> markViewed(String symbol) async {
    if (state.contains(symbol)) return;
    state = {...state, symbol};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, state.toList());
  }
}

final viewedSymbolsProvider =
    StateNotifierProvider<ViewedSymbolsController, Set<String>>((ref) {
  return ViewedSymbolsController();
});

/// True if the user may view *another* symbol's full detail (i.e. either
/// they've already unlocked it, they're premium, or they're under quota).
final canViewSymbolProvider = Provider.family<bool, String>((ref, symbol) {
  final auth = ref.watch(authControllerProvider);
  if (auth.user?.isPremium == true) return true;

  final viewed = ref.watch(viewedSymbolsProvider);
  if (viewed.contains(symbol)) return true;
  return viewed.length < AppConfig.freeSymbolDetailLimit;
});
