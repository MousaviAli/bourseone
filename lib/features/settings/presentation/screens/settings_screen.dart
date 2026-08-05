import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../authentication/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsLanguage,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'fa', label: Text('فارسی')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (sel) =>
                ref.read(localeProvider.notifier).setLocale(Locale(sel.first)),
          ),
          const SizedBox(height: 20),
          Text(l10n.settingsTheme,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('تیره'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: false, label: Text('روشن'), icon: Icon(Icons.light_mode_outlined)),
            ],
            selected: {isDark},
            onSelectionChanged: (sel) =>
                ref.read(isDarkModeProvider.notifier).setDark(sel.first),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text(l10n.settingsBiometric),
            value: false,
            onChanged: (_) {},
            activeColor: AppColors.neonGreen,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l10n.settingsNotifications),
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.neonGreen,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_outlined, color: AppColors.gold),
            title: Text(l10n.academyTitle),
            trailing: Icon(Icons.chevron_left, color: AppColors.textMuted),
            onTap: () => context.push('/academy'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.checklist_outlined, color: AppColors.blue),
            title: const Text('تسک‌ها و یادداشت‌ها'),
            trailing: Icon(Icons.chevron_left, color: AppColors.textMuted),
            onTap: () => context.push('/timeline'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_balance_outlined, color: AppColors.neonGreen),
            title: const Text('صندوق‌های سرمایه‌گذاری'),
            trailing: Icon(Icons.chevron_left, color: AppColors.textMuted),
            onTap: () => context.push('/funds'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.forum_outlined, color: AppColors.blue),
            title: const Text('نظرات و تحلیل‌های کاربران'),
            trailing: Icon(Icons.chevron_left, color: AppColors.textMuted),
            onTap: () => context.push('/social'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: AppColors.red),
            label: Text(l10n.settingsLogout, style: const TextStyle(color: AppColors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }
}
