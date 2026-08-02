import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../models/stock_symbol.dart';
import 'market_repository.dart';

/// Talks to YOUR backend's `/market/*` endpoints (see takvan_plus_backend/routes/market.js),
/// which in turn scrape/cache TSETMC + CODAL. The app itself never touches
/// tsetmc.com directly (CORS, rate-limits and TOS make that unreliable from
/// a mobile client - always go through your own server).
class RemoteMarketRepository implements MarketRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<StockSymbol>> getAllSymbols() async {
    final res = await _dio.get('/market/symbols');
    return (res.data as List)
        .map((e) => StockSymbol.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StockSymbol>> searchSymbols(String query) async {
    final res = await _dio.get('/market/symbols/search', queryParameters: {'q': query});
    return (res.data as List)
        .map((e) => StockSymbol.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StockSymbol> getSymbolDetail(String symbol) async {
    final res = await _dio.get('/market/symbols/$symbol');
    return StockSymbol.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<PricePoint>> getPriceHistory(String symbol, {String range = '1M'}) async {
    final res = await _dio.get(
      '/market/symbols/$symbol/history',
      queryParameters: {'range': range},
    );
    return (res.data as List)
        .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MarketIndex>> getIndices() async {
    final res = await _dio.get('/market/indices');
    return (res.data as List).map((e) {
      final m = e as Map<String, dynamic>;
      return MarketIndex(
        key: m['key'] as String,
        title: m['title'] as String,
        value: (m['value'] as num).toDouble(),
        changePercent: (m['changePercent'] as num).toDouble(),
        history: (m['history'] as List? ?? [])
            .map((h) => PricePoint.fromJson(h as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }

  @override
  Future<List<StockSymbol>> getTopGainers({int limit = 10}) async {
    final res = await _dio.get('/market/movers/gainers', queryParameters: {'limit': limit});
    return (res.data as List).map((e) => StockSymbol.fromJson(e)).toList();
  }

  @override
  Future<List<StockSymbol>> getTopLosers({int limit = 10}) async {
    final res = await _dio.get('/market/movers/losers', queryParameters: {'limit': limit});
    return (res.data as List).map((e) => StockSymbol.fromJson(e)).toList();
  }

  @override
  Future<List<StockSymbol>> getMostTraded({int limit = 10}) async {
    final res = await _dio.get('/market/movers/most-traded', queryParameters: {'limit': limit});
    return (res.data as List).map((e) => StockSymbol.fromJson(e)).toList();
  }

  @override
  Future<Map<String, List<StockSymbol>>> getHeatmapByIndustry() async {
    final res = await _dio.get('/market/heatmap');
    final map = res.data as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(
          k,
          (v as List).map((e) => StockSymbol.fromJson(e)).toList(),
        ));
  }

  @override
  Future<bool> isMarketOpen() async {
    final res = await _dio.get('/market/status');
    return (res.data as Map<String, dynamic>)['isOpen'] as bool;
  }
}
