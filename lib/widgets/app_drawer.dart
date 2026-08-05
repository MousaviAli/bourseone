import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Full quick-access menu to every section of the app - inspired by
/// wanting one-tap access to Indices/Funds/Academy/Timeline/Social
/// instead of nesting some of them only inside Settings.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(IconData, String, String)>[
      (Icons.dashboard_outlined, l10n.navDashboard, '/dashboard'),
      (Icons.show_chart, l10n.navMarket, '/market'),
      (Icons.grid_view_rounded, 'نقشه بازار', '/heatmap'),
      (Icons.visibility_outlined, l10n.navWatchlist, '/watchlist'),
      (Icons.account_balance_outlined, 'صندوق‌های سرمایه‌گذاری', '/funds'),
      (Icons.auto_awesome_outlined, l10n.navAssistant, '/assistant'),
      (Icons.checklist_outlined, 'تسک‌ها و یادداشت‌ها', '/timeline'),
      (Icons.forum_outlined, 'نظرات و تحلیل‌های کاربران', '/social'),
      (Icons.school_outlined, l10n.academyTitle, '/academy'),
      (Icons.notifications_none, 'هشدارهای قیمت', '/alerts'),
      (Icons.workspace_premium_outlined, 'اشتراک ویژه', '/subscribe'),
      (Icons.settings_outlined, l10n.navSettings, '/settings'),
    ];

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset('assets/brand/logo_mark.png', width: 44, height: 44),
                  const SizedBox(width: 12),
                  Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                ],
              ),
            ),
            Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in items)
                    ListTile(
                      leading: Icon(item.$1, color: AppColors.textSecondary, size: 21),
                      title: Text(item.$2, style: const TextStyle(fontSize: 13.5)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(item.$3);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
