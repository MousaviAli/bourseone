import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/crypto_asset.dart';
import '../../market/providers/market_ticker.dart';
import '../data/crypto_repository.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return AppConfig.useMockData ? MockCryptoRepository() : RemoteCryptoRepository();
});

final cryptoCoinsProvider = FutureProvider<List<CryptoAsset>>((ref) {
  ref.watch(marketTickerProvider); // re-fetch on every tick -> feels live
  return ref.watch(cryptoRepositoryProvider).getCoins();
});

final cryptoNewsProvider = FutureProvider<List<CryptoNewsItem>>((ref) {
  return ref.watch(cryptoRepositoryProvider).getNews();
});

final cryptoCoinDetailProvider = FutureProvider.family<CryptoAsset, String>((ref, slug) {
  ref.watch(marketTickerProvider);
  return ref.watch(cryptoRepositoryProvider).getCoinDetail(slug);
});
