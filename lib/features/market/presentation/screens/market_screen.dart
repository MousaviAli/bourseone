import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/stock_widgets.dart';
import '../../../../widgets/crypto_widgets.dart';
import '../../../../widgets/shimmer_box.dart';
import '../../../crypto/providers/crypto_providers.dart';
import '../../../gold_currency/presentation/screens/gold_currency_screen.dart';
import '../../providers/market_providers.dart';

enum _AssetClass { stocks, crypto, goldCurrency }

final _assetClassProvider = StateProvider<_AssetClass>((ref) => _AssetClass.stocks);

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final assetClass = ref.watch(_assetClassProvider);
    final query = ref.watch(symbolSearchQueryProvider);
    final results = ref.watch(symbolSearchResultsProvider);
    final coins = ref.watch(cryptoCoinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMarket),
        actions: [
          if (assetClass == _AssetClass.stocks)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Heatmap',
              onPressed: () => context.push('/heatmap'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<_AssetClass>(
                segments: const [
                  ButtonSegment(value: _AssetClass.stocks, label: Text('بورس'), icon: Icon(Icons.show_chart)),
                  ButtonSegment(value: _AssetClass.crypto, label: Text('رمزارز'), icon: Icon(Icons.currency_bitcoin)),
                  ButtonSegment(value: _AssetClass.goldCurrency, label: Text('طلا و ارز'), icon: Icon(Icons.workspace_premium_outlined)),
                ],
                selected: {assetClass},
                onSelectionChanged: (sel) => ref.read(_assetClassProvider.notifier).state = sel.first,
              ),
            ),
          ),
          if (assetClass == _AssetClass.stocks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => ref.read(symbolSearchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: l10n.searchSymbolHint,
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => ref.read(symbolSearchQueryProvider.notifier).state = '',
                        )
                      : null,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (assetClass) {
              _AssetClass.stocks => results.when(
                  data: (list) => list.isEmpty
                      ? Center(child: Text(l10n.somethingWrong))
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, i) => StockListTile(
                            stock: list[i],
                            onTap: () => context.push('/stock/${list[i].symbol}'),
                          ),
                        ),
                  loading: () => const ListSkeleton(count: 8),
                  error: (_, __) => Center(child: Text(l10n.somethingWrong)),
                ),
              _AssetClass.crypto => coins.when(
                  data: (list) => ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => CryptoListTile(
                      coin: list[i],
                      onTap: () => context.push('/crypto/${list[i].slug}'),
                    ),
                  ),
                  loading: () => const ListSkeleton(count: 8),
                  error: (_, __) => Center(child: Text(l10n.somethingWrong)),
                ),
              _AssetClass.goldCurrency => const GoldCurrencyScreen(),
            },
          ),
        ],
      ),
    );
  }
}
