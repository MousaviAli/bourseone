class AcademyCourse {
  final String id;
  final String title;
  final String level; // مقدماتی | متوسط | پیشرفته
  final int lessonsCount;
  final double progress; // 0..1

  const AcademyCourse({
    required this.id,
    required this.title,
    required this.level,
    required this.lessonsCount,
    this.progress = 0,
  });
}

class AcademyArticle {
  final String id;
  final String title;
  final String category;
  final int readMinutes;

  const AcademyArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.readMinutes,
  });
}
