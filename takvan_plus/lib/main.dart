import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: TakvanPlusApp()));
}

class TakvanPlusApp extends ConsumerWidget {
  const TakvanPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ایزی‌استاک | EasyStock',
      theme: AppTheme.dark(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: ThemeMode.dark,
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
          child: child!,
        );
      },
    );
  }
}
