import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary_models.dart';

class DictionaryService {

  Future<DictionaryResponse?> getDefinition(String word) async {
  try {
    final cleanWord = word
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '');

    print("🔍 WORD: $cleanWord");

    if (cleanWord.isEmpty) return null;

    final url = Uri.parse(
      'https://api.dictionaryapi.dev/api/v2/entries/en/$cleanWord',
    );

    print("🌐 URL: $url");

    final response = await http.get(url);

    print("📡 STATUS: ${response.statusCode}");
    print("📦 BODY: ${response.body}");

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);

    print("✅ PARSED DATA: $data");

    if (data is! List || data.isEmpty) return null;

    return DictionaryResponse.fromJson(data[0]);
  } catch (e) {
    print("❌ ERROR: $e");
    return null;
  }
}

}

