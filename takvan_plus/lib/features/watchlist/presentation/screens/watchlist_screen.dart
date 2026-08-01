import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/watchlist.dart';
import '../../../../widgets/glass_card.dart';
import '../../../market/providers/market_providers.dart';
import '../../providers/watchlist_providers.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final watchlists = ref.watch(watchlistControllerProvider);
    final selectedId = ref.watch(selectedWatchlistIdProvider);
    final selected = watchlists.firstWhere((w) => w.id == selectedId,
        orElse: () => watchlists.first);
    final allSymbols = ref.watch(allSymbolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navWatchlist),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: watchlists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final w = watchlists[i];
                final isSelected = w.id == selectedId;
                return GestureDetector(
                  onLongPress: () => _showManageSheet(context, ref, w),
                  child: ChoiceChip(
                    label: Text(w.name),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(selectedWatchlistIdProvider.notifier).state = w.id,
                    selectedColor: AppColors.neonGreen.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.neonGreen : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AppColors.card,
                    side: BorderSide(
                      color: isSelected ? AppColors.neonGreen : AppColors.divider,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: selected.entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.watchlistEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : allSymbols.when(
                    data: (all) => ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: selected.entries.length,
                      itemBuilder: (_, i) {
                        final entry = selected.entries[i];
                        final stock = all.firstWhere(
                          (s) => s.symbol == entry.symbol,
                          orElse: () => all.first,
                        );
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          onTap: () => context.push('/stock/${stock.symbol}'),
                          child: ListTile(
                            title: Text(stock.symbol,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: entry.hasHoldings
                                ? Text(
                                    'میانگین خرید: ${entry.averageBuyPrice.toStringAsFixed(0)} | تعداد: ${entry.totalQuantity}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  )
                                : Text(stock.companyName,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${stock.changePercent > 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: AppColors.changeColor(stock.changePercent),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                                  onPressed: () => ref
                                      .read(watchlistControllerProvider.notifier)
                                      .removeSymbol(selected.id, stock.symbol),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSymbolSheet(context, ref, selected),
        icon: const Icon(Icons.add),
        label: Text(l10n.addToWatchlist),
      ),
    );
  }

  void _showManageSheet(BuildContext context, WidgetRef ref, Watchlist w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.blue),
              title: const Text('تغییر نام دیده‌بان'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, w);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.red),
              title: const Text('حذف دیده‌بان'),
              onTap: () {
                ref.read(watchlistControllerProvider.notifier).deleteWatchlist(w.id);
                final remaining = ref.read(watchlistControllerProvider);
                if (remaining.isNotEmpty &&
                    ref.read(selectedWatchlistIdProvider) == w.id) {
                  ref.read(selectedWatchlistIdProvider.notifier).state = remaining.first.id;
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Watchlist w) {
    final controller = TextEditingController(text: w.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تغییر نام دیده‌بان'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'نام جدید')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(watchlistControllerProvider.notifier).renameWatchlist(w.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ایجاد دیده‌بان جدید'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'نام دیده‌بان')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(watchlistControllerProvider.notifier).createWatchlist(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('ایجاد'),
          ),
        ],
      ),
    );
  }

  void _showAddSymbolSheet(BuildContext context, WidgetRef ref, Watchlist selected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (_) => Consumer(builder: (context, ref, __) {
        final all = ref.watch(allSymbolsProvider);
        return SizedBox(
          height: 500,
          child: all.when(
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(list[i].symbol),
                subtitle: Text(list[i].companyName, style: const TextStyle(fontSize: 11)),
                onTap: () {
                  ref.read(watchlistControllerProvider.notifier).addSymbol(selected.id, list[i].symbol);
                  Navigator.pop(context);
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        );
      }),
    );
  }
}
