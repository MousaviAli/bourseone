import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/otp_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/splash_screen.dart';
import '../../features/market/presentation/screens/market_screen.dart';
import '../../features/market/presentation/screens/heatmap_screen.dart';
import '../../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../../features/stock_detail/presentation/screens/stock_detail_screen.dart';
import '../../features/crypto/presentation/screens/crypto_detail_screen.dart';
import '../../features/assistant/presentation/screens/assistant_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/subscribe_screen.dart';
import '../../features/academy/presentation/screens/academy_screen.dart';
import '../../features/tasks/presentation/screens/timeline_screen.dart';
import '../../features/funds/presentation/screens/funds_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/social/presentation/screens/social_feed_screen.dart';
import '../../models/social_post.dart';
import 'root_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) => OtpScreen(phone: state.extra as String? ?? ''),
    ),
    GoRoute(path: '/subscribe', builder: (_, __) => const SubscribeScreen()),
    GoRoute(path: '/academy', builder: (_, __) => const AcademyScreen()),
    GoRoute(path: '/timeline', builder: (_, __) => const TimelineScreen()),
    GoRoute(path: '/funds', builder: (_, __) => const FundsScreen()),
    GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
    GoRoute(
      path: '/social',
      builder: (_, state) => SocialFeedScreen(filterTag: state.extra as SocialTag?),
    ),
    GoRoute(path: '/heatmap', builder: (_, __) => const HeatmapScreen()),
    GoRoute(
      path: '/stock/:symbol',
      builder: (_, state) => StockDetailScreen(symbol: state.pathParameters['symbol']!),
    ),
    GoRoute(
      path: '/crypto/:slug',
      builder: (_, state) => CryptoDetailScreen(slug: state.pathParameters['slug']!),
    ),
    ShellRoute(
      builder: (context, state, child) => RootShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/market', builder: (_, __) => const MarketScreen()),
        GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistScreen()),
        GoRoute(path: '/assistant', builder: (_, __) => const AssistantScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);
