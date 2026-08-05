import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: TakvanPlusApp()));
}

class TakvanPlusApp extends ConsumerWidget {
  const TakvanPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(isDarkModeProvider);

    // Key forces the whole subtree to rebuild fresh whenever light/dark
    // changes, so every custom widget re-reads AppColors.* (which our
    // widgets consult directly instead of Theme.of(context)).
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ایزی‌استاک | EasyStock',
      theme: AppTheme.build(locale),
      darkTheme: AppTheme.build(locale),
      themeMode: ThemeMode.light, // irrelevant: both slots are identical; isDark drives AppColors instead
      locale: locale,
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'fa' ? TextDirection.rtl : TextDirection.ltr,
          // KeyedSubtree forces a full rebuild of the page content (so every
          // widget re-reads AppColors.*) whenever locale/theme changes,
          // WITHOUT remounting MaterialApp/Router itself - navigation
          // state (current route, back stack) is preserved.
          child: KeyedSubtree(
            key: ValueKey('${locale.languageCode}-$isDark'),
            child: child!,
          ),
        );
      },
    );
  }
}
