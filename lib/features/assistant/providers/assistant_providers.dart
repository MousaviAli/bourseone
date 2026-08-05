import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../models/chat_message.dart';
import '../../../models/task_item.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/assistant_repository.dart';

final assistantRepositoryProvider = Provider((ref) => AssistantRepository());

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController(this._repo, this._ref) : super([]);
  final AssistantRepository _repo;
  final Ref _ref;

  Future<void> send(String text, {required String locale}) async {
    // Offline/mock fallback: a small local regex parser handles simple
    // cases like "فردا ساعت ۱۲ جلسه دارم" without needing the backend
    // (see TaskController.tryParseTaskFromMessage). Once the real backend
    // is live (USE_MOCK_DATA=false), the AI itself detects tasks via
    // OpenAI function-calling server-side (see routes/assistant.js
    // `create_task` tool) and reports them through the stream instead -
    // so we skip the local guess there to avoid double-creating a task.
    TaskItem? locallyCreatedTask;
    if (AppConfig.useMockData) {
      locallyCreatedTask = _ref.read(taskControllerProvider.notifier).tryParseTaskFromMessage(text);
    }

    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );
    final assistantId = 'a_${DateTime.now().microsecondsSinceEpoch}';
    state = [
      ...state,
      userMsg,
      ChatMessage(
        id: assistantId,
        role: ChatRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      ),
    ];

    final history = state
        .where((m) => m.id != assistantId)
        .map((m) => {'role': m.role.name, 'content': m.content})
        .toList();

    final buffer = StringBuffer();
    TaskItem? aiCreatedTask;

    await for (final event in _repo.streamReply(message: text, history: history, locale: locale)) {
      switch (event) {
        case AssistantTextChunk(text: final chunk):
          buffer.write(chunk);
          state = [
            for (final m in state)
              if (m.id == assistantId) m.copyWith(content: buffer.toString(), isStreaming: true) else m,
          ];
        case AssistantTaskAction(title: final title, dueAt: final dueAt):
          final task = TaskItem(
            id: 't_${DateTime.now().microsecondsSinceEpoch}',
            title: title,
            dueAt: dueAt,
            createdByAssistant: true,
          );
          _ref.read(taskControllerProvider.notifier).add(task);
          aiCreatedTask = task;
      }
    }

    state = [
      for (final m in state)
        if (m.id == assistantId) m.copyWith(isStreaming: false) else m,
    ];

    final confirmedTask = aiCreatedTask ?? locallyCreatedTask;
    if (confirmedTask != null) {
      state = [
        ...state,
        ChatMessage(
          id: 'sys_${DateTime.now().microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          content: locale == 'en'
              ? '✅ Added to your timeline: "${confirmedTask.title}" - ${confirmedTask.dueAt.month}/${confirmedTask.dueAt.day} at ${confirmedTask.dueAt.hour}:00'
              : '✅ به تسک‌ها اضافه شد: «${confirmedTask.title}» - ${confirmedTask.dueAt.month}/${confirmedTask.dueAt.day} ساعت ${confirmedTask.dueAt.hour}',
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController(ref.watch(assistantRepositoryProvider), ref);
});

/// Suggested starter questions shown as chips above the input.
final suggestedQuestionsProvider = Provider<List<String>>((ref) {
  return [
    'وضعیت شاخص کل امروز چطوره؟',
    'فولاد رو تحلیل کن',
    'صف خرید یعنی چی؟',
    'بهترین صنایع این هفته کدومن؟',
  ];
});
