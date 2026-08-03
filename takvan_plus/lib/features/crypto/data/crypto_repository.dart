import 'dart:math';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../models/crypto_asset.dart';

abstract class CryptoRepository {
  Future<List<CryptoAsset>> getCoins();
  Future<CryptoAsset> getCoinDetail(String slug);
  Future<List<CryptoNewsItem>> getNews();
}

/// Calls YOUR backend's /crypto/* endpoints, which scrape+cache arzdigital.com
/// (see takvan_plus_backend/services/arzdigital.js + routes/crypto.js).
/// The app never scrapes arzdigital.com directly.
class RemoteCryptoRepository implements CryptoRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<CryptoAsset>> getCoins() async {
    final res = await _dio.get('/crypto/coins');
    return (res.data as List).map((e) => CryptoAsset.fromJson(e)).toList();
  }

  @override
  Future<CryptoAsset> getCoinDetail(String slug) async {
    final res = await _dio.get('/crypto/coins/$slug');
    return CryptoAsset.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<CryptoNewsItem>> getNews() async {
    final res = await _dio.get('/crypto/news');
    return (res.data as List).map((e) => CryptoNewsItem.fromJson(e)).toList();
  }
}

/// Realistic placeholder data so the Crypto tab works immediately, before
/// the backend scraper is deployed. Prices drift a little on every call to
/// simulate live movement during on-device testing.
class MockCryptoRepository implements CryptoRepository {
  final Random _rnd = Random();
  static const _seed = [
    ('bitcoin', 'BTC', 'بیت‌کوین', 64000.0),
    ('ethereum', 'ETH', 'اتریوم', 3400.0),
    ('tether', 'USDT', 'تتر', 1.0),
    ('binancecoin', 'BNB', 'بایننس کوین', 580.0),
    ('solana', 'SOL', 'سولانا', 140.0),
    ('ripple', 'XRP', 'ریپل', 0.52),
    ('dogecoin', 'DOGE', 'دوج‌کوین', 0.12),
    ('toncoin', 'TON', 'تون‌کوین', 5.8),
    ('cardano', 'ADA', 'کاردانو', 0.44),
    ('tron', 'TRX', 'ترون', 0.13),
  ];

  static const _tomanUsdRate = 590000; // illustrative only - wire real FX from backend
  late final Map<String, double> _livePrices = {
    for (final c in _seed) c.$1: c.$4,
  };

  List<CryptoAsset> _snapshot() {
    return _seed.map((c) {
      final base = _livePrices[c.$1]!;
      final drift = (_rnd.nextDouble() - 0.5) * base * 0.01; // ~±0.5% per tick
      final newPrice = (base + drift).clamp(base * 0.5, base * 2.0);
      _livePrices[c.$1] = newPrice;
      final change = ((newPrice - c.$4) / c.$4 * 100);
      return CryptoAsset(
        slug: c.$1,
        symbol: c.$2,
        name: c.$3,
        priceUsd: newPrice,
        priceToman: newPrice * _tomanUsdRate,
        changePercent24h: double.parse(change.toStringAsFixed(2)),
        marketCapUsd: newPrice * (1e6 + _rnd.nextInt(500)) * 1000,
        volume24hUsd: newPrice * (1e5 + _rnd.nextInt(200)) * 1000,
      );
    }).toList();
  }

  @override
  Future<List<CryptoAsset>> getCoins() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _snapshot();
  }

  @override
  Future<CryptoAsset> getCoinDetail(String slug) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _snapshot().firstWhere((c) => c.slug == slug, orElse: () => _snapshot().first);
  }

  @override
  Future<List<CryptoNewsItem>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      CryptoNewsItem(title: 'تحلیل هفتگی بازار رمزارزها', url: 'https://arzdigital.com'),
      CryptoNewsItem(title: 'روند قیمت بیت‌کوین در هفته جاری', url: 'https://arzdigital.com'),
    ];
  }
}
