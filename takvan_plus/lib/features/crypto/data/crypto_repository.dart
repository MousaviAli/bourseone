import 'dart:math';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../models/crypto_asset.dart';

abstract class CryptoRepository {
  Future<List<CryptoAsset>> getCoins();
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
  Future<List<CryptoNewsItem>> getNews() async {
    final res = await _dio.get('/crypto/news');
    return (res.data as List).map((e) => CryptoNewsItem.fromJson(e)).toList();
  }
}

/// Realistic placeholder data so the Crypto tab works immediately, before
/// the backend scraper is deployed.
class MockCryptoRepository implements CryptoRepository {
  final Random _rnd = Random(7);
  static const _seed = [
    ('bitcoin', 'BTC', 'بیت‌کوین', 64000.0),
    ('ethereum', 'ETH', 'اتریوم', 3400.0),
    ('tether', 'USDT', 'تتر', 1.0),
    ('binancecoin', 'BNB', 'بایننس کوین', 580.0),
    ('solana', 'SOL', 'سولانا', 140.0),
    ('ripple', 'XRP', 'ریپل', 0.52),
    ('dogecoin', 'DOGE', 'دوج‌کوین', 0.12),
    ('toncoin', 'TON', 'تون‌کوین', 5.8),
  ];

  @override
  Future<List<CryptoAsset>> getCoins() async {
    await Future.delayed(const Duration(milliseconds: 300));
    const tomanUsdRate = 590000; // illustrative only - wire real FX from backend
    return _seed.map((c) {
      final change = (_rnd.nextDouble() * 12 - 6);
      return CryptoAsset(
        slug: c.$1,
        symbol: c.$2,
        name: c.$3,
        priceUsd: c.$4,
        priceToman: c.$4 * tomanUsdRate,
        changePercent24h: double.parse(change.toStringAsFixed(2)),
        marketCapUsd: c.$4 * (1e6 + _rnd.nextInt(500)) * 1000,
        volume24hUsd: c.$4 * (1e5 + _rnd.nextInt(200)) * 1000,
      );
    }).toList();
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
