import 'dart:math';
import '../../../models/stock_symbol.dart';
import 'market_repository.dart';

/// In-memory repository with realistically-shaped (but fabricated) data,
/// so the whole app runs and demos correctly before the backend/scraper
/// is deployed. Swap the provider in market_providers.dart to
/// RemoteMarketRepository once the backend is live - no UI code changes needed.
class MockMarketRepository implements MarketRepository {
  static final List<_SeedSymbol> _seed = [
    _SeedSymbol('فولاد', 'مبارکه اصفهان', 'فلزات اساسی', 6420),
    _SeedSymbol('فملی', 'ملی صنایع مس ایران', 'فلزات اساسی', 15870),
    _SeedSymbol('شپنا', 'پالایش نفت اصفهان', 'فرآورده نفتی', 9340),
    _SeedSymbol('خودرو', 'ایران خودرو', 'خودرو', 2180),
    _SeedSymbol('وبملت', 'بانک ملت', 'بانک', 4210),
    _SeedSymbol('شستا', 'سرمایه‌گذاری تامین اجتماعی', 'سرمایه‌گذاری', 1370),
    _SeedSymbol('فارس', 'صنایع پتروشیمی خلیج فارس', 'پتروشیمی', 11250),
    _SeedSymbol('صبا', 'سرمایه گذاری صبا تامین', 'سرمایه‌گذاری', 4680),
    _SeedSymbol('کچاد', 'معدنی و صنعتی چادرملو', 'فلزات اساسی', 8930),
    _SeedSymbol('شبندر', 'پالایش نفت بندرعباس', 'فرآورده نفتی', 12480),
    _SeedSymbol('رمپنا', 'گروه مپنا', 'ساخت تجهیزات', 20150),
    _SeedSymbol('وغدیر', 'سرمایه‌گذاری غدیر', 'سرمایه‌گذاری', 2760),
    _SeedSymbol('پارس', 'پتروشیمی پارس', 'پتروشیمی', 18900),
    _SeedSymbol('اخابر', 'مخابرات ایران', 'مخابرات', 3120),
    _SeedSymbol('حکشتی', 'کشتیرانی ج.ا.ایران', 'حمل و نقل', 5340),
  ];

  final Random _rnd = Random(42);
  late final List<StockSymbol> _symbols = _seed.map((s) {
    final changePct = (_rnd.nextDouble() * 10 - 5);
    return StockSymbol(
      symbol: s.symbol,
      isin: 'IRO1${s.symbol.hashCode.abs() % 100000}',
      companyName: s.companyName,
      industry: s.industry,
      lastPrice: s.basePrice.toDouble(),
      closingPrice: s.basePrice * (1 - changePct / 100),
      changePercent: double.parse(changePct.toStringAsFixed(2)),
      changeValue: double.parse((s.basePrice * changePct / 100).toStringAsFixed(0)),
      volume: 1000000 + _rnd.nextInt(50000000),
      marketCap: s.basePrice * (5e8 + _rnd.nextInt(500) * 1e6),
      pe: 4 + _rnd.nextDouble() * 12,
      eps: s.basePrice / (4 + _rnd.nextDouble() * 10),
      isMarketOpen: false,
    );
  }).toList();

  @override
  Future<List<StockSymbol>> getAllSymbols() async {
    await _delay();
    return _symbols;
  }

  @override
  Future<List<StockSymbol>> searchSymbols(String query) async {
    await _delay();
    final q = query.trim();
    if (q.isEmpty) return _symbols;
    return _symbols
        .where((s) =>
            s.symbol.contains(q) ||
            s.companyName.contains(q) ||
            s.industry.contains(q))
        .toList();
  }

  @override
  Future<StockSymbol> getSymbolDetail(String symbol) async {
    await _delay();
    return _symbols.firstWhere(
      (s) => s.symbol == symbol,
      orElse: () => _symbols.first,
    );
  }

  @override
  Future<List<PricePoint>> getPriceHistory(String symbol, {String range = '1M'}) async {
    await _delay();
    final days = switch (range) {
      '1W' => 7,
      '1M' => 30,
      '3M' => 90,
      '1Y' => 365,
      _ => 30,
    };
    final base = (_symbols.firstWhere((s) => s.symbol == symbol,
                orElse: () => _symbols.first))
            .lastPrice *
        0.85;
    double price = base;
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - i));
      final drift = (_rnd.nextDouble() - 0.48) * base * 0.02;
      final open = price;
      price = (price + drift).clamp(base * 0.5, base * 1.8);
      final high = max(open, price) + _rnd.nextDouble() * base * 0.01;
      final low = min(open, price) - _rnd.nextDouble() * base * 0.01;
      return PricePoint(
        date: date,
        open: open,
        high: high,
        low: low,
        close: price,
        volume: 500000 + _rnd.nextInt(20000000),
      );
    });
  }

  @override
  Future<List<MarketIndex>> getIndices() async {
    await _delay();
    final now = DateTime.now();
    List<PricePoint> genHistory(double base) {
      double v = base;
      return List.generate(30, (i) {
        v += (_rnd.nextDouble() - 0.47) * base * 0.01;
        return PricePoint(
          date: now.subtract(Duration(days: 30 - i)),
          open: v,
          high: v * 1.005,
          low: v * 0.995,
          close: v,
          volume: 0,
        );
      });
    }

    return [
      MarketIndex(
        key: 'tedpix',
        title: 'شاخص کل',
        value: 2154870,
        changePercent: 1.24,
        history: genHistory(2100000),
      ),
      MarketIndex(
        key: 'equalWeight',
        title: 'شاخص هم‌وزن',
        value: 741230,
        changePercent: -0.63,
        history: genHistory(730000),
      ),
      MarketIndex(
        key: 'industry:فلزات اساسی',
        title: 'شاخص فلزات اساسی',
        value: 512340,
        changePercent: 2.15,
        history: genHistory(500000),
      ),
      MarketIndex(
        key: 'industry:بانک',
        title: 'شاخص بانک',
        value: 198760,
        changePercent: -1.02,
        history: genHistory(195000),
      ),
    ];
  }

  @override
  Future<List<StockSymbol>> getTopGainers({int limit = 10}) async {
    await _delay();
    final sorted = [..._symbols]..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<StockSymbol>> getTopLosers({int limit = 10}) async {
    await _delay();
    final sorted = [..._symbols]..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<StockSymbol>> getMostTraded({int limit = 10}) async {
    await _delay();
    final sorted = [..._symbols]..sort((a, b) => b.volume.compareTo(a.volume));
    return sorted.take(limit).toList();
  }

  @override
  Future<Map<String, List<StockSymbol>>> getHeatmapByIndustry() async {
    await _delay();
    final Map<String, List<StockSymbol>> map = {};
    for (final s in _symbols) {
      map.putIfAbsent(s.industry, () => []).add(s);
    }
    return map;
  }

  @override
  Future<bool> isMarketOpen() async {
    await _delay();
    final now = DateTime.now();
    // TSE trading hours (Tehran time) ~ 09:00-12:30, Sat-Wed. Simplified check.
    return now.weekday != DateTime.thursday &&
        now.weekday != DateTime.friday &&
        now.hour >= 9 &&
        now.hour < 13;
  }

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 350));
}

class _SeedSymbol {
  final String symbol;
  final String companyName;
  final String industry;
  final int basePrice;
  _SeedSymbol(this.symbol, this.companyName, this.industry, this.basePrice);
}
