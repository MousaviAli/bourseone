enum FundType { fixedIncome, equity, mixed, indexTracker, gold, venture }

extension FundTypeLabel on FundType {
  String get labelFa => switch (this) {
        FundType.fixedIncome => 'درآمد ثابت',
        FundType.equity => 'سهامی',
        FundType.mixed => 'مختلط',
        FundType.indexTracker => 'شاخصی',
        FundType.gold => 'طلا',
        FundType.venture => 'جسورانه',
      };
}

class InvestmentFund {
  final String slug;
  final String name;
  final FundType type;
  final String manager;
  final double nav; // net asset value per unit (تومان)
  final double dailyChangePercent;
  final double aumBillionToman; // assets under management
  final double oneYearReturnPercent;

  const InvestmentFund({
    required this.slug,
    required this.name,
    required this.type,
    required this.manager,
    required this.nav,
    required this.dailyChangePercent,
    required this.aumBillionToman,
    required this.oneYearReturnPercent,
  });
}
