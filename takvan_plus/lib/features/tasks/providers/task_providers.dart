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

  /// Very small heuristic parser: looks for "فردا"/"امروز" + "ساعت N" in a
  /// chat message and, if found, creates a task automatically - this is
  /// what lets the assistant say "باشه، یادآوری‌ات رو ساختم".
  ///
  /// For production-quality intent parsing, do this server-side instead:
  /// have routes/assistant.js use OpenAI function-calling (tools param)
  /// with a `create_task(title, due_iso)` function, and stream a
  /// structured action back to the app alongside the chat reply.
  TaskItem? tryParseTaskFromMessage(String message) {
    final hasTomorrow = message.contains('فردا');
    final hasToday = message.contains('امروز');
    final hourMatch = RegExp(r'ساعت\s*(\d{1,2})').firstMatch(message);
    if ((hasTomorrow || hasToday) && hourMatch != null) {
      final hour = int.tryParse(hourMatch.group(1)!) ?? 9;
      final now = DateTime.now();
      final due = DateTime(now.year, now.month, now.day + (hasTomorrow ? 1 : 0), hour);
      final task = TaskItem(
        id: 't_${DateTime.now().microsecondsSinceEpoch}',
        title: message,
        dueAt: due,
        createdByAssistant: true,
      );
      add(task);
      return task;
    }
    return null;
  }
}

final taskControllerProvider = StateNotifierProvider<TaskController, List<TaskItem>>((ref) {
  return TaskController();
});
