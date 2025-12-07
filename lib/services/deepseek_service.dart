import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soul_plan/models/questionnaire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DeepSeekService {
  static const String _apiKey = 'sk-3b5847f8e6514ab5b7d9c481281e6a67';
  static const String _apiUrl = 'https://api.deepseek.com/v1/chat/completions';

  List<String> _previousSuggestions = [];
  DeepSeekService();

  Future<T> _executeWithRetry<T>(Future<T> Function() operation,
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final result = await operation();
        return result;
      } catch (e) {
        attempts++;
        print('Operation failed (attempt $attempts): $e');

        if (attempts >= maxRetries) {
          rethrow;
        }

        final backoffDuration = Duration(milliseconds: 300 * (1 << attempts));
        await Future.delayed(backoffDuration);
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }

  Future<Map<String, dynamic>> _callDeepSeekAPI(String prompt,
      {double temperature = 0.7}) async {
    try {
      // Check if running on web and warn about CORS limitations
      if (kIsWeb) {
        print('⚠️ Running on web - DeepSeek API may be blocked by CORS. Please use mobile app for full functionality.');
      }
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': temperature,
          'max_tokens': 4000,
        }),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          if (kIsWeb) {
            throw Exception('Web platform limitation: DeepSeek API blocked by browser CORS policy. Please use the mobile app (Android/iOS) for AI-powered features.');
          }
          throw Exception('Request timeout - API did not respond within 90 seconds');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'DeepSeek API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DeepSeek API call failed: $e');
      if (kIsWeb && e.toString().contains('Failed to fetch')) {
        throw Exception('Web platform limitation: AI features require mobile app. CORS blocks browser API calls. Please use Android or iOS app.');
      }
      rethrow;
    }
  }

  Future<String?> regenerateDescription(
      String suggestion, String language) async {
    final title = suggestion.split('\n')[0];
    final cleanTitle = title.replaceAll(RegExp(r'[*#\(\)\[\]]'), '').trim();
    final shortTitle = cleanTitle.length > 40
        ? cleanTitle.substring(0, 40) + '...'
        : cleanTitle;

    final prompt =
        '''Generate a concise, well-structured description in $language for this date idea: "${shortTitle}"

Format your response EXACTLY as follows with these 5 sections (use these exact section names):

INTRODUCTION:
Write 2-3 engaging sentences introducing the date idea. Keep it brief and exciting.

STEP-BY-STEP GUIDE:
Provide 5-6 clear, numbered steps to follow. Each step should be 1-2 sentences.

SPECIAL TOUCHES:
List 3-4 special touches to make the date memorable. Use bullet points.

CONVERSATION STARTERS:
Suggest 3 conversation topics or bonding activities. Make them specific and relevant.

PREPARATION & ADAPTATIONS:
Include required preparations and 2-3 adaptation tips for different preferences.

IMPORTANT FORMATTING RULES:
- Do NOT use markdown formatting (no #, *, _, etc.)
- Use plain text only
- Use "SECTION NAME:" format for headers (all caps)
- Keep each section brief and focused
- Ensure ALL five sections are included with content
- Use simple bullet points with "-" only
- Do not include numbers in section names
- Do not include any additional sections''';

    try {
      return await _executeWithRetry(() async {
        final response = await _callDeepSeekAPI(prompt);
        String description = response['choices'][0]['message']['content'] ?? '';
        description = _cleanupDescription(description);
        description = _ensureAllSections(description);

        if (_hasMissingSections(description)) {
          print(
              "Detected empty sections, trying one more time with a more specific prompt");
          return await _regenerateWithMoreSpecificPrompt(shortTitle, language);
        }

        if (description.isNotEmpty) {
          return '$shortTitle\n$description';
        }
        return null;
      });
    } catch (e) {
      print('Error regenerating description: $e');
      return null;
    }
  }

  bool _hasMissingSections(String description) {
    final sections = [
      'INTRODUCTION:',
      'STEP-BY-STEP GUIDE:',
      'SPECIAL TOUCHES:',
      'CONVERSATION STARTERS:',
      'PREPARATION & ADAPTATIONS:'
    ];

    for (int i = 0; i < sections.length; i++) {
      String currentSection = sections[i];
      String nextSection = i < sections.length - 1 ? sections[i + 1] : "";
      String content =
          _extractSectionContent(description, currentSection, nextSection);

      if (content.trim().isEmpty ||
          content.contains("Content for this section will be available soon") ||
          content.contains("will be available soon")) {
        return true;
      }
    }
    return false;
  }

  String _extractSectionContent(
      String description, String sectionHeader, String nextSectionHeader) {
    int startIndex = description.indexOf(sectionHeader);
    if (startIndex == -1) return "";

    startIndex += sectionHeader.length;
    int endIndex;

    if (nextSectionHeader.isNotEmpty) {
      endIndex = description.indexOf(nextSectionHeader, startIndex);
      if (endIndex == -1) endIndex = description.length;
    } else {
      endIndex = description.length;
    }

    return description.substring(startIndex, endIndex).trim();
  }

  String _cleanupDescription(String description) {
    String cleaned = description
        .replaceAll(RegExp(r'#\s+'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'_'), '')
        .replaceAll(RegExp(r'\$\d+'), '');

    cleaned = cleaned
        .replaceAll(RegExp(r'introduction\s*:?\s*\n', caseSensitive: false),
            'INTRODUCTION:\n')
        .replaceAll(
            RegExp(r'step[s\-]*(by)*[- ]*step[s]* guide\s*:?\s*\n',
                caseSensitive: false),
            'STEP-BY-STEP GUIDE:\n')
        .replaceAll(RegExp(r'special touches\s*:?\s*\n', caseSensitive: false),
            'SPECIAL TOUCHES:\n')
        .replaceAll(
            RegExp(r'conversation starters\s*:?\s*\n', caseSensitive: false),
            'CONVERSATION STARTERS:\n')
        .replaceAll(
            RegExp(r'preparation[s]* (&|and) adaptation[s]*\s*:?\s*\n',
                caseSensitive: false),
            'PREPARATION & ADAPTATIONS:\n');

    return cleaned;
  }

  Future<String?> _regenerateWithMoreSpecificPrompt(
      String title, String language) async {
    final moreSpecificPrompt =
        '''I need COMPLETE content for a date idea called "${title}" in $language.

YOU MUST include ALL of these 5 sections with DETAILED content for each:

INTRODUCTION:
[2-3 sentences introducing the date idea - BE SPECIFIC about what makes this date special]

STEP-BY-STEP GUIDE:
[5-6 numbered steps, each 1-2 sentences - BE SPECIFIC about what to do]
1. First step...
2. Second step...
3. Third step...
4. Fourth step...
5. Fifth step...

SPECIAL TOUCHES:
[4 bullet points with special touches - BE SPECIFIC about how to make it memorable]
- First special touch...
- Second special touch...
- Third special touch...
- Fourth special touch...

CONVERSATION STARTERS:
[3 specific conversation topics related to this date]
- First conversation topic...
- Second conversation topic...
- Third conversation topic...

PREPARATION & ADAPTATIONS:
[List of preparations and 3 adaptation tips - BE SPECIFIC]
- Preparation item 1...
- Adaptation for different preferences...
- Adaptation for different moods...
- Adaptation for different settings...

CRITICAL: Include ALL sections with COMPLETE content. Do NOT use markdown formatting.''';

    final response = await _callDeepSeekAPI(moreSpecificPrompt);
    String description = response['choices'][0]['message']['content'] ?? '';
    description = _cleanupDescription(description);
    description = _ensureAllSections(description);

    if (description.isNotEmpty) {
      return '$title\n$description';
    }
    return null;
  }

  String _ensureAllSections(String description) {
    final sections = [
      'INTRODUCTION:',
      'STEP-BY-STEP GUIDE:',
      'SPECIAL TOUCHES:',
      'CONVERSATION STARTERS:',
      'PREPARATION & ADAPTATIONS:'
    ];

    for (String section in sections) {
      if (!description.contains(section)) {
        description +=
            '\n\n$section\nContent for this section will be available soon.';
      }
    }

    return description;
  }

  Future<List<String>> getDateSuggestions(
      Questionnaire user, Questionnaire partner,
      {required String language}) async {
    try {
      // Analyze sentiments and create profiles
      final userSentiment = await analyzeSentiment(user);
      final partnerSentiment = await analyzeSentiment(partner);
      final combinedSentiment =
          _combineSentiments(userSentiment, partnerSentiment);
      final userProfile = _createProfile(user);
      final partnerProfile = _createProfile(partner);

      // Get language preference
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';

      // Format previous suggestions to avoid repetition
      String previousInfo = '';
      if (_previousSuggestions.isNotEmpty) {
        previousInfo = '''
Previously suggested ideas (DO NOT repeat these):
${_previousSuggestions.map((s) => "- $s").join('\n')}

''';
      }

      // Create the prompt for DeepSeek
      final prompt =
          '''As a creative date planning expert, design 3 NEW and UNIQUE date experiences in $languageCode:

$previousInfo
Person 1 Profile:
${userProfile.join('\n')}
Sentiment: ${json.encode(userSentiment)}

Person 2 Profile:
${partnerProfile.join('\n')}
Sentiment: ${json.encode(partnerSentiment)}

Combined Vibe: ${json.encode(combinedSentiment)}

For EACH of the 3 date ideas, structure it EXACTLY like this (use plain text, NO markdown):

[CREATIVE TITLE - max 5 words]

INTRODUCTION:
Write a warm, engaging 2-3 sentence introduction that sets the scene.

STEP-BY-STEP GUIDE:
1. [First step with clear action]
2. [Second step]
3. [Third step]
4. [Fourth step]
5. [Fifth step - the grand finale]

SPECIAL TOUCHES:
- [First special touch to make it memorable]
- [Second special touch]
- [Third special touch]

CONVERSATION STARTERS:
- [First conversation topic or bonding activity]
- [Second conversation topic]
- [Third conversation topic]

PREPARATION & ADAPTATIONS:
What to prepare: [List items needed]
Adaptations: [Ways to adjust for weather, budget, or preferences]

---

RULES:
- Use ONLY plain text (no *, #, _, etc.)
- Keep titles SHORT (max 5 words)
- ALL 5 sections must have real content (no placeholders)
- Separate each date with "---"
- Make each date COMPLETELY different from previous ideas''';

      // Execute the API call with retry logic
      return await _executeWithRetry(() async {
        final response = await _callDeepSeekAPI(prompt);
        final responseText = response['choices'][0]['message']['content'] ?? '';

        // Parse and clean up suggestions
        var suggestions = _parseDateSuggestions(responseText);

        // Clean up titles and format
        suggestions = suggestions.map((suggestion) {
          final parts = suggestion.split('\n');
          if (parts.isEmpty) return suggestion;

          // Clean up the title
          String title = parts[0]
              .trim()
              .replaceAll(RegExp(r'[*#\(\)\[\]]'), '')
              .replaceAll(RegExp(r'\$\d+'), '')
              .trim();

          // Limit title length
          if (title.length > 40) {
            title = title.substring(0, 40);
          }

          // Format the description
          final description =
              parts.length > 1 ? parts.sublist(1).join('\n').trim() : '';
          return '$title\n\n$description';
        }).toList();

        // Filter out any suggestions that match previous ones
        suggestions = suggestions.where((suggestion) {
          final title = suggestion.split('\n')[0].trim().toLowerCase();
          return !_previousSuggestions
              .any((prev) => prev.toLowerCase() == title);
        }).toList();

        // If we don't have enough suggestions, throw error to retry
        if (suggestions.isEmpty) {
          throw Exception('No unique suggestions generated');
        }

        // Store these suggestions in our history to avoid repetition
        if (suggestions.isNotEmpty) {
          _previousSuggestions
              .addAll(suggestions.map((idea) => idea.split('\n')[0].trim()));
          // Limit the history size to avoid memory issues
          if (_previousSuggestions.length > 20) {
            _previousSuggestions =
                _previousSuggestions.sublist(_previousSuggestions.length - 20);
          }
        }

        return suggestions.take(3).toList();
      }, maxRetries: 2);
    } catch (e) {
      print('Error generating date suggestions: $e');
      throw Exception('Unable to generate date suggestions. Please try again.');
    }
  }

  Future<String> getAtHomeDateAdvice(String suggestion, String language) async {
    final prompt =
        '''As an AI dating expert, provide detailed advice in $language for an at-home date based on the following suggestion: "$suggestion"

Consider the following aspects:
1. Adaptability: Suggest ways to adjust the activities based on energy levels and moods.
2. Balance: Include both active and relaxing elements in the date.
3. Communication: Incorporate opportunities for both conversation and comfortable silences.
4. Personalization: Offer ideas to tailor the experience to each partner's preferences.
5. Resource utilization: Focus on activities that can be done with items typically found at home.

Structure your response as follows:
#  : [Restate or adapt the suggestion for an at-home setting]
## Description
[Brief, engaging description of the at-home date idea]
## Specific Activities
1. [First activity]
2. [Second activity]
3. [Third activity]
4. [Fourth activity]
5. [Fifth activity]
## Tips to Make It Special
- [First tip]
- [Second tip]
- [Third tip]
- [Fourth tip]
- [Fifth tip]
## Adaptations
- For different energy levels: [Suggestion]
- For varying moods: [Suggestion]
- For conversation preferences: [Suggestion]

Ensure your advice is creative, romantic, and tailored to make the at-home date memorable and enjoyable for both partners, regardless of their current states and without relying on external venues or services.''';

    try {
      return await _executeWithRetry(() async {
        final response = await _callDeepSeekAPI(prompt);
        return response['choices'][0]['message']['content'] ??
            'Unable to generate advice.';
      });
    } catch (e) {
      print('Error generating at-home date advice: $e');
      return 'Error: Unable to generate advice. Please try again later.';
    }
  }

  Future<Map<String, dynamic>> analyzeSentiment(
      Questionnaire questionnaire) async {
    final prompt =
        '''Analyze the sentiment and emotions in the following responses:
${questionnaire.answers.map((answer) => "- $answer").join("\n")}

Provide a summary of the overall mood, dominant emotions, and any notable patterns.
Also, rate the overall positivity on a scale of 1-10.

Format the response as JSON with the following structure:
{
  "overallMood": "string",
  "dominantEmotions": ["string"],
  "notablePatterns": ["string"],
  "positivityScore": number
}

IMPORTANT: Return ONLY the raw JSON without any markdown formatting, code blocks, or additional text.''';

    try {
      return await _executeWithRetry(() async {
        final response = await _callDeepSeekAPI(prompt, temperature: 0.3);
        String responseText =
            response['choices'][0]['message']['content'] ?? '{}';
        responseText = _extractJsonFromResponse(responseText);

        try {
          final jsonResponse = json.decode(responseText);
          return jsonResponse;
        } catch (parseError) {
          print('JSON parsing error: $parseError');
          print('Attempted to parse: $responseText');
          return {
            "overallMood": "neutral",
            "dominantEmotions": ["calm"],
            "notablePatterns": ["none"],
            "positivityScore": 5
          };
        }
      });
    } catch (e) {
      print('Error analyzing sentiment: $e');
      return {
        "overallMood": "neutral",
        "dominantEmotions": ["calm"],
        "notablePatterns": ["none"],
        "positivityScore": 5
      };
    }
  }

  String _extractJsonFromResponse(String response) {
    final codeBlockRegex = RegExp(r'```(?:json)?\s*({[\s\S]*?})\s*```');
    final match = codeBlockRegex.firstMatch(response);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? response;
    }

    final jsonRegex = RegExp(r'{[\s\S]*}');
    final jsonMatch = jsonRegex.firstMatch(response);
    if (jsonMatch != null) {
      return jsonMatch.group(0) ?? response;
    }

    return response;
  }

  List<String> _parseDateSuggestions(String responseText) {
    final suggestions = <String>[];

    // Split by "---" separator or by numbered items followed by uppercase titles
    final parts = responseText.split('---');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      // Remove leading number if present (e.g., "1. " or "2. ")
      String content = trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '');

      // Split into lines
      final lines = content
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      // First line is the title
      String title = lines[0].replaceAll(RegExp(r'[*#\(\)\[\]]'), '').trim();

      // Limit title length
      if (title.length > 40) {
        title = title.substring(0, 40).trim();
      }

      // Rest is the description
      if (lines.length > 1) {
        final description = lines.sublist(1).join('\n');
        final formattedDescription = _formatDescriptionSections(description);
        suggestions.add('$title\n\n$formattedDescription');
      } else {
        suggestions.add(title);
      }
    }

    // If no suggestions found with "---" separator, try old regex method as fallback
    if (suggestions.isEmpty) {
      final regex = RegExp(r'^\d+\.\s*(.+?)(?=\n\d+\.\s*|\Z)',
          multiLine: true, dotAll: true);
      final matches = regex.allMatches(responseText);

      for (final match in matches) {
        final suggestion = match.group(1)?.trim() ?? '';
        if (suggestion.isNotEmpty) {
          final lines = suggestion
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
          if (lines.isEmpty) continue;

          final title = lines[0].replaceAll(RegExp(r'[*#\(\)\[\]]'), '').trim();

          if (lines.length > 1) {
            final description = lines.sublist(1).join('\n');
            final formattedDescription =
                _formatDescriptionSections(description);
            suggestions.add('$title\n\n$formattedDescription');
          } else {
            suggestions.add(title);
          }
        }
      }
    }

    return suggestions;
  }

  String _formatDescriptionSections(String description) {
    final sectionHeaders = [
      'INTRODUCTION:',
      'STEP-BY-STEP GUIDE:',
      'SPECIAL TOUCHES:',
      'CONVERSATION STARTERS:',
      'PREPARATION & ADAPTATIONS:'
    ];

    String cleaned = description
        .replaceAll(RegExp(r'#\s+'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'_'), '')
        .replaceAll(RegExp(r'\$\d+'), '');

    cleaned = cleaned
        .replaceAll(RegExp(r'introduction\s*:?\s*\n', caseSensitive: false),
            'INTRODUCTION:\n')
        .replaceAll(
            RegExp(r'step[s\-]*(by)*[- ]*step[s]* guide\s*:?\s*\n',
                caseSensitive: false),
            'STEP-BY-STEP GUIDE:\n')
        .replaceAll(RegExp(r'special touches\s*:?\s*\n', caseSensitive: false),
            'SPECIAL TOUCHES:\n')
        .replaceAll(
            RegExp(r'conversation starters\s*:?\s*\n', caseSensitive: false),
            'CONVERSATION STARTERS:\n')
        .replaceAll(
            RegExp(r'preparation[s]* (&|and) adaptation[s]*\s*:?\s*\n',
                caseSensitive: false),
            'PREPARATION & ADAPTATIONS:\n');

    for (String section in sectionHeaders) {
      if (!cleaned.contains(section)) {
        cleaned +=
            '\n\n$section\nContent for this section will be available soon.';
      }
    }

    return cleaned;
  }

  String getSimplifiedMood(Questionnaire questionnaire) {
    Map<String, List<String>> moodKeywords = {
      'Energized': [
        'energetic',
        'active',
        'lively',
        'enthusiastic',
        'vigorous',
        'full of energy',
        'fun',
        'adventurous',
        'exciting'
      ],
      'Calm': [
        'relaxed',
        'peaceful',
        'tranquil',
        'serene',
        'composed',
        'quiet',
        'low-key',
        'casual',
        'just okay'
      ],
      'Stressed': [
        'anxious',
        'worried',
        'tense',
        'overwhelmed',
        'pressured',
        'rough',
        'exhausting'
      ],
      'Excited': [
        'thrilled',
        'eager',
        'animated',
        'elated',
        'jubilant',
        'great',
        'new and exciting'
      ],
      'Tired': [
        'exhausted',
        'fatigued',
        'weary',
        'drained',
        'sleepy',
        'low on energy'
      ]
    };

    // First check the direct answers
    if (questionnaire.answers.isNotEmpty) {
      String firstAnswer = questionnaire.answers[0].toLowerCase();
      if (firstAnswer == 'energized') return 'Energized';
      if (firstAnswer == 'calm') return 'Calm';
      if (firstAnswer == 'tired') return 'Tired';
      if (firstAnswer == 'stressed') return 'Stressed';
      if (firstAnswer == 'excited') return 'Excited';
      if (firstAnswer == 'pensive') return 'Calm';
      if (firstAnswer == 'down') return 'Tired';
    }

    // Then do a more comprehensive analysis
    Map<String, int> moodCounts = {
      'Energized': 0,
      'Calm': 0,
      'Stressed': 0,
      'Excited': 0,
      'Tired': 0
    };

    for (String answer in questionnaire.answers) {
      String lowerAnswer = answer.toLowerCase();
      for (var entry in moodKeywords.entries) {
        if (entry.value.any((keyword) => lowerAnswer.contains(keyword))) {
          moodCounts[entry.key] = (moodCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    // Check for energy level question specifically
    if (questionnaire.answers.length >= 3) {
      String energyAnswer = questionnaire.answers[2].toLowerCase();
      if (energyAnswer.contains('full of energy')) {
        moodCounts['Energized'] = (moodCounts['Energized'] ?? 0) + 2;
      } else if (energyAnswer.contains('low on energy')) {
        moodCounts['Tired'] = (moodCounts['Tired'] ?? 0) + 2;
      }
    }

    // Get the dominant mood
    String dominantMood =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return moodCounts[dominantMood]! > 0 ? dominantMood : 'Calm';
  }

  Map<String, dynamic> _combineSentiments(
      Map<String, dynamic> sentiment1, Map<String, dynamic> sentiment2) {
    final combinedMood = _averageMood(
        sentiment1['overallMood'] as String? ?? 'neutral',
        sentiment2['overallMood'] as String? ?? 'neutral');

    final combinedEmotions = [
      ...(sentiment1['dominantEmotions'] as List<dynamic>? ?? []),
      ...(sentiment2['dominantEmotions'] as List<dynamic>? ?? [])
    ].whereType<String>().toSet().toList();

    final combinedPatterns = [
      ...(sentiment1['notablePatterns'] as List<dynamic>? ?? []),
      ...(sentiment2['notablePatterns'] as List<dynamic>? ?? [])
    ].whereType<String>().toSet().toList();

    final combinedScore = ((sentiment1['positivityScore'] as num? ?? 5) +
            (sentiment2['positivityScore'] as num? ?? 5)) /
        2;

    return {
      'overallMood': combinedMood,
      'dominantEmotions': combinedEmotions,
      'notablePatterns': combinedPatterns,
      'positivityScore': combinedScore,
    };
  }

  String _averageMood(String? mood1, String? mood2) {
    final moodMap = {
      'very negative': 1,
      'negative': 2,
      'neutral': 3,
      'positive': 4,
      'very positive': 5,
    };

    final score1 = moodMap[mood1?.toLowerCase() ?? 'neutral'] ?? 3;
    final score2 = moodMap[mood2?.toLowerCase() ?? 'neutral'] ?? 3;
    final averageScore = (score1 + score2) / 2;

    if (averageScore < 1.5) return 'very negative';
    if (averageScore < 2.5) return 'negative';
    if (averageScore < 3.5) return 'neutral';
    if (averageScore < 4.5) return 'positive';
    return 'very positive';
  }

  List<String> _createProfile(Questionnaire q) {
    final profile = <String>[];
    for (int i = 0; i < q.answers.length; i++) {
      if (i < q.questions.length) {
        profile.add('${q.questions[i].question}: ${q.answers[i]}');
      }
    }
    return profile;
  }

  /// Match date suggestions based on both partners' favorite selections
  /// Returns the matched date or an AI-generated compromise
  Future<Map<String, dynamic>> matchDateSuggestions({
    required List<Map<String, dynamic>> initiatorFavorites,
    required List<Map<String, dynamic>> partnerFavorites,
    required String location,
  }) async {
    try {
      // Check for direct overlap first
      final overlappingDates =
          _findOverlappingDates(initiatorFavorites, partnerFavorites);

      if (overlappingDates.isNotEmpty) {
        // Both selected the same date - perfect match!
        final matchedDate = overlappingDates.first;
        return {
          'matchType': 'perfect',
          'date': matchedDate,
          'reasoning':
              'You both chose this date! It\'s a perfect match that combines your shared interests and excitement.',
        };
      }

      // No overlap - need AI to create a compromise
      return await _generateCompromiseDate(
        initiatorFavorites,
        partnerFavorites,
        location,
      );
    } catch (e) {
      print('Error in matchDateSuggestions: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _findOverlappingDates(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    final overlapping = <Map<String, dynamic>>[];

    for (final date1 in list1) {
      for (final date2 in list2) {
        // Check if titles match (case-insensitive)
        if (_areDatesEqual(date1, date2)) {
          overlapping.add(date1);
          break;
        }
      }
    }

    return overlapping;
  }

  bool _areDatesEqual(Map<String, dynamic> date1, Map<String, dynamic> date2) {
    final title1 = (date1['title'] ?? '').toString().toLowerCase().trim();
    final title2 = (date2['title'] ?? '').toString().toLowerCase().trim();
    return title1 == title2 && title1.isNotEmpty;
  }

  Future<Map<String, dynamic>> _generateCompromiseDate(
    List<Map<String, dynamic>> initiatorFavorites,
    List<Map<String, dynamic>> partnerFavorites,
    String location,
  ) async {
    // Build prompt with both partners' preferences
    final initiatorTitles =
        initiatorFavorites.map((d) => d['title']).join(', ');
    final partnerTitles = partnerFavorites.map((d) => d['title']).join(', ');

    final initiatorDetails = initiatorFavorites.map((d) {
      return '''
Title: ${d['title']}
Description: ${d['description'] ?? 'N/A'}
Activities: ${(d['activities'] as List?)?.join(', ') ?? 'N/A'}
Venue: ${d['venue'] ?? 'N/A'}''';
    }).join('\n\n');

    final partnerDetails = partnerFavorites.map((d) {
      return '''
Title: ${d['title']}
Description: ${d['description'] ?? 'N/A'}
Activities: ${(d['activities'] as List?)?.join(', ') ?? 'N/A'}
Venue: ${d['venue'] ?? 'N/A'}''';
    }).join('\n\n');

    final prompt =
        '''You are a relationship expert tasked with creating the perfect compromise date idea.

CONTEXT:
Location: $location

Partner 1's Top Choices:
$initiatorTitles

Partner 1's Details:
$initiatorDetails

Partner 2's Top Choices:
$partnerTitles

Partner 2's Details:
$partnerDetails

TASK:
Create a single, unique date idea that thoughtfully combines elements from BOTH partners' preferences. This should feel like a genuine compromise that respects both sets of choices while creating something new and exciting.

IMPORTANT REQUIREMENTS:
1. The compromise date MUST incorporate specific elements from BOTH partners' selections
2. Explain clearly how it combines their preferences
3. Make it feasible in the specified location
4. Keep the magic and excitement of both sets of choices
5. Provide practical details like venue suggestions and activities

FORMAT YOUR RESPONSE AS VALID JSON (no markdown, no code blocks):
{
  "title": "Creative compromise date title",
  "description": "2-3 engaging sentences about this compromise date and why it works for both",
  "activities": ["activity1", "activity2", "activity3"],
  "venue": "Specific venue suggestion in $location",
  "estimatedCost": "Budget range (e.g., \$\$-\$\$\$)",
  "duration": "Time range (e.g., 3-4 hours)",
  "reasoning": "Detailed explanation of how this date combines elements from both partners' preferences. Be specific about what came from Partner 1's choices and what came from Partner 2's choices."
}

Return ONLY the JSON object, no additional text or formatting.''';

    final response = await _callDeepSeekAPI(prompt, temperature: 0.8);
    final content = response['choices'][0]['message']['content'];

    try {
      // Parse the JSON response
      final compromiseDate = json.decode(content);

      return {
        'matchType': 'compromise',
        'date': compromiseDate,
        'reasoning': compromiseDate['reasoning'] ??
            'This date combines the best of both your preferences!',
      };
    } catch (e) {
      print('Error parsing compromise date JSON: $e');
      print('Raw content: $content');

      // Fallback: create a simple compromise from the response
      return {
        'matchType': 'compromise',
        'date': {
          'title': 'Custom Compromise Date',
          'description': content.length > 500
              ? content.substring(0, 500) + '...'
              : content,
          'activities': [
            'Explore together',
            'Share experiences',
            'Create memories'
          ],
          'venue': location,
          'estimatedCost': '\$\$-\$\$\$',
          'duration': '3-4 hours',
        },
        'reasoning':
            'This unique date combines elements that both of you will enjoy!',
      };
    }
  }
}
