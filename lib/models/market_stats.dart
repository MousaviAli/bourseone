class MarketStats {
  final double valueTradedBillionToman;
  final double volumeBillion;
  final double realMoneyInflowBillionToman;
  final int positiveSymbolsCount;
  final int negativeSymbolsCount;

  const MarketStats({
    required this.valueTradedBillionToman,
    required this.volumeBillion,
    required this.realMoneyInflowBillionToman,
    required this.positiveSymbolsCount,
    required this.negativeSymbolsCount,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String source;
  final DateTime publishedAt;

  const NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.publishedAt,
  });

  String get minutesAgoLabel {
    final diff = DateTime.now().difference(publishedAt).inMinutes;
    return '$diff′';
  }
}
