import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticks every few seconds so mock data feels "live" when the phone has
/// internet (per user request) - providers below watch this to refresh
/// on an interval instead of only on manual pull-to-refresh. Once the real
/// backend is wired in, this becomes a natural place to instead reconnect
/// a WebSocket for true push updates.
final marketTickerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 6), (i) => i);
});
