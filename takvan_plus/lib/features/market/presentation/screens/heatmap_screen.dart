import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/stock_symbol.dart';
import '../../providers/market_providers.dart';

/// Two levels:
/// 1) grid of industries, tile size ~ combined market cap, color ~ avg change
/// 2) tap an industry -> grid of its symbols, same idea
class HeatmapScreen extends ConsumerWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmap = ref.watch(heatmapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('نقشه بازار')),
      body: heatmap.when(
        data: (map) => _IndustryGrid(map: map),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('خطا در بارگذاری')),
      ),
    );
  }
}

class _IndustryGrid extends StatelessWidget {
  final Map<String, List<StockSymbol>> map;
  const _IndustryGrid({required this.map});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: map.length,
      itemBuilder: (_, i) {
        final industry = map.keys.elementAt(i);
        final symbols = map[industry]!;
        final avgChange =
            symbols.map((s) => s.changePercent).reduce((a, b) => a + b) / symbols.length;
        final color = AppColors.changeColor(avgChange);
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _IndustryDetailScreen(industry: industry, symbols: symbols)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              border: Border.all(color: color.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(industry, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '${avgChange > 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                Text('${symbols.length} نماد',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IndustryDetailScreen extends StatelessWidget {
  final String industry;
  final List<StockSymbol> symbols;
  const _IndustryDetailScreen({required this.industry, required this.symbols});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(industry)),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
        ),
        itemCount: symbols.length,
        itemBuilder: (_, i) {
          final s = symbols[i];
          final color = AppColors.changeColor(s.changePercent);
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/stock/${s.symbol}'),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                border: Border.all(color: color.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${s.changePercent > 0 ? '+' : ''}${s.changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
