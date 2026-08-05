class StockSymbol {
  final String symbol; // e.g. "فولاد"
  final String isin; // TSETMC instrument ID
  final String companyName;
  final String industry;
  final double lastPrice;
  final double closingPrice;
  final double changePercent;
  final double changeValue;
  final int volume;
  final double marketCap;
  final double? pe;
  final double? eps;
  final String? logoUrl;
  final bool isMarketOpen;

  const StockSymbol({
    required this.symbol,
    required this.isin,
    required this.companyName,
    required this.industry,
    required this.lastPrice,
    required this.closingPrice,
    required this.changePercent,
    required this.changeValue,
    required this.volume,
    required this.marketCap,
    this.pe,
    this.eps,
    this.logoUrl,
    this.isMarketOpen = false,
  });

  factory StockSymbol.fromJson(Map<String, dynamic> json) {
    return StockSymbol(
      symbol: json['symbol'] as String,
      isin: json['isin'] as String,
      companyName: json['companyName'] as String,
      industry: json['industry'] as String,
      lastPrice: (json['lastPrice'] as num).toDouble(),
      closingPrice: (json['closingPrice'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      changeValue: (json['changeValue'] as num).toDouble(),
      volume: json['volume'] as int,
      marketCap: (json['marketCap'] as num).toDouble(),
      pe: (json['pe'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      logoUrl: json['logoUrl'] as String?,
      isMarketOpen: json['isMarketOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'isin': isin,
        'companyName': companyName,
        'industry': industry,
        'lastPrice': lastPrice,
        'closingPrice': closingPrice,
        'changePercent': changePercent,
        'changeValue': changeValue,
        'volume': volume,
        'marketCap': marketCap,
        'pe': pe,
        'eps': eps,
        'logoUrl': logoUrl,
        'isMarketOpen': isMarketOpen,
      };
}

class PricePoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const PricePoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
        date: DateTime.parse(json['date'] as String),
        open: (json['open'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
        low: (json['low'] as num).toDouble(),
        close: (json['close'] as num).toDouble(),
        volume: json['volume'] as int,
      );
}

class MarketIndex {
  final String key; // tedpix | equalWeight | industry:<name>
  final String title;
  final double value;
  final double changePercent;
  final List<PricePoint> history;

  const MarketIndex({
    required this.key,
    required this.title,
    required this.value,
    required this.changePercent,
    this.history = const [],
  });
}
