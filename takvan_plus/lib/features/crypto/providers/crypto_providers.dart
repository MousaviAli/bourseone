import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/crypto_asset.dart';
import '../data/crypto_repository.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return AppConfig.useMockData ? MockCryptoRepository() : RemoteCryptoRepository();
});

final cryptoCoinsProvider = FutureProvider<List<CryptoAsset>>((ref) {
  return ref.watch(cryptoRepositoryProvider).getCoins();
});

final cryptoNewsProvider = FutureProvider<List<CryptoNewsItem>>((ref) {
  return ref.watch(cryptoRepositoryProvider).getNews();
});
