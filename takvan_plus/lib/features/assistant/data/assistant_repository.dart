import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

/// Streams chat completions from YOUR backend at POST {apiBaseUrl}/assistant/chat
/// (see takvan_plus_backend/routes/assistant.js), which itself calls the
/// OpenAI Chat Completions API with the secret key that lives only on the
/// server. The Flutter app NEVER holds an OpenAI key.
class AssistantRepository {
  final Dio _dio = ApiClient.instance.dio;

  Stream<String> streamReply({
    required String message,
    required List<Map<String, String>> history,
    required String locale,
  }) async* {
    if (AppConfig.useMockData) {
      // Local canned response so the UI/UX can be built and demoed before
      // the backend + OpenAI key are configured.
      final mock = locale == 'fa'
          ? 'این یک پاسخ نمایشی است. برای فعال‌سازی پاسخ واقعی هوش مصنوعی، بک‌اند را با کلید OpenAI خودتان دیپلوی و USE_MOCK_DATA را false کنید. سوال شما: "$message"'
          : 'This is a demo reply. Deploy the backend with your OpenAI key and set USE_MOCK_DATA to false to get real answers. Your question: "$message"';
      for (final chunk in mock.split(' ')) {
        await Future.delayed(const Duration(milliseconds: 40));
        yield '$chunk ';
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
      // Backend sends newline-delimited SSE-style "data: <token>\n\n" frames.
      for (final line in text.split('\n')) {
        if (line.startsWith('data: ')) {
          yield line.substring(6);
        }
      }
    }
  }
}
