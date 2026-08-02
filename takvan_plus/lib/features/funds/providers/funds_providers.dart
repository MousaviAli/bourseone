import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/investment_fund.dart';
import '../data/funds_repository.dart';

final fundsRepositoryProvider = Provider<FundsRepository>((ref) {
  return AppConfig.useMockData ? MockFundsRepository() : RemoteFundsRepository();
});

final fundsProvider = FutureProvider<List<InvestmentFund>>((ref) {
  return ref.watch(fundsRepositoryProvider).getFunds();
});

final fundTypeFilterProvider = StateProvider<FundType?>((ref) => null);
