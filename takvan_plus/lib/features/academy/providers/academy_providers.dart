import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/academy.dart';

/// Placeholder catalog. Swap for a real CMS-backed repository
/// (e.g. `/academy/courses` on your backend) when you have real content.
/// Titles below are original, generic capital-market-education topics -
/// no text is copied from any blog or third-party source.
final academyCoursesProvider = Provider<List<AcademyCourse>>((ref) => const [
      AcademyCourse(id: 'c1', title: 'مبانی بورس برای تازه‌واردها', level: 'مقدماتی', lessonsCount: 8, progress: 0.4),
      AcademyCourse(id: 'c2', title: 'خواندن صورت‌های مالی', level: 'متوسط', lessonsCount: 12),
      AcademyCourse(id: 'c3', title: 'تحلیل بنیادی صنایع', level: 'متوسط', lessonsCount: 10),
      AcademyCourse(id: 'c4', title: 'مقدمات تحلیل تکنیکال', level: 'مقدماتی', lessonsCount: 9),
      AcademyCourse(id: 'c5', title: 'مدیریت ریسک و روانشناسی معامله‌گری', level: 'پیشرفته', lessonsCount: 7),
    ]);

final academyArticlesProvider = Provider<List<AcademyArticle>>((ref) => const [
      AcademyArticle(id: 'a1', title: 'صف خرید و صف فروش یعنی چه؟', category: 'مفاهیم پایه', readMinutes: 4),
      AcademyArticle(id: 'a2', title: 'تفاوت شاخص کل و شاخص هم‌وزن', category: 'مفاهیم پایه', readMinutes: 5),
      AcademyArticle(id: 'a3', title: 'P/E و EPS چگونه خوانده می‌شوند؟', category: 'تحلیل بنیادی', readMinutes: 6),
      AcademyArticle(id: 'a4', title: 'آشنایی با صندوق‌های سرمایه‌گذاری', category: 'ابزارهای مالی', readMinutes: 7),
      AcademyArticle(id: 'a5', title: 'مدیریت سرمایه در بازار نوسانی', category: 'روانشناسی معامله', readMinutes: 5),
    ]);
