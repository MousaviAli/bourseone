import 'dart:async';
import 'package:flutter/material.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_en.dart';

/// NOTE: This file (and the two per-locale files it imports) mirrors
/// app_fa.arb / app_en.arb by hand. Once you run:
///   flutter gen-l10n
/// Flutter will regenerate a fuller, type-safe version from those ARB
/// files. Keeping this hand-written version means the project compiles
/// right away even before you've run the Flutter toolchain.
abstract class AppLocalizations {
  AppLocalizations(this.localeName);
  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appName;
  String get appTagline;
  String get navDashboard;
  String get navMarket;
  String get navWatchlist;
  String get navAssistant;
  String get navReports;
  String get navAcademy;
  String get navProfile;
  String get navSettings;
  String get login;
  String get register;
  String get phoneNumber;
  String get otpTitle;
  String otpSubtitle(String phone);
  String get forgotPassword;
  String get resendOtp;
  String get verify;
  String get marketOpen;
  String get marketClosed;
  String get marketPreOpen;
  String get tedpixIndex;
  String get equalWeightIndex;
  String get industryIndex;
  String get topGainers;
  String get topLosers;
  String get mostTraded;
  String get watchlistEmpty;
  String get addToWatchlist;
  String get createWatchlist;
  String get searchSymbolHint;
  String get priceChart;
  String get technicalAnalysis;
  String get fundamentalData;
  String get buyQueue;
  String get sellQueue;
  String get companyNews;
  String get codalReports;
  String get financialRatios;
  String get portfolioValue;
  String get dailyPnl;
  String get allocation;
  String get assistantGreeting;
  String get assistantInputHint;
  String get assistantSuggested;
  String get subscribeTitle;
  String get subscribeBody;
  String get plan1Month;
  String get plan3Month;
  String get plan6Month;
  String get plan1Year;
  String get academyTitle;
  String get academyCourses;
  String get academyArticles;
  String get academyQuizzes;
  String get settingsLanguage;
  String get settingsTheme;
  String get settingsBiometric;
  String get settingsNotifications;
  String get settingsLogout;
  String get retry;
  String get loading;
  String get noInternet;
  String get somethingWrong;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fa', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final impl = locale.languageCode == 'en' ? AppLocalizationsEn() : AppLocalizationsFa();
    return SynchronousFuture<AppLocalizations>(impl);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Minimal SynchronousFuture (avoids importing flutter/foundation just for this).
class SynchronousFuture<T> implements Future<T> {
  SynchronousFuture(this._value);
  final T _value;

  @override
  Stream<T> asStream() => Stream<T>.fromIterable([_value]);

  @override
  Future<T> catchError(Function onError, {bool Function(Object)? test}) => this;

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    final result = onValue(_value);
    if (result is Future<R>) return result;
    return SynchronousFuture<R>(result as R);
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) => this;

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    action();
    return this;
  }
}
