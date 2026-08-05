import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/glass_card.dart';

class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plans = [
      (l10n.plan1Month, '۱۹۹,۰۰۰ تومان'),
      (l10n.plan3Month, '۴۹۹,۰۰۰ تومان'),
      (l10n.plan6Month, '۸۹۹,۰۰۰ تومان'),
      (l10n.plan1Year, '۱,۴۹۹,۰۰۰ تومان'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscribeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.subscribeBody, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...plans.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(p.$2, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
