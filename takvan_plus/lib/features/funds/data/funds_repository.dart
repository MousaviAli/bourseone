import 'package:dio/dio.dart';
import 'dart:math';
import '../../../core/network/api_client.dart';
import '../../../models/investment_fund.dart';

abstract class FundsRepository {
  Future<List<InvestmentFund>> getFunds();
}

/// Calls YOUR backend's /funds endpoint, which scrapes+caches fipiran.ir
/// (فیپ ایران) - see takvan_plus_backend/services (add a fipiran.js
/// scraper following the same pattern as services/rahavard365.js when
/// you build this out server-side).
class RemoteFundsRepository implements FundsRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<InvestmentFund>> getFunds() async {
    final res = await _dio.get('/funds');
    return (res.data as List).map((f) {
      final m = f as Map<String, dynamic>;
      return InvestmentFund(
        slug: m['slug'],
        name: m['name'],
        type: FundType.values.firstWhere((t) => t.name == m['type'], orElse: () => FundType.mixed),
        manager: m['manager'],
        nav: (m['nav'] as num).toDouble(),
        dailyChangePercent: (m['dailyChangePercent'] as num).toDouble(),
        aumBillionToman: (m['aumBillionToman'] as num).toDouble(),
        oneYearReturnPercent: (m['oneYearReturnPercent'] as num).toDouble(),
      );
    }).toList();
  }
}

/// Placeholder catalog covering the main fund categories, so the section
/// is fully browsable/comparable before the real fipiran.ir scraper exists.
class MockFundsRepository implements FundsRepository {
  final Random _rnd = Random();

  @override
  Future<List<InvestmentFund>> getFunds() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final seed = [
      ('kian-fixed', 'صندوق درآمد ثابت کیان', FundType.fixedIncome, 'تامین سرمایه کیان', 12500.0, 21.4),
      ('atieh-equity', 'صندوق سهامی آتیه ملت', FundType.equity, 'کارگزاری آتیه ملت', 38200.0, 34.8),
      ('mixed-pioneer', 'صندوق مختلط پیشرو', FundType.mixed, 'تامین سرمایه نوین', 21400.0, 27.1),
      ('index-hamrah', 'صندوق شاخصی هم‌راه', FundType.indexTracker, 'کارگزاری آگاه', 15800.0, 25.6),
      ('gold-lotus', 'صندوق طلای لوتوس', FundType.gold, 'کارگزاری بانک اقتصاد نوین', 9600.0, 18.9),
      ('venture-fanavaran', 'صندوق جسورانه فناوران', FundType.venture, 'تامین سرمایه امید', 47000.0, 41.2),
      ('novin-fixed', 'صندوق درآمد ثابت نوین', FundType.fixedIncome, 'تامین سرمایه نوین', 11800.0, 20.7),
      ('agah-equity', 'صندوق سهامی آگاه', FundType.equity, 'کارگزاری آگاه', 29500.0, 30.3),
    ];
    return seed.map((s) {
      final drift = (_rnd.nextDouble() - 0.5) * 1.2;
      return InvestmentFund(
        slug: s.$1,
        name: s.$2,
        type: s.$3,
        manager: s.$4,
        nav: s.$5,
        dailyChangePercent: double.parse(drift.toStringAsFixed(2)),
        aumBillionToman: 500 + _rnd.nextInt(9500),
        oneYearReturnPercent: s.$6,
      );
    }).toList();
  }
}
