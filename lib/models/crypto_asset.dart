class CryptoAsset {
  final String slug;
  final String symbol; // BTC, ETH, ...
  final String name;
  final double priceUsd;
  final double priceToman;
  final double changePercent24h;
  final double marketCapUsd;
  final double volume24hUsd;
  final String? logoUrl;

  const CryptoAsset({
    required this.slug,
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.priceToman,
    required this.changePercent24h,
    required this.marketCapUsd,
    required this.volume24hUsd,
    this.logoUrl,
  });

  factory CryptoAsset.fromJson(Map<String, dynamic> json) => CryptoAsset(
        slug: json['slug'] as String,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        priceUsd: double.tryParse(json['priceUsd'].toString()) ?? 0,
        priceToman: double.tryParse(json['priceToman'].toString()) ?? 0,
        changePercent24h: double.tryParse(json['changePercent24h'].toString()) ?? 0,
        marketCapUsd: double.tryParse(json['marketCapUsd'].toString()) ?? 0,
        volume24hUsd: double.tryParse(json['volume24hUsd'].toString()) ?? 0,
        logoUrl: json['logoUrl'] as String?,
      );
}

class CryptoNewsItem {
  final String title;
  final String url;
  const CryptoNewsItem({required this.title, required this.url});

  factory CryptoNewsItem.fromJson(Map<String, dynamic> json) =>
      CryptoNewsItem(title: json['title'] as String, url: json['url'] as String);
}
