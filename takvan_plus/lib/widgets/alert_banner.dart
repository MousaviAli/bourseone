import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AlertBannerType { info, success, warning, danger }

/// High-contrast alert/notification banner. Earlier versions used a
/// near-transparent glass card for status messages (e.g. market open/closed)
/// which was hard to read - this uses a solid-enough background + bold
/// white-ish text to stay legible at a glance.
class AlertBanner extends StatelessWidget {
  final AlertBannerType type;
  final String message;
  final IconData? icon;

  const AlertBanner({super.key, required this.type, required this.message, this.icon});

  Color get _color => switch (type) {
        AlertBannerType.info => AppColors.blue,
        AlertBannerType.success => AppColors.neonGreen,
        AlertBannerType.warning => AppColors.gold,
        AlertBannerType.danger => AppColors.red,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
