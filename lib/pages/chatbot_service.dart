import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  late final GenerativeModel _model;

  static const String _systemPrompt = '''
You are an agricultural expert specializing in sugarcane cultivation and pest management.

You provide helpful information about:
- Sugarcane plant varieties and their characteristics
- Pest identification and control measures
- Disease mitigation and management strategies
- Best practices for sugarcane farming

Always provide clear, practical advice based on agricultural best practices.
''';

  ChatbotService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // ✅ FIXED MODEL
      apiKey: 'AIzaSyC-XUt_aPBMMrpezXswCOvmaEbZkBck3_Q',
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _model.generateContent([
        Content.text('$_systemPrompt\n\nUser: $userMessage'),
      ]);

      return response.text ?? 'No response received';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
