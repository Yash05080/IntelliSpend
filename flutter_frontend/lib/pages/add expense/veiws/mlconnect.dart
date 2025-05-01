import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey = 'YOUR_API_KEY_HERE';

  /// Extracts *all* transactions from the OCR text as a JSON array.
  Future<String> extractAllTransactionsJson(String ocrText) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );

    final prompt = '''
You are a financial assistant. The user provides text extracted from a receipt, bill, or bank statement via OCR. Find every transaction in the text.  

**Output** ONLY a JSON array where each element has keys:  
- "title" (string),  
- "description" (string),  
- "amount" (number),  
- "date" (ISO8601 string, If no date is available, try to guess it or return current date/ todays date.),  
- "category" (- Use strictly these 9 categories: Food, Travel, Shopping, Entertainment, Recharge, Medical, Rent, Automobile, Other.).

Example output:
[
  {
    "title": "Starbucks Coffee",
    "description": "Latte Grande",
    "amount": 5.95,
    "date": "2025-04-01",
    "category": "Food"
  },
  {
    "title": "Uber Ride",
    "description": "Ride from airport",
    "amount": 23.40,
    "date": "2025-04-01",
    "category": "Travel"
  }
]

Text to analyze:
\"\"\"$ocrText\"\"\"
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '[]';
    } catch (e) {
      throw Exception('Gemini error: $e');
    }
  }
}
