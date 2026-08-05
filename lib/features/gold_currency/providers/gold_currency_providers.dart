import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/gold_currency_asset.dart';
import '../../market/providers/market_ticker.dart';
import '../data/gold_currency_repository.dart';

final goldCurrencyRepositoryProvider = Provider<GoldCurrencyRepository>((ref) {
  return AppConfig.useMockData ? MockGoldCurrencyRepository() : RemoteGoldCurrencyRepository();
});

final goldCurrencyProvider = FutureProvider<List<GoldCurrencyAsset>>((ref) {
  ref.watch(marketTickerProvider); // re-fetch periodically -> feels live
  return ref.watch(goldCurrencyRepositoryProvider).getAll();
});

final goldCurrencyCategoryFilterProvider = StateProvider<GCCategory?>((ref) => null);
final goldCurrencyTypeFilterProvider = StateProvider<GCType?>((ref) => null);
