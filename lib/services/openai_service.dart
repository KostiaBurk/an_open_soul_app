import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = '***REMOVED***proj-7ujr68azq-RBImAo5m0WDex6ILhOKxmCVn3G49wS4qiDl2H1ANd845DsWAg8YW1XsoPwqJHHpiT3BlbkFJJv25atnxK4pP_5p6R4cldruQiE-XRYPUiqnOLMK59-P5qjenbw27fjuFxqMg17Wr4RyMIhTEMA';

 Future<String> sendChat(List<Map<String, String>> chatHistory, {String model = "gpt-3.5-turbo"}) async {
  const url = 'https://api.openai.com/v1/chat/completions';

  // ✅ Маппинг локального имени модели на API-имя
  String mapModelName(String selected) {
    switch (selected) {
      case 'gpt-3.0':
        return 'gpt-3.5-turbo';
      case 'gpt-3.5':
        return 'gpt-3.5-turbo';
      case 'gpt-4o':
        return 'gpt-4o';
      default:
        return 'gpt-3.5-turbo';
    }
  }

  final mappedModel = mapModelName(model);

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": mappedModel,
        "messages": chatHistory,
        "temperature": 0.8,
      }),
    ).timeout(const Duration(seconds: 20));

    log('📥 Response status: ${response.statusCode}');
    log('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else if (response.statusCode == 401) {
      return 'Invalid API key. Please check your OpenAI credentials.';
    } else if (response.statusCode == 429) {
      return 'You have reached the request limit. Please try again later.';
    } else if (response.statusCode == 400 && response.body.contains('billing')) {
      return 'Billing not enabled. Please add a payment method at OpenAI.';
    } else {
      return 'Unexpected error: ${response.statusCode}. Please try again.';
    }
  } catch (e, stack) {
    log('❌ Exception during OpenAI request: $e', stackTrace: stack);
    return 'Error connecting to Nova. Check your internet or try again later.';
  }
}


}
