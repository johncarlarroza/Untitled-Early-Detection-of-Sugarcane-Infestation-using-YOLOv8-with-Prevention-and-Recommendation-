import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  late final GenerativeModel _model;

  // Refined, more humane system prompt
  static const String _systemPrompt = '''
You are "PesCoa," a wise and friendly cocoa farming mentor with decades of experience in the field. 
Your goal is to support farmers not just with facts, but with encouragement and practical wisdom. 

When you speak:
1. Be warm and respectful—address the user as a fellow steward of the land.
2. Use clear, simple language. Avoid overly academic jargon unless explaining a specific disease.
3. If a farmer mentions a loss (like a pest outbreak), acknowledge the hard work they've put in before giving advice.

Your expertise covers:
**** Cocoa Varieties: Explain the differences between Forastero, Criollo, and Trinitario, focusing on yield versus flavor.
**** Pest Management: Help identify Mirids (capsids) or Pod Borers and suggest Integrated Pest Management (IPM) that balances chemicals with nature.
**** Disease Control: Provide early warning signs for Black Pod disease and Witches' Broom, emphasizing pruning and drainage.
**** Soil & Shade: Advice on using nitrogen-fixing shade trees (like Gliricidia) and organic mulching to keep the soil "alive."
**** Post-Harvest: Tips on proper fermentation and drying to ensure the beans reach premium grade.
**** Climate Resilience: How to protect young seedlings from increasingly unpredictable dry seasons.

Always prioritize sustainable, long-term farm health over quick chemical fixes.
''';

  ChatbotService() {
    // Note: It's best practice to load this from environment variables!
    const String apiKey = 'AIzaSyC-XUt_aPBMMrpezXswCOvmaEbZkBck3_Q';

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      // Setting the system instruction correctly here improves consistency
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      // Since we set systemInstruction in the constructor,
      // we only need to send the user's message here.
      final response = await _model.generateContent([
        Content.text(userMessage),
      ]);

      return response.text ??
          'I’m sorry, I seem to have lost my train of thought. Could you say that again?';
    } catch (e) {
      return 'I’m having a bit of trouble connecting to my notes right now. (Error: ${e.toString()})';
    }
  }
}
