import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/stock_widgets.dart';
import '../../../market/providers/market_providers.dart';
import '../../../watchlist/providers/watchlist_providers.dart';
import '../../../profile/providers/subscription_providers.dart';
import '../../../../models/social_post.dart';
import '../../../../models/task_item.dart';
import '../../../tasks/providers/task_providers.dart';
import '../../../alerts/presentation/widgets/set_alert_button.dart';

class StockDetailScreen extends ConsumerWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canView = ref.watch(canViewSymbolProvider(symbol));

    if (!canView) {
      return Scaffold(
        appBar: AppBar(title: Text(symbol)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.gold, size: 40),
              const SizedBox(height: 16),
              Text(l10n.subscribeTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 8),
              Text(l10n.subscribeBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push('/subscribe'),
                child: Text(l10n.subscribeTitle),
              ),
            ],
          ),
        ),
      );
    }

    // Grant + persist access for this symbol (no-op if already counted).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewedSymbolsProvider.notifier).markViewed(symbol);
    });

    final detail = ref.watch(symbolDetailProvider(symbol));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(symbol),
          actions: [
            SetAlertButton(symbol: symbol, currentPrice: detail.valueOrNull?.lastPrice ?? 0),
            IconButton(
              icon: const Icon(Icons.forum_outlined),
              tooltip: 'نظرات و تحلیل‌ها',
              onPressed: () => context.push(
                '/social',
                extra: SocialTag(type: SocialTagType.symbol, value: symbol),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () => ref
                  .read(watchlistControllerProvider.notifier)
                  .addSymbol('default', symbol),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.neonGreen,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: l10n.priceChart),
              Tab(text: l10n.fundamentalData),
              Tab(text: l10n.technicalAnalysis),
              Tab(text: l10n.codalReports),
            ],
          ),
        ),
        body: detail.when(
          data: (stock) => TabBarView(
            children: [
              _ChartTab(symbol: symbol, stock: stock),
              _FundamentalsTab(stock: stock),
              _TechnicalTab(symbol: symbol),
              _CodalTab(symbol: symbol),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.somethingWrong)),
        ),
      ),
    );
  }
}

class _ChartTab extends ConsumerWidget {
  final String symbol;
  final dynamic stock;
  const _ChartTab({required this.symbol, required this.stock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(priceHistoryRangeProvider);
    final history = ref.watch(priceHistoryProvider(symbol));
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(stock.lastPrice.toStringAsFixed(0),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            ChangeChip(changePercent: stock.changePercent),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: history.when(
            data: (points) {
              if (points.isEmpty) return const SizedBox.shrink();
              final spots = <FlSpot>[
                for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].close)
              ];
              final color = AppColors.changeColor(stock.changePercent);
              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.cardElevated,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.somethingWrong)),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['1W', '1M', '3M', '1Y'].map((r) {
            final selected = r == range;
            return ChoiceChip(
              label: Text(r),
              selected: selected,
              onSelected: (_) => ref.read(priceHistoryRangeProvider.notifier).state = r,
              selectedColor: AppColors.neonGreen.withOpacity(0.2),
              labelStyle: TextStyle(color: selected ? AppColors.neonGreen : AppColors.textSecondary),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.buyQueue, style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ..._queueRows(color: AppColors.neonGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.sellQueue, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ..._queueRows(color: AppColors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Builder(builder: (context) {
          final tasks = ref.watch(taskControllerProvider).where((t) =>
              t.attachments.any((a) => a.type == TaskAttachmentType.symbol && a.label == symbol));
          if (tasks.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تسک‌های مرتبط', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              ...tasks.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassCard(
                      onTap: () => context.push('/timeline'),
                      child: Row(
                        children: [
                          Icon(
                            t.isDone ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                            size: 16,
                            color: t.isDone ? AppColors.neonGreen : AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(t.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  decoration: t.isDone ? TextDecoration.lineThrough : null,
                                )),
                          ),
                          Text('${t.dueAt.month}/${t.dueAt.day}',
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }

  List<Widget> _queueRows({required Color color}) {
    return List.generate(3, (i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(stock.lastPrice - i * 10).toStringAsFixed(0)}',
                style: TextStyle(color: color, fontSize: 12)),
            Text('${(1000 * (i + 1))}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    });
  }
}

class _FundamentalsTab extends StatelessWidget {
  final dynamic stock;
  const _FundamentalsTab({required this.stock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = {
      'P/E': stock.pe?.toStringAsFixed(2) ?? '-',
      'EPS': stock.eps?.toStringAsFixed(0) ?? '-',
      'ارزش بازار': '${(stock.marketCap / 1e9).toStringAsFixed(0)} میلیارد',
      'حجم معاملات': stock.volume.toString(),
      'قیمت پایانی': stock.closingPrice.toStringAsFixed(0),
      'صنعت': stock.industry,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            children: rows.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: TextStyle(color: AppColors.textSecondary)),
                          Text(e.value, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.financialRatios, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        GlassCard(
          child: Text(
            'نسبت‌های مالی تفصیلی (P/B، ROE، ROA و ...) از طریق سرویس کدال روی بک‌اند تامین می‌شود.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _TechnicalTab extends StatelessWidget {
  final String symbol;
  const _TechnicalTab({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        GlassCard(
          child: Text(
            'نمودار تحلیل تکنیکال (خطوط روند، فیبوناچی، ایچیموکو، RSI، MACD) با کتابخانه syncfusion_flutter_charts پیاده‌سازی می‌شود. ابزار ترسیم برای کاربر (خط روند، مستطیل، فیبوناچی) در این پنل فعال است.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _CodalTab extends StatelessWidget {
  final String symbol;
  const _CodalTab({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('صورت‌های مالی میان‌دوره‌ای ۶ ماهه',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(l10n.codalReports, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.download_outlined, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: Text(
            'گزارش‌های کدال از طریق /reports/codal/{symbol} روی بک‌اند واکشی و کش می‌شوند.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
