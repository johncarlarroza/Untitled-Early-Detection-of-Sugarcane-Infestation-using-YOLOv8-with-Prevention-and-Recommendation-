
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class ChatbotService {
  late final GenerativeModel _model;

  // Replace this with your actual Gemini API key.
  static const String _apiKey = 'AIzaSyCXhwrz1fFODzlFd0Ky7E2g3u7IiHcP76M';

  static const String _systemPrompt = '''
You are CocoaBot, a knowledgeable and friendly cacao farming assistant.

Your purpose is to help farmers understand cacao pests,
diseases, crop management, prevention, and treatment.

COMMUNICATION STYLE:
- Be concise, clear, professional, and kind.
- Speak naturally to adults, not like a child.
- Answer simple questions in 1 to 3 sentences.
- Provide additional details only when necessary.
- Avoid unnecessary greetings, emojis, and exaggerated encouragement.
- Give direct, practical, and useful recommendations.
- Do not use asterisks in your responses.

LANGUAGE SUPPORT:
- If the user speaks Hiligaynon (Ilonggo), respond in Hiligaynon.
- If the user speaks Filipino, respond in Filipino.
- If the user speaks English, respond in English.
- If the user mixes languages, respond naturally using the same languages.
- Use natural, conversational Hiligaynon rather than overly formal translations.

AREAS OF EXPERTISE:
- Cocoa Mealybug
- Cocoa Mirid Bug
- Cocoa Pod Borer
- Cocoa Phytophthora / Black Pod Rot
- Cacao cultivation and maintenance
- Pest and disease management
- Soil management, pruning, and irrigation
- Prevention and mitigation techniques
- Sustainable cacao farming practices

IMPORTANT:
- Prioritize accurate agricultural information.
- Never invent diagnoses or guarantee treatments.
- If symptoms are unclear, ask for additional details.
- Recommend safe and practical management methods.
- If pesticides are discussed, recommend following local
  agricultural guidelines and product label instructions.
''';

  ChatbotService() {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY') {
      throw StateError(
        'Please configure your Gemini API key in chatbot_service.dart.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final message = userMessage.trim();

      if (message.isEmpty) {
        return 'Please enter your question.';
      }

      final response = await _model.generateContent([
        Content.text(message),
      ]);

      final cleanText = (response.text ?? '')
          .replaceAll('*', '')
          .trim();

      if (cleanText.isEmpty) {
        return 'I could not generate a response. Please try again.';
      }

      return cleanText;
    } catch (e) {
      debugPrint('COCOABOT ERROR: $e');

      final error = e.toString().toLowerCase();

      if (error.contains('api_key_invalid') ||
          error.contains('api key not valid')) {
        return 'The AI service is not configured correctly. '
            'Please contact the administrator.';
      }

      if (error.contains('quota') ||
          error.contains('resource_exhausted') ||
          error.contains('429')) {
        return 'CocoaBot has reached its current usage limit. '
            'Please try again later.';
      }

      if (error.contains('network') ||
          error.contains('socket')) {
        return 'Unable to connect. Please check your internet connection.';
      }

      return 'CocoaBot is temporarily unavailable. '
          'Please try again later.';
    }
  }
}
