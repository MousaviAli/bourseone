import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/gold_currency_asset.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/shimmer_box.dart';
import '../../providers/gold_currency_providers.dart';

class GoldCurrencyScreen extends ConsumerWidget {
  const GoldCurrencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(goldCurrencyProvider);
    final categoryFilter = ref.watch(goldCurrencyCategoryFilterProvider);
    final typeFilter = ref.watch(goldCurrencyTypeFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<GCCategory?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('همه')),
                    ButtonSegment(value: GCCategory.domestic, label: Text('داخلی')),
                    ButtonSegment(value: GCCategory.international, label: Text('جهانی')),
                  ],
                  selected: {categoryFilter},
                  onSelectionChanged: (s) =>
                      ref.read(goldCurrencyCategoryFilterProvider.notifier).state = s.first,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('همه انواع'),
                    selected: typeFilter == null,
                    onSelected: (_) => ref.read(goldCurrencyTypeFilterProvider.notifier).state = null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('طلا'),
                    selected: typeFilter == GCType.gold,
                    onSelected: (_) => ref.read(goldCurrencyTypeFilterProvider.notifier).state = GCType.gold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('ارز'),
                    selected: typeFilter == GCType.currency,
                    onSelected: (_) => ref.read(goldCurrencyTypeFilterProvider.notifier).state = GCType.currency,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('کالا'),
                    selected: typeFilter == GCType.commodity,
                    onSelected: (_) => ref.read(goldCurrencyTypeFilterProvider.notifier).state = GCType.commodity,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: data.when(
            data: (list) {
              var filtered = list;
              if (categoryFilter != null) {
                filtered = filtered.where((a) => a.category == categoryFilter).toList();
              }
              if (typeFilter != null) {
                filtered = filtered.where((a) => a.type == typeFilter).toList();
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final a = filtered[i];
                  final color = AppColors.changeColor(a.changePercent);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              a.type == GCType.gold
                                  ? Icons.workspace_premium_outlined
                                  : a.type == GCType.currency
                                      ? Icons.currency_exchange
                                      : Icons.local_gas_station_outlined,
                              size: 18,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(
                                  a.category == GCCategory.domestic ? 'بازار داخلی' : 'بازار جهانی',
                                  style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_formatPrice(a.price)} ${a.unit}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${a.changePercent > 0 ? '+' : ''}${a.changePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const ListSkeleton(count: 6),
            error: (_, __) => const Center(child: Text('خطا در بارگذاری')),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return price.toStringAsFixed(price < 10 ? 3 : 2);
  }
}
