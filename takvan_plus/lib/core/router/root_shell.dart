import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Wraps the 5 primary destinations. Below 700px width -> bottom nav bar
/// (phones). Above that -> a NavigationRail, so the app also looks right
/// on tablets / desktop browsers (Flutter web build).
class RootShell extends StatelessWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  static const _tabs = [
    ('/dashboard', Icons.dashboard_outlined, Icons.dashboard),
    ('/market', Icons.show_chart, Icons.show_chart),
    ('/watchlist', Icons.visibility_outlined, Icons.visibility),
    ('/assistant', Icons.auto_awesome_outlined, Icons.auto_awesome),
    ('/settings', Icons.settings_outlined, Icons.settings),
  ];

  int _indexForLocation(String location) {
    final i = _tabs.indexWhere((t) => location.startsWith(t.$1));
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.navDashboard,
      l10n.navMarket,
      l10n.navWatchlist,
      l10n.navAssistant,
      l10n.navSettings,
    ];
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final isWide = MediaQuery.of(context).size.width >= 700;

    void onSelect(int i) => context.go(_tabs[i].$1);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: currentIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (int i = 0; i < _tabs.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_tabs[i].$2),
                    selectedIcon: Icon(_tabs[i].$3),
                    label: Text(labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onSelect,
        items: [
          for (int i = 0; i < _tabs.length; i++)
            BottomNavigationBarItem(
              icon: Icon(_tabs[i].$2),
              activeIcon: Icon(_tabs[i].$3),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}
