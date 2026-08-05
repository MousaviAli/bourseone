enum AlertDirection { above, below }

class PriceAlert {
  final String id;
  final String symbol;
  final bool isCrypto;
  final double targetPrice;
  final AlertDirection direction;
  final bool triggered;
  final DateTime createdAt;

  const PriceAlert({
    required this.id,
    required this.symbol,
    required this.isCrypto,
    required this.targetPrice,
    required this.direction,
    this.triggered = false,
    required this.createdAt,
  });

  PriceAlert copyWith({bool? triggered}) => PriceAlert(
        id: id,
        symbol: symbol,
        isCrypto: isCrypto,
        targetPrice: targetPrice,
        direction: direction,
        triggered: triggered ?? this.triggered,
        createdAt: createdAt,
      );
}
