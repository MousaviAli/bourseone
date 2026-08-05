enum SocialTagType { symbol, industry, marketIndex }

class SocialTag {
  final SocialTagType type;
  final String value; // e.g. "فولاد" or "فلزات اساسی" or "tedpix"
  const SocialTag({required this.type, required this.value});
}

enum PostSentiment { bullish, bearish, neutral }

class SocialPost {
  final String id;
  final String authorName;
  final String content;
  final SocialTag tag;
  final PostSentiment sentiment;
  final DateTime createdAt;
  final int likes;

  const SocialPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.tag,
    required this.sentiment,
    required this.createdAt,
    this.likes = 0,
  });

  SocialPost copyWith({int? likes}) => SocialPost(
        id: id,
        authorName: authorName,
        content: content,
        tag: tag,
        sentiment: sentiment,
        createdAt: createdAt,
        likes: likes ?? this.likes,
      );
}
