class DictionaryCacheModel {
  final String word;
  final String definition;
  final List<String> synonyms;
  final String? phonetic;
  final DateTime cachedAt;

  DictionaryCacheModel({
    required this.word,
    required this.definition,
    required this.synonyms,
    this.phonetic,
    required this.cachedAt,
  });

  Map<String, dynamic> toMap() => {
        'word': word.toLowerCase(),
        'definition': definition,
        'synonyms': synonyms.join('|'),
        'phonetic': phonetic,
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory DictionaryCacheModel.fromMap(Map<String, dynamic> map) {
    return DictionaryCacheModel(
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      synonyms: map['synonyms'] != null && map['synonyms'].toString().isNotEmpty
          ? map['synonyms'].toString().split('|').where((s) => s.isNotEmpty).toList()
          : [],
      phonetic: map['phonetic'],
      cachedAt: map['cachedAt'] != null 
          ? DateTime.parse(map['cachedAt']) 
          : DateTime.now(),
    );
  }
}

class DictionaryResponse {
  final String word;
  final String definition;
  final List<String> synonyms;
  final String? phonetic;

  DictionaryResponse({
    required this.word,
    required this.definition,
    required this.synonyms,
    this.phonetic,
  });

  factory DictionaryResponse.fromJson(Map<String, dynamic> json) {
    String definition = '';
    List<String> synonyms = [];
    String? phonetic;

    // 1. Parse Phonetic
    if (json['phonetic'] != null && json['phonetic'].toString().isNotEmpty) {
      phonetic = json['phonetic'];
    } else if (json['phonetics'] is List) {
      for (final p in json['phonetics']) {
        if (p['text'] != null) {
          phonetic = p['text'];
          break;
        }
      }
    }

    // 2. Parse Meanings and Synonyms
    if (json['meanings'] is List) {
      for (final meaning in json['meanings']) {
        // Get the first available definition
        if (definition.isEmpty && 
            meaning['definitions'] is List &&
            meaning['definitions'].isNotEmpty) {
          definition = meaning['definitions'][0]['definition'];
        }

        // Collect all synonyms
        if (meaning['synonyms'] is List) {
          synonyms.addAll(List<String>.from(meaning['synonyms']));
        }

        if (meaning['definitions'] is List) {
          for (final d in meaning['definitions']) {
            if (d['synonyms'] is List) {
              synonyms.addAll(List<String>.from(d['synonyms']));
            }
          }
        }
      }
    }

    return DictionaryResponse(
      word: json['word'] ?? '',
      definition: definition.isNotEmpty ? definition : 'No definition available',
      synonyms: synonyms.toSet().toList(), // Remove duplicates
      phonetic: phonetic,
    );
  }
}
