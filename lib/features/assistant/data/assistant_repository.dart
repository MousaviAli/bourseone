import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

/// One event out of the assistant stream: either a piece of reply text,
/// or a structured task the backend's AI decided to create (see
/// takvan_plus_backend/routes/assistant.js `create_task` function-calling
/// tool).
sealed class AssistantStreamEvent {}

class AssistantTextChunk extends AssistantStreamEvent {
  final String text;
  AssistantTextChunk(this.text);
}

class AssistantTaskAction extends AssistantStreamEvent {
  final String title;
  final DateTime dueAt;
  AssistantTaskAction(this.title, this.dueAt);
}

/// Streams chat completions from YOUR backend at POST {apiBaseUrl}/assistant/chat
/// (see takvan_plus_backend/routes/assistant.js), which itself calls the
/// OpenAI Chat Completions API with the secret key that lives only on the
/// server. The Flutter app NEVER holds an OpenAI key.
class AssistantRepository {
  final Dio _dio = ApiClient.instance.dio;

  Stream<AssistantStreamEvent> streamReply({
    required String message,
    required List<Map<String, String>> history,
    required String locale,
  }) async* {
    if (AppConfig.useMockData) {
      // Local canned response so the UI/UX can be built and demoed before
      // the backend + OpenAI key are configured. Real AI-driven task
      // creation only happens through the real backend (see
      // TaskController.tryParseTaskFromMessage for the offline/mock
      // client-side fallback used instead in this mode).
      final mock = locale == 'fa'
          ? 'این یک پاسخ نمایشی است. برای فعال‌سازی پاسخ واقعی هوش مصنوعی، بک‌اند را با کلید OpenAI خودتان دیپلوی و USE_MOCK_DATA را false کنید. سوال شما: "$message"'
          : 'This is a demo reply. Deploy the backend with your OpenAI key and set USE_MOCK_DATA to false to get real answers. Your question: "$message"';
      for (final chunk in mock.split(' ')) {
        await Future.delayed(const Duration(milliseconds: 40));
        yield AssistantTextChunk('$chunk ');
      }
      return;
    }

    final response = await _dio.post<ResponseBody>(
      '/assistant/chat',
      data: {
        'message': message,
        'history': history,
        'locale': locale,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream;
    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      // Backend sends newline-delimited frames: "data: <token>" for reply
      // text, or "task: <json>" when it detected a schedulable task.
      for (final line in text.split('\n')) {
        if (line.startsWith('data: ')) {
          yield AssistantTextChunk(line.substring(6));
        } else if (line.startsWith('task: ')) {
          try {
            final json = jsonDecode(line.substring(6)) as Map<String, dynamic>;
            final title = json['title'] as String?;
            final dueIso = json['dueIso'] as String?;
            if (title != null && dueIso != null) {
              final dueAt = DateTime.tryParse(dueIso);
              if (dueAt != null) yield AssistantTaskAction(title, dueAt);
            }
          } catch (_) {
            // ignore malformed task payloads - never break the chat reply
          }
        }
      }
    }
  }
}
