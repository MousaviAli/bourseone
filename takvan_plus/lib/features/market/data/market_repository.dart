import '../../../models/stock_symbol.dart';

/// Contract for anything that can supply market data.
/// Two implementations exist:
///  - MockMarketRepository (lib/features/market/data/mock_market_repository.dart)
///  - RemoteMarketRepository (lib/features/market/data/remote_market_repository.dart)
/// Swap the provider binding in market_providers.dart to go live.
abstract class MarketRepository {
  Future<List<StockSymbol>> getAllSymbols();
  Future<List<StockSymbol>> searchSymbols(String query);
  Future<StockSymbol> getSymbolDetail(String symbol);
  Future<List<PricePoint>> getPriceHistory(String symbol, {String range = '1M'});
  Future<List<MarketIndex>> getIndices();
  Future<List<StockSymbol>> getTopGainers({int limit = 10});
  Future<List<StockSymbol>> getTopLosers({int limit = 10});
  Future<List<StockSymbol>> getMostTraded({int limit = 10});
  Future<Map<String, List<StockSymbol>>> getHeatmapByIndustry();
  Future<bool> isMarketOpen();
}
