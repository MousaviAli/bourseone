import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/price_alert.dart';
import '../../providers/price_alert_providers.dart';

/// Bell icon button that opens a small dialog to set a price alert for
/// [symbol] (a stock symbol or a crypto ticker - pass [isCrypto]
/// accordingly since the two use different price providers).
class SetAlertButton extends ConsumerWidget {
  final String symbol;
  final bool isCrypto;
  final double currentPrice;

  const SetAlertButton({
    super.key,
    required this.symbol,
    required this.currentPrice,
    this.isCrypto = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.notifications_none, color: AppColors.gold),
      tooltip: 'تنظیم هشدار قیمت',
      onPressed: () => _showDialog(context, ref),
    );
  }

  void _showDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: currentPrice.toStringAsFixed(isCrypto ? 2 : 0));
    var direction = AlertDirection.above;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('هشدار قیمت برای $symbol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<AlertDirection>(
                segments: const [
                  ButtonSegment(value: AlertDirection.above, label: Text('بالاتر از'), icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(value: AlertDirection.below, label: Text('پایین‌تر از'), icon: Icon(Icons.arrow_downward)),
                ],
                selected: {direction},
                onSelectionChanged: (s) => setState(() => direction = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'قیمت هدف'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
            TextButton(
              onPressed: () {
                final target = double.tryParse(controller.text.trim());
                if (target != null) {
                  ref.read(priceAlertControllerProvider.notifier).add(
                        PriceAlert(
                          id: 'alert_${DateTime.now().microsecondsSinceEpoch}',
                          symbol: symbol,
                          isCrypto: isCrypto,
                          targetPrice: target,
                          direction: direction,
                          createdAt: DateTime.now(),
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('تنظیم هشدار'),
            ),
          ],
        ),
      ),
    );
  }
}
