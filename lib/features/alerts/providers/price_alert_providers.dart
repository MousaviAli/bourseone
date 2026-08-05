import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/price_alert.dart';
import '../../crypto/providers/crypto_providers.dart';
import '../../market/providers/market_providers.dart';

class PriceAlertController extends StateNotifier<List<PriceAlert>> {
  PriceAlertController() : super([]);

  void add(PriceAlert alert) {
    state = [...state, alert];
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void markTriggered(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(triggered: true) else a,
    ];
  }
}

final priceAlertControllerProvider =
    StateNotifierProvider<PriceAlertController, List<PriceAlert>>((ref) {
  return PriceAlertController();
});

/// Checks every active (untriggered) alert against the latest prices on
/// every market tick, and returns any that just crossed their threshold
/// this tick - a listener (see RootShell) shows an in-app banner for
/// these and marks them triggered so they don't fire repeatedly.
///
/// This is a local, in-app-only alert (checked while the app is open).
/// For real push notifications while the app is closed, you'd move this
/// check server-side (a cron job comparing live TSETMC/arzdigital prices
/// against stored alerts) and send via FCM - a natural next step once
/// the backend is deployed.
final triggeredAlertsProvider = FutureProvider<List<PriceAlert>>((ref) async {
  final alerts = ref.watch(priceAlertControllerProvider).where((a) => !a.triggered).toList();
  if (alerts.isEmpty) return [];

  final stocks = await ref.watch(allSymbolsProvider.future);
  final coins = await ref.watch(cryptoCoinsProvider.future);

  final stockPrice = {for (final s in stocks) s.symbol: s.lastPrice};
  final coinPrice = {for (final c in coins) c.symbol: c.priceUsd};

  final justTriggered = <PriceAlert>[];
  for (final alert in alerts) {
    final price = alert.isCrypto ? coinPrice[alert.symbol] : stockPrice[alert.symbol];
    if (price == null) continue;
    final crossed = alert.direction == AlertDirection.above
        ? price >= alert.targetPrice
        : price <= alert.targetPrice;
    if (crossed) justTriggered.add(alert);
  }
  return justTriggered;
});
