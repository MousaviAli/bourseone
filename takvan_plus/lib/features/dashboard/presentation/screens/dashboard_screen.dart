import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../market/providers/market_providers.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/stock_widgets.dart';
import '../../../../widgets/alert_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final marketOpen = ref.watch(marketOpenProvider);
    final indices = ref.watch(indicesProvider);
    final gainers = ref.watch(topGainersProvider);
    final losers = ref.watch(topLosersProvider);
    final jalali = Jalali.now().formatter;
    final gregorian = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${jalali.yyyy}/${jalali.mm}/${jalali.dd}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${gregorian.year}/${gregorian.month.toString().padLeft(2, '0')}/${gregorian.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(marketOpenProvider);
          ref.invalidate(indicesProvider);
          ref.invalidate(topGainersProvider);
          ref.invalidate(topLosersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            marketOpen.when(
              data: (isOpen) => AlertBanner(
                type: isOpen ? AlertBannerType.success : AlertBannerType.danger,
                message: isOpen ? l10n.marketOpen : l10n.marketClosed,
                icon: isOpen ? Icons.trending_up : Icons.access_time,
              ),
              loading: () => const SizedBox(height: 56),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Portfolio / watchlist value summary
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.portfolioValue,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text(
                    '۰ ﷼',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(l10n.dailyPnl,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 8),
                      const ChangeChip(changePercent: 0),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Indices
            SizedBox(
              height: 110,
              child: indices.when(
                data: (list) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final idx = list[i];
                    return SizedBox(
                      width: 160,
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(idx.title,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(
                              idx.value.toStringAsFixed(0),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            ChangeChip(changePercent: idx.changePercent),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(l10n.somethingWrong)),
              ),
            ),
            const SizedBox(height: 20),

            Text(l10n.topGainers, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            gainers.when(
              data: (list) => Column(
                children: list
                    .take(5)
                    .map((s) => StockListTile(
                          stock: s,
                          onTap: () => context.push('/stock/${s.symbol}'),
                        ))
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(l10n.somethingWrong),
            ),
            const SizedBox(height: 20),

            Text(l10n.topLosers, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            losers.when(
              data: (list) => Column(
                children: list
                    .take(5)
                    .map((s) => StockListTile(
                          stock: s,
                          onTap: () => context.push('/stock/${s.symbol}'),
                        ))
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(l10n.somethingWrong),
            ),
          ],
        ),
      ),
    );
  }
}
