import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/market_stats.dart';
import 'market_ticker.dart';
import 'market_providers.dart';

/// Aggregate market-wide stats. Once the backend is live, replace this
/// with a call to GET /market/stats (add that endpoint to
/// takvan_plus_backend/routes/market.js following the same pattern as
/// the other /market/* routes).
final marketStatsProvider = FutureProvider<MarketStats>((ref) async {
  ref.watch(marketTickerProvider);
  final symbols = await ref.watch(marketRepositoryProvider).getAllSymbols();
  final rnd = Random();
  final positive = symbols.where((s) => s.changePercent > 0).length;
  final negative = symbols.where((s) => s.changePercent < 0).length;
  return MarketStats(
    valueTradedBillionToman: 90000 + rnd.nextInt(15000).toDouble(),
    volumeBillion: 10 + rnd.nextDouble() * 5,
    realMoneyInflowBillionToman: 800 + rnd.nextInt(800).toDouble(),
    positiveSymbolsCount: positive,
    negativeSymbolsCount: negative,
  );
});

/// Placeholder financial news feed. Wire to GET /news on your backend
/// (which can aggregate CODAL disclosures + TSETMC announcements) once
/// available.
final financialNewsProvider = FutureProvider<List<NewsItem>>((ref) async {
  ref.watch(marketTickerProvider);
  await Future.delayed(const Duration(milliseconds: 200));
  final now = DateTime.now();
  return [
    NewsItem(id: 'n1', title: 'انتشار گزارش فعالیت ماهانه فولاد مبارکه در کدال', source: 'کدال', publishedAt: now.subtract(const Duration(minutes: 12))),
    NewsItem(id: 'n2', title: 'رشد شاخص کل بورس تهران در پایان معاملات امروز', source: 'مدیریت فناوری بورس', publishedAt: now.subtract(const Duration(minutes: 38))),
    NewsItem(id: 'n3', title: 'افزایش نرخ خوراک پالایشگاه‌ها در بودجه سال آینده', source: 'سازمان بورس', publishedAt: now.subtract(const Duration(minutes: 74))),
    NewsItem(id: 'n4', title: 'ورود پول حقیقی به گروه خودرویی برای سومین روز متوالی', source: 'مدیریت فناوری بورس', publishedAt: now.subtract(const Duration(minutes: 96))),
  ];
});
