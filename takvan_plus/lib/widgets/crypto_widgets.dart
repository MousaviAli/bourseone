import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/crypto_asset.dart';

class CryptoListTile extends StatelessWidget {
  final CryptoAsset coin;
  final VoidCallback? onTap;
  const CryptoListTile({super.key, required this.coin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.changeColor(coin.changePercent24h);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.cardElevated,
        backgroundImage: coin.logoUrl != null ? NetworkImage(coin.logoUrl!) : null,
        child: coin.logoUrl == null
            ? Text(coin.symbol.characters.first,
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700))
            : null,
      ),
      title: Text(coin.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(coin.name,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('\$${coin.priceUsd.toStringAsFixed(coin.priceUsd < 10 ? 4 : 0)}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(
              '${coin.changePercent24h > 0 ? '+' : ''}${coin.changePercent24h.toStringAsFixed(2)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
