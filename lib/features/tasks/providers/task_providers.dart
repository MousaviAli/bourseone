import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/task_item.dart';

class TaskController extends StateNotifier<List<TaskItem>> {
  TaskController() : super([]);

  void add(TaskItem task) {
    state = [...state, task]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  void toggleDone(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(isDone: !t.isDone) else t,
    ];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  static const _weekdays = {
    'شنبه': DateTime.saturday,
    'یکشنبه': DateTime.sunday,
    'دوشنبه': DateTime.monday,
    'سه‌شنبه': DateTime.tuesday,
    'سه شنبه': DateTime.tuesday,
    'چهارشنبه': DateTime.wednesday,
    'پنج‌شنبه': DateTime.thursday,
    'پنجشنبه': DateTime.thursday,
    'جمعه': DateTime.friday,
  };

  static String _normalizeDigits(String s) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final faIdx = fa.indexOf(ch);
      final arIdx = ar.indexOf(ch);
      if (faIdx != -1) {
        buf.write(faIdx);
      } else if (arIdx != -1) {
        buf.write(arIdx);
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  /// Resolves the target *date* (day/month/year) implied by the message:
  /// امروز، فردا، پس‌فردا، or a weekday name (شنبه..جمعه، next occurrence).
  /// Returns null if no date cue was found.
  DateTime? _resolveDate(String message) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (message.contains('پس‌فردا') || message.contains('پس فردا')) {
      return today.add(const Duration(days: 2));
    }
    if (message.contains('فردا')) {
      return today.add(const Duration(days: 1));
    }
    if (message.contains('امروز')) {
      return today;
    }
    for (final entry in _weekdays.entries) {
      if (message.contains(entry.key)) {
        var delta = (entry.value - today.weekday) % 7;
        // "شنبه" said on a Saturday almost always means *this* Saturday,
        // not next week - only push forward if the day already passed
        // relative to "now" in a same-day sense; keep delta as-is (0..6).
        return today.add(Duration(days: delta));
      }
    }
    return null;
  }

  /// Resolves the target *hour* (0-23) implied by the message, handling
  /// "ساعت ۹"، "ساعت 9:30"، "ساعت ۳ عصر"، "ساعت ۹ شب"، "ظهر" etc.
  /// Returns null if no time cue was found (caller should default).
  int? _resolveHour(String message) {
    final normalized = _normalizeDigits(message);

    if (RegExp(r'ظهر').hasMatch(normalized) && !RegExp(r'\d').hasMatch(normalized)) {
      return 12;
    }

    final match = RegExp(r'ساعت\s*(\d{1,2})(?::(\d{2}))?').firstMatch(normalized);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!) ?? 9;
    final isPm = RegExp(r'(عصر|شب)').hasMatch(normalized);
    final isAm = RegExp(r'صبح').hasMatch(normalized);

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return hour.clamp(0, 23);
  }

  /// Looks for scheduling intent in a chat message (relative day + time)
  /// and, if found, creates a task automatically - this is what lets the
  /// assistant say "باشه، یادآوری‌ات رو ساختم". Understands: امروز، فردا،
  /// پس‌فردا، نام روز هفته (دوشنبه و...)، و زمان به شکل‌های «ساعت ۹»،
  /// «ساعت ۹:۳۰»، «ساعت ۳ عصر»، «ظهر».
  ///
  /// This is a client-side fallback. The backend can additionally use
  /// OpenAI function-calling (see routes/assistant.js `create_task` tool)
  /// for a more robust, model-driven version of the same idea - when the
  /// backend sends a `task:` action line, ChatController creates the task
  /// from that instead of re-parsing locally (see assistant_providers.dart).
  TaskItem? tryParseTaskFromMessage(String message) {
    final date = _resolveDate(message);
    if (date == null) return null;

    final hour = _resolveHour(message) ?? 9;
    final due = DateTime(date.year, date.month, date.day, hour);

    final task = TaskItem(
      id: 't_${DateTime.now().microsecondsSinceEpoch}',
      title: message,
      dueAt: due,
      createdByAssistant: true,
    );
    add(task);
    return task;
  }
}

final taskControllerProvider = StateNotifierProvider<TaskController, List<TaskItem>>((ref) {
  return TaskController();
});
