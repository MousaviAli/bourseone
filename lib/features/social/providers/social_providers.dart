import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/social_post.dart';

/// Local-only community feed for now (posts live in memory / this session).
/// Wire to `/social/posts` REST endpoints on your backend for a real,
/// shared, persistent feed across users.
class SocialFeedController extends StateNotifier<List<SocialPost>> {
  SocialFeedController()
      : super([
          SocialPost(
            id: 'p1',
            authorName: 'سرمایه‌گذار۱۲',
            content: 'فولاد امروز با حجم بالا صف خرید تشکیل داد، به نظر می‌رسه روند صعودی ادامه‌دار باشه.',
            tag: const SocialTag(type: SocialTagType.symbol, value: 'فولاد'),
            sentiment: PostSentiment.bullish,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likes: 14,
          ),
          SocialPost(
            id: 'p2',
            authorName: 'تحلیلگر_بازار',
            content: 'صنعت بانک این هفته فشار فروش داره، احتیاط کنید تا شفافیت گزارش‌های جدید مشخص بشه.',
            tag: const SocialTag(type: SocialTagType.industry, value: 'بانک'),
            sentiment: PostSentiment.bearish,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            likes: 8,
          ),
          SocialPost(
            id: 'p3',
            authorName: 'مانی_بورسی',
            content: 'شاخص کل امروز در محدوده مقاومتی مهمی قرار داره، رد شدنش می‌تونه سیگنال خوبی باشه.',
            tag: const SocialTag(type: SocialTagType.marketIndex, value: 'tedpix'),
            sentiment: PostSentiment.neutral,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            likes: 21,
          ),
        ]);

  void addPost(SocialPost post) {
    state = [post, ...state];
  }

  void toggleLike(String id) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(likes: p.likes + 1) else p,
    ];
  }

  List<SocialPost> forTag(SocialTag tag) =>
      state.where((p) => p.tag.type == tag.type && p.tag.value == tag.value).toList();
}

final socialFeedControllerProvider =
    StateNotifierProvider<SocialFeedController, List<SocialPost>>((ref) {
  return SocialFeedController();
});
