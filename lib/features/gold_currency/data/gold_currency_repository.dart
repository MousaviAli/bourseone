import 'dart:math';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../models/gold_currency_asset.dart';

abstract class GoldCurrencyRepository {
  Future<List<GoldCurrencyAsset>> getAll();
}

/// Calls YOUR backend's /gold-currency endpoint, which scrapes+caches
/// tgju.org (see takvan_plus_backend/services/tgju.js + routes/gold-currency.js).
/// The app never scrapes tgju.org directly.
class RemoteGoldCurrencyRepository implements GoldCurrencyRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<GoldCurrencyAsset>> getAll() async {
    final res = await _dio.get('/gold-currency');
    return (res.data as List).map((e) => GoldCurrencyAsset.fromJson(e)).toList();
  }
}

/// Realistic placeholder data covering both domestic (Iranian coins/gold/
/// currency) and international (world gold, oil, major FX) markets, so the
/// section works immediately before the tgju.org scraper is deployed.
/// Prices drift a little on every call to feel live.
class MockGoldCurrencyRepository implements GoldCurrencyRepository {
  final Random _rnd = Random();

  static const _seed = [
    // domestic gold/coins (تومان)
    ('emami', 'سکه امامی', GCCategory.domestic, GCType.gold, 42500000.0, 'تومان'),
    ('half-coin', 'نیم سکه', GCCategory.domestic, GCType.gold, 22800000.0, 'تومان'),
    ('quarter-coin', 'ربع سکه', GCCategory.domestic, GCType.gold, 13200000.0, 'تومان'),
    ('gram-coin', 'سکه گرمی', GCCategory.domestic, GCType.gold, 8100000.0, 'تومان'),
    ('gold-18k', 'طلای ۱۸ عیار (گرم)', GCCategory.domestic, GCType.gold, 4150000.0, 'تومان'),
    // domestic currency (تومان)
    ('usd', 'دلار آمریکا', GCCategory.domestic, GCType.currency, 68200.0, 'تومان'),
    ('eur', 'یورو', GCCategory.domestic, GCType.currency, 74500.0, 'تومان'),
    ('aed', 'درهم امارات', GCCategory.domestic, GCType.currency, 18600.0, 'تومان'),
    ('gbp', 'پوند انگلیس', GCCategory.domestic, GCType.currency, 86900.0, 'تومان'),
    ('try', 'لیر ترکیه', GCCategory.domestic, GCType.currency, 2050.0, 'تومان'),
    // international (دلار / جهانی)
    ('xau-ounce', 'اونس جهانی طلا', GCCategory.international, GCType.gold, 2385.0, 'دلار'),
    ('xag-ounce', 'اونس نقره', GCCategory.international, GCType.gold, 28.4, 'دلار'),
    ('brent', 'نفت برنت', GCCategory.international, GCType.commodity, 82.3, 'دلار'),
    ('wti', 'نفت وست‌تگزاس', GCCategory.international, GCType.commodity, 78.1, 'دلار'),
    ('dxy', 'شاخص دلار (DXY)', GCCategory.international, GCType.currency, 104.2, 'واحد'),
    ('eur-usd', 'یورو / دلار', GCCategory.international, GCType.currency, 1.087, 'دلار'),
  ];

  @override
  Future<List<GoldCurrencyAsset>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 280));
    return _seed.map((s) {
      final drift = (_rnd.nextDouble() - 0.5) * 1.6;
      return GoldCurrencyAsset(
        key: s.$1,
        name: s.$2,
        category: s.$3,
        type: s.$4,
        price: s.$5 * (1 + drift / 100),
        unit: s.$6,
        changePercent: double.parse(drift.toStringAsFixed(2)),
      );
    }).toList();
  }
}
