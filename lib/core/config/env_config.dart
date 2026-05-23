import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get groqApiKey => dotenv.env['GROQ_API_KEY']?.trim() ?? '';

  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;
}
