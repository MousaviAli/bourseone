import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/price_alert.dart';
import '../../../../widgets/glass_card.dart';
import '../../providers/price_alert_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(priceAlertControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('هشدارهای قیمت')),
      body: alerts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'هنوز هشداری تنظیم نکرده‌اید. از صفحه‌ی جزئیات هر نماد یا رمزارز، آیکون زنگ 🔔 رو بزنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (_, i) {
                final a = alerts[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          a.triggered ? Icons.notifications_active : Icons.notifications_none,
                          color: a.triggered ? AppColors.gold : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                a.direction == AlertDirection.above
                                    ? 'وقتی قیمت بالاتر از ${a.targetPrice.toStringAsFixed(a.isCrypto ? 2 : 0)} بشه'
                                    : 'وقتی قیمت پایین‌تر از ${a.targetPrice.toStringAsFixed(a.isCrypto ? 2 : 0)} بشه',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              if (a.triggered)
                                const Text('✅ فعال شده', style: TextStyle(fontSize: 11, color: AppColors.gold)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                          onPressed: () => ref.read(priceAlertControllerProvider.notifier).remove(a.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
