import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/watchlist.dart';

/// Manages the user's watchlists (دیده‌بان‌ها).
/// Backed locally for now; wire to `/watchlists` REST endpoints on your
/// backend for cross-device sync (see takvan_plus_backend/routes/watchlists.js).
class WatchlistController extends StateNotifier<List<Watchlist>> {
  WatchlistController()
      : super([
          Watchlist(
            id: 'default',
            name: 'دیده‌بان من',
            entries: [
              WatchlistEntry(symbol: 'فولاد', addedAt: DateTime.now()),
              WatchlistEntry(symbol: 'شپنا', addedAt: DateTime.now()),
            ],
          ),
        ]);

  void createWatchlist(String name) {
    state = [
      ...state,
      Watchlist(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name),
    ];
  }

  void renameWatchlist(String watchlistId, String newName) {
    state = state.map((w) => w.id == watchlistId ? w.copyWith(name: newName) : w).toList();
  }

  void deleteWatchlist(String watchlistId) {
    if (state.length <= 1) return; // always keep at least one watchlist
    state = state.where((w) => w.id != watchlistId).toList();
  }

  void addSymbol(String watchlistId, String symbol) {
    state = state.map((w) {
      if (w.id != watchlistId) return w;
      if (w.entries.any((e) => e.symbol == symbol)) return w;
      return w.copyWith(entries: [
        ...w.entries,
        WatchlistEntry(symbol: symbol, addedAt: DateTime.now()),
      ]);
    }).toList();
  }

  void removeSymbol(String watchlistId, String symbol) {
    state = state.map((w) {
      if (w.id != watchlistId) return w;
      return w.copyWith(entries: w.entries.where((e) => e.symbol != symbol).toList());
    }).toList();
  }

  /// User optionally logs a manual buy/sell lot against a watchlist entry,
  /// which turns that row into an (optional) P/L-tracked holding.
  void addLot(String watchlistId, String symbol, HoldingLot lot) {
    state = state.map((w) {
      if (w.id != watchlistId) return w;
      final entries = w.entries.map((e) {
        if (e.symbol != symbol) return e;
        return WatchlistEntry(
          symbol: e.symbol,
          addedAt: e.addedAt,
          lots: [...e.lots, lot],
        );
      }).toList();
      return w.copyWith(entries: entries);
    }).toList();
  }
}

final watchlistControllerProvider =
    StateNotifierProvider<WatchlistController, List<Watchlist>>((ref) {
  return WatchlistController();
});

final selectedWatchlistIdProvider = StateProvider<String>((ref) => 'default');
