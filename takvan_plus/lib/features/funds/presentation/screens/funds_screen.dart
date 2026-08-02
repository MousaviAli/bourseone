import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/investment_fund.dart';
import '../../../../widgets/glass_card.dart';
import '../../providers/funds_providers.dart';

class FundsScreen extends ConsumerWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final filter = ref.watch(fundTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('صندوق‌های سرمایه‌گذاری')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('همه'),
                    selected: filter == null,
                    onSelected: (_) => ref.read(fundTypeFilterProvider.notifier).state = null,
                  ),
                ),
                for (final type in FundType.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(type.labelFa),
                      selected: filter == type,
                      onSelected: (_) => ref.read(fundTypeFilterProvider.notifier).state = type,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: funds.when(
              data: (list) {
                final filtered = filter == null ? list : list.where((f) => f.type == filter).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final f = filtered[i];
                    final color = AppColors.changeColor(f.dailyChangePercent);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(f.type.labelFa, style: const TextStyle(fontSize: 10, color: AppColors.blue)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(f.manager, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('NAV هر واحد', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    Text('${f.nav.toStringAsFixed(0)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('بازده ۱ ساله', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    Text('+${f.oneYearReturnPercent.toStringAsFixed(1)}%',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.neonGreen)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('تغییر روزانه', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    Text('${f.dailyChangePercent > 0 ? '+' : ''}${f.dailyChangePercent.toStringAsFixed(2)}%',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                                  ],
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('خطا در بارگذاری')),
            ),
          ),
        ],
      ),
    );
  }
}
