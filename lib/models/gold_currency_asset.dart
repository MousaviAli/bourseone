enum GCCategory { domestic, international }
enum GCType { gold, currency, commodity }

class GoldCurrencyAsset {
  final String key;
  final String name;
  final GCCategory category;
  final GCType type;
  final double price;
  final String unit; // تومان | دلار | ...
  final double changePercent;

  const GoldCurrencyAsset({
    required this.key,
    required this.name,
    required this.category,
    required this.type,
    required this.price,
    required this.unit,
    required this.changePercent,
  });

  factory GoldCurrencyAsset.fromJson(Map<String, dynamic> json) => GoldCurrencyAsset(
        key: json['key'] as String,
        name: json['name'] as String,
        category: (json['category'] as String) == 'international'
            ? GCCategory.international
            : GCCategory.domestic,
        type: GCType.values.firstWhere((t) => t.name == json['type'], orElse: () => GCType.currency),
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String,
        changePercent: (json['changePercent'] as num).toDouble(),
      );
}
