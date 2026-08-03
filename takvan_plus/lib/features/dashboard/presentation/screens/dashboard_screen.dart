import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../market/providers/market_providers.dart';
import '../../../market/providers/market_stats_providers.dart';
import '../../../watchlist/providers/watchlist_providers.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/stock_widgets.dart';
import '../../../../widgets/alert_banner.dart';
import '../../../../widgets/app_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final marketOpen = ref.watch(marketOpenProvider);
    final indices = ref.watch(indicesProvider);
    final gainers = ref.watch(topGainersProvider);
    final losers = ref.watch(topLosersProvider);
    final mostTraded = ref.watch(mostTradedProvider);
    final stats = ref.watch(marketStatsProvider);
    final news = ref.watch(financialNewsProvider);
    final watchlists = ref.watch(watchlistControllerProvider);
    final allSymbols = ref.watch(allSymbolsProvider);
    final jalali = Jalali.now().formatter;
    final gregorian = DateTime.now();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset('assets/brand/logo_mark.png'),
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
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
          ref.invalidate(mostTradedProvider);
          ref.invalidate(marketStatsProvider);
          ref.invalidate(financialNewsProvider);
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

            // ---- Market-wide stats grid ----
            Text('آمار بازار', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            stats.when(
              data: (s) => GlassCard(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.6,
                  mainAxisSpacing: 4,
                  children: [
                    _StatTile(label: 'ارزش معاملات', value: '${(s.valueTradedBillionToman/1000).toStringAsFixed(1)} هزار میلیارد'),
                    _StatTile(label: 'حجم معاملات', value: '${s.volumeBillion.toStringAsFixed(1)} میلیارد'),
                    _StatTile(label: 'ورود پول حقیقی', value: '${(s.realMoneyInflowBillionToman/1000).toStringAsFixed(1)} هزار میلیارد'),
                    _StatTile(label: 'نمادهای مثبت / منفی', value: '${s.positiveSymbolsCount} / ${s.negativeSymbolsCount}',
                        valueColor: null),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ---- Portfolio composition (from watchlist holdings) ----
            Text('ترکیب پرتفوی', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            allSymbols.when(
              data: (symbolList) {
                final priceOf = {for (final s in symbolList) s.symbol: s.lastPrice};
                final holdings = <String, double>{};
                for (final w in watchlists) {
                  for (final e in w.entries) {
                    if (!e.hasHoldings) continue;
                    final value = e.totalQuantity * (priceOf[e.symbol] ?? 0);
                    holdings[e.symbol] = (holdings[e.symbol] ?? 0) + value;
                  }
                }
                if (holdings.isEmpty) {
                  return GlassCard(
                    child: Text(
                      'هنوز دارایی‌ای با تعداد/قیمت خرید ثبت نکرده‌اید. از دیده‌بان، برای هر نماد سابقه‌ی خرید اضافه کنید تا اینجا نمودار ترکیب پرتفوی‌تان را ببینید.',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  );
                }
                final total = holdings.values.fold<double>(0, (a, b) => a + b);
                final colors = [AppColors.neonGreen, AppColors.blue, AppColors.gold, AppColors.red, AppColors.textSecondary];
                final entries = holdings.entries.toList();
                return GlassCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110, height: 110,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 28,
                            sections: [
                              for (int i = 0; i < entries.length; i++)
                                PieChartSectionData(
                                  value: entries[i].value,
                                  color: colors[i % colors.length],
                                  showTitle: false,
                                  radius: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < entries.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(entries[i].key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text('${(entries[i].value/total*100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            Text(l10n.topGainers, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            gainers.when(
              data: (list) => Column(
                children: list
                    .take(4)
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
                    .take(4)
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

            Text(l10n.mostTraded, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            mostTraded.when(
              data: (list) => Column(
                children: list
                    .take(4)
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

            // ---- Financial news ----
            Text('اخبار مالی', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            news.when(
              data: (list) => Column(
                children: list.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.article_outlined, size: 16, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(n.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(n.source, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text(n.minutesAgoLabel, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )).toList(),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
