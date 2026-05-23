import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/env_config.dart';
import '../../domain/entities/chat_turn.dart';
import '../../domain/exceptions/chat_failure.dart';

class GroqChatDatasource {
  GroqChatDatasource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  static const _systemPrompt = '''
You are Respondi, a friendly AI health assistant for first aid, symptoms, and emergency guidance.
Give clear, practical, concise answers.
Always remind users this is not a substitute for professional medical care.
For emergencies, tell them to contact local emergency services immediately.
''';

  Future<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
  }) async {
    final apiKey = EnvConfig.groqApiKey;
    if (apiKey.isEmpty) {
      throw const ChatFailure(
        'Groq API key is missing. Add GROQ_API_KEY to your .env file.',
      );
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      for (final turn in history)
        {'role': turn.role, 'content': turn.content},
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.6,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw ChatFailure(_parseError(response));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const ChatFailure('Groq returned an empty response.');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const ChatFailure('Groq returned an empty message.');
    }

    return content.trim();
  }

  String _parseError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Fall through to generic message.
    }
    return 'Groq request failed (${response.statusCode}).';
  }
}
