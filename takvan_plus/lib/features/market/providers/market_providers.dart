import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/stock_symbol.dart';
import '../data/market_repository.dart';
import '../data/mock_market_repository.dart';
import '../data/remote_market_repository.dart';

/// Single place to flip mock <-> real backend.
/// Once takvan_plus_backend is deployed, set USE_MOCK_DATA=false
/// (see AppConfig) and everything downstream keeps working unchanged.
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return AppConfig.useMockData ? MockMarketRepository() : RemoteMarketRepository();
});

final marketOpenProvider = FutureProvider<bool>((ref) {
  return ref.watch(marketRepositoryProvider).isMarketOpen();
});

final allSymbolsProvider = FutureProvider<List<StockSymbol>>((ref) {
  return ref.watch(marketRepositoryProvider).getAllSymbols();
});

final indicesProvider = FutureProvider<List<MarketIndex>>((ref) {
  return ref.watch(marketRepositoryProvider).getIndices();
});

final topGainersProvider = FutureProvider<List<StockSymbol>>((ref) {
  return ref.watch(marketRepositoryProvider).getTopGainers();
});

final topLosersProvider = FutureProvider<List<StockSymbol>>((ref) {
  return ref.watch(marketRepositoryProvider).getTopLosers();
});

final mostTradedProvider = FutureProvider<List<StockSymbol>>((ref) {
  return ref.watch(marketRepositoryProvider).getMostTraded();
});

final heatmapProvider = FutureProvider<Map<String, List<StockSymbol>>>((ref) {
  return ref.watch(marketRepositoryProvider).getHeatmapByIndustry();
});

final symbolSearchQueryProvider = StateProvider<String>((ref) => '');

final symbolSearchResultsProvider = FutureProvider<List<StockSymbol>>((ref) {
  final query = ref.watch(symbolSearchQueryProvider);
  return ref.watch(marketRepositoryProvider).searchSymbols(query);
});

final symbolDetailProvider =
    FutureProvider.family<StockSymbol, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getSymbolDetail(symbol);
});

final priceHistoryRangeProvider = StateProvider<String>((ref) => '1M');

final priceHistoryProvider =
    FutureProvider.family<List<PricePoint>, String>((ref, symbol) {
  final range = ref.watch(priceHistoryRangeProvider);
  return ref.watch(marketRepositoryProvider).getPriceHistory(symbol, range: range);
});
