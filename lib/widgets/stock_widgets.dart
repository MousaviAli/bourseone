import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/stock_symbol.dart';

/// Small +/- % pill, colored green/red like TradingView.
class ChangeChip extends StatelessWidget {
  final double changePercent;
  const ChangeChip({super.key, required this.changePercent});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.changeColor(changePercent);
    final sign = changePercent > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$sign${changePercent.toStringAsFixed(2)}%',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

/// Circular symbol logo with graceful fallback to initials.
class SymbolLogo extends StatelessWidget {
  final String symbol;
  final String? logoUrl;
  final double size;
  const SymbolLogo({super.key, required this.symbol, this.logoUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.cardElevated,
      backgroundImage: logoUrl != null ? NetworkImage(logoUrl!) : null,
      child: logoUrl == null
          ? Text(
              symbol.characters.first,
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
            )
          : null,
    );
  }
}

/// Row used across Market / Watchlist / search results lists.
class StockListTile extends StatelessWidget {
  final StockSymbol stock;
  final VoidCallback? onTap;
  final Widget? trailingExtra;

  const StockListTile({super.key, required this.stock, this.onTap, this.trailingExtra});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SymbolLogo(symbol: stock.symbol, logoUrl: stock.logoUrl),
      title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        stock.companyName,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.lastPrice.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              ChangeChip(changePercent: stock.changePercent),
            ],
          ),
          if (trailingExtra != null) ...[const SizedBox(width: 8), trailingExtra!],
        ],
      ),
    );
  }
}
