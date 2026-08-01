import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chat_message.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/assistant_repository.dart';

final assistantRepositoryProvider = Provider((ref) => AssistantRepository());

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController(this._repo, this._ref) : super([]);
  final AssistantRepository _repo;
  final Ref _ref;

  Future<void> send(String text, {required String locale}) async {
    // Demo-level: let the assistant turn "فردا ساعت ۱۲ جلسه دارم" into a
    // real timeline task. See TaskController.tryParseTaskFromMessage for
    // the production-grade approach (server-side function calling).
    final createdTask = _ref.read(taskControllerProvider.notifier).tryParseTaskFromMessage(text);

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
    await for (final chunk in _repo.streamReply(message: text, history: history, locale: locale)) {
      buffer.write(chunk);
      state = [
        for (final m in state)
          if (m.id == assistantId) m.copyWith(content: buffer.toString(), isStreaming: true) else m,
      ];
    }
    state = [
      for (final m in state)
        if (m.id == assistantId) m.copyWith(isStreaming: false) else m,
    ];

    if (createdTask != null) {
      state = [
        ...state,
        ChatMessage(
          id: 'sys_${DateTime.now().microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          content: locale == 'en'
              ? '✅ Added to your timeline: ${createdTask.dueAt.hour}:00'
              : '✅ به تایم‌لاین شما اضافه شد: ساعت ${createdTask.dueAt.hour}',
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
