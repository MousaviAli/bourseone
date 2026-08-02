import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/social_post.dart';
import '../../../../widgets/glass_card.dart';
import '../../../market/providers/market_providers.dart';
import '../../providers/social_providers.dart';

/// Community feed. Pass [filterTag] to show only posts about one
/// symbol/industry/index (used from stock/crypto detail screens);
/// leave null to show the full feed (used from the main nav / dashboard).
class SocialFeedScreen extends ConsumerWidget {
  final SocialTag? filterTag;
  const SocialFeedScreen({super.key, this.filterTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPosts = ref.watch(socialFeedControllerProvider);
    final posts = filterTag == null
        ? allPosts
        : allPosts.where((p) => p.tag.type == filterTag!.type && p.tag.value == filterTag!.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(filterTag == null ? 'نظرات و تحلیل‌های کاربران' : 'نظرات درباره ${filterTag!.value}'),
      ),
      body: posts.isEmpty
          ? const Center(
              child: Text('هنوز پستی ثبت نشده - اولین نفر باشید!',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (_, i) => _PostCard(post: posts[i]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        onPressed: () => _showComposeSheet(context, ref),
        child: const Icon(Icons.edit_outlined, color: Colors.black),
      ),
    );
  }

  void _showComposeSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    SocialTagType tagType = filterTag?.type ?? SocialTagType.symbol;
    String? tagValue = filterTag?.value;
    PostSentiment sentiment = PostSentiment.neutral;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (sheetContext, ref, __) => StatefulBuilder(
          builder: (sheetContext, setState) => Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتشار تحلیل یا نظر', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'تحلیل یا نظرتون رو بنویسید...'),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: SocialTagType.values.map((t) {
                    final label = switch (t) {
                      SocialTagType.symbol => 'نماد',
                      SocialTagType.industry => 'صنعت',
                      SocialTagType.index => 'شاخص',
                    };
                    return ChoiceChip(
                      label: Text(label),
                      selected: tagType == t,
                      onSelected: (_) => setState(() { tagType = t; tagValue = null; }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                if (tagType == SocialTagType.symbol)
                  Consumer(builder: (_, ref, __) {
                    final symbols = ref.watch(allSymbolsProvider);
                    return symbols.when(
                      data: (list) => DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('انتخاب نماد'),
                        value: tagValue,
                        items: list.map((s) => DropdownMenuItem(value: s.symbol, child: Text(s.symbol))).toList(),
                        onChanged: (v) => setState(() => tagValue = v),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  })
                else if (tagType == SocialTagType.industry)
                  Consumer(builder: (_, ref, __) {
                    final heatmap = ref.watch(heatmapProvider);
                    return heatmap.when(
                      data: (map) => DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('انتخاب صنعت'),
                        value: tagValue,
                        items: map.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                        onChanged: (v) => setState(() => tagValue = v),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  })
                else
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('انتخاب شاخص'),
                    value: tagValue,
                    items: const [
                      DropdownMenuItem(value: 'tedpix', child: Text('شاخص کل')),
                      DropdownMenuItem(value: 'equalWeight', child: Text('شاخص هم‌وزن')),
                    ],
                    onChanged: (v) => setState(() => tagValue = v),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('صعودی'),
                      selected: sentiment == PostSentiment.bullish,
                      selectedColor: AppColors.neonGreen.withOpacity(0.2),
                      onSelected: (_) => setState(() => sentiment = PostSentiment.bullish),
                    ),
                    ChoiceChip(
                      label: const Text('نزولی'),
                      selected: sentiment == PostSentiment.bearish,
                      selectedColor: AppColors.red.withOpacity(0.2),
                      onSelected: (_) => setState(() => sentiment = PostSentiment.bearish),
                    ),
                    ChoiceChip(
                      label: const Text('خنثی'),
                      selected: sentiment == PostSentiment.neutral,
                      onSelected: (_) => setState(() => sentiment = PostSentiment.neutral),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty || tagValue == null) return;
                    ref.read(socialFeedControllerProvider.notifier).addPost(
                          SocialPost(
                            id: 'p_${DateTime.now().microsecondsSinceEpoch}',
                            authorName: 'شما',
                            content: controller.text.trim(),
                            tag: SocialTag(type: tagType, value: tagValue!),
                            sentiment: sentiment,
                            createdAt: DateTime.now(),
                          ),
                        );
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('انتشار'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final SocialPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentimentColor = switch (post.sentiment) {
      PostSentiment.bullish => AppColors.neonGreen,
      PostSentiment.bearish => AppColors.red,
      PostSentiment.neutral => AppColors.blue,
    };
    final sentimentLabel = switch (post.sentiment) {
      PostSentiment.bullish => 'صعودی',
      PostSentiment.bearish => 'نزولی',
      PostSentiment.neutral => 'خنثی',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.cardElevated,
                  child: Text(post.authorName.characters.first,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      Text('# ${post.tag.value}', style: const TextStyle(fontSize: 10.5, color: AppColors.blue)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sentimentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sentimentLabel, style: TextStyle(fontSize: 10, color: sentimentColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 13, height: 1.6)),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () => ref.read(socialFeedControllerProvider.notifier).toggleLike(post.id),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${post.likes}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
