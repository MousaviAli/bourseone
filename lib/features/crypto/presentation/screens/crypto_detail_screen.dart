import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/glass_card.dart';
import '../../providers/crypto_providers.dart';
import '../../../alerts/presentation/widgets/set_alert_button.dart';

class CryptoDetailScreen extends ConsumerWidget {
  final String slug;
  const CryptoDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coin = ref.watch(cryptoCoinDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: Text(slug.toUpperCase()),
        actions: [
          SetAlertButton(
            symbol: coin.valueOrNull?.symbol ?? slug.toUpperCase(),
            currentPrice: coin.valueOrNull?.priceUsd ?? 0,
            isCrypto: true,
          ),
        ],
      ),
      body: coin.when(
        data: (c) {
          final color = AppColors.changeColor(c.changePercent24h);
          final rnd = Random(c.slug.hashCode);
          final spots = List.generate(30, (i) {
            final wobble = (rnd.nextDouble() - 0.5) * 10;
            return FlSpot(i.toDouble(), 50 + i * 0.6 + wobble);
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.cardElevated,
                    child: Text(c.symbol.characters.first,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(c.symbol, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${c.priceUsd.toStringAsFixed(c.priceUsd < 10 ? 4 : 0)}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('${c.changePercent24h > 0 ? '+' : ''}${c.changePercent24h.toStringAsFixed(2)}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Text('≈ ${c.priceToman.toStringAsFixed(0)} تومان',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  children: [
                    _row('مارکت‌کپ', '\$${(c.marketCapUsd / 1e9).toStringAsFixed(2)}B'),
                    _row('حجم ۲۴ ساعته', '\$${(c.volume24hUsd / 1e6).toStringAsFixed(1)}M'),
                    _row('قیمت تومانی', '${c.priceToman.toStringAsFixed(0)} تومان'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: Text(
                  'داده‌های تفصیلی‌تر (ATH، عرضه در گردش، اخبار مرتبط) از طریق سرویس آرزدیجیتال روی بک‌اند تامین می‌شود.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('خطا در بارگذاری')),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
