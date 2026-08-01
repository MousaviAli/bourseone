/// یک ردیف در دیده‌بان: فقط نماد (بدون هیچ اطلاعات مالکیتی)
/// یا نماد + سابقه خرید/فروش که کاربر خودش وارد کرده.
class WatchlistEntry {
  final String symbol;
  final DateTime addedAt;
  final List<HoldingLot> lots; // خالی یعنی فقط دیده‌بانی، بدون مالکیت واقعی

  const WatchlistEntry({
    required this.symbol,
    required this.addedAt,
    this.lots = const [],
  });

  bool get hasHoldings => lots.isNotEmpty;

  int get totalQuantity => lots.fold(0, (sum, l) => sum + l.quantity);

  double get averageBuyPrice {
    if (lots.isEmpty) return 0;
    final totalCost = lots.fold<double>(0, (s, l) => s + l.quantity * l.price);
    return totalCost / totalQuantity;
  }
}

/// یک تراکنش خرید یا فروش که کاربر به صورت دستی وارد کرده
/// (برای محاسبه سود/زیان اختیاری روی دیده‌بان)
class HoldingLot {
  final String id;
  final bool isBuy;
  final int quantity;
  final double price;
  final DateTime date;

  const HoldingLot({
    required this.id,
    required this.isBuy,
    required this.quantity,
    required this.price,
    required this.date,
  });

  factory HoldingLot.fromJson(Map<String, dynamic> json) => HoldingLot(
        id: json['id'] as String,
        isBuy: json['isBuy'] as bool,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isBuy': isBuy,
        'quantity': quantity,
        'price': price,
        'date': date.toIso8601String(),
      };
}

/// کاربر می‌تواند چند دیده‌بان مجزا داشته باشد (مثلاً "بلندمدت"، "نوسانی")
class Watchlist {
  final String id;
  final String name;
  final List<WatchlistEntry> entries;

  const Watchlist({
    required this.id,
    required this.name,
    this.entries = const [],
  });

  Watchlist copyWith({String? name, List<WatchlistEntry>? entries}) =>
      Watchlist(
        id: id,
        name: name ?? this.name,
        entries: entries ?? this.entries,
      );
}
