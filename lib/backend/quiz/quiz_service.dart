import 'dart:convert';
import 'package:flutter/material.dart';
import 'quiz_repository.dart';
// TODO: Adjust this import to point to where your gemini.dart file is
import '../gemini/gemini.dart'; 

class ParsedQuizInput {
  const ParsedQuizInput({
    required this.topic,
    required this.questionCount,
  });

  final String topic;
  final int questionCount;
}

class QuizService {
  QuizService({QuizRepository? repository})
      : _repository = repository ?? QuizRepository();

  final QuizRepository _repository;

  ParsedQuizInput parsePrompt(String rawInput) {
    final normalized = rawInput.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      throw ArgumentError('Digite um tema e o numero de perguntas.');
    }

    final match = RegExp(r'^(.*?)[,\s]+(\d{1,2})$').firstMatch(normalized);
    if (match == null) {
      throw ArgumentError('Formato invalido. Exemplo: Historia de Portugal 10');
    }

    final topic = (match.group(1) ?? '').trim();
    final count = int.tryParse(match.group(2) ?? '');
    if (topic.isEmpty || count == null) {
      throw ArgumentError('Nao foi possivel interpretar o tema e o numero.');
    }

    if (count < 1 || count > 40) {
      throw ArgumentError('O numero de perguntas deve estar entre 1 e 40.');
    }

    return ParsedQuizInput(topic: topic, questionCount: count);
  }

  // UPDATED: Now orchestrates the AI Generation & DB insertion
  Future<String> createQuizFromPrompt({
    required BuildContext context, // Added Context to pass to Gemini
    required String ownerUid,
    required String prompt,
  }) async {
    if (ownerUid.isEmpty) {
      throw ArgumentError('Utilizador nao autenticado.');
    }

    final parsed = parsePrompt(prompt);

    // 1. Create the base quiz document
    final quizId = await _repository.createQuiz(
      QuizCreateRequest(
        ownerUid: ownerUid,
        title: parsed.topic,
        topic: parsed.topic,
        requestedQuestionCount: parsed.questionCount,
        sourcePrompt: prompt,
      ),
    );

    // 2. Prompt Gemini for structured JSON questions
    final aiPrompt = '''
    Create a quiz about "${parsed.topic}" with ${parsed.questionCount} multiple-choice questions.
    Return ONLY a valid JSON array of objects. Do not include markdown codeblocks, explanations, or any other text.
    Each object must exactly have these keys:
    - "question": a string with the question text
    - "options": an array of strings for the answer options. This array MUST contain EITHER exactly 2 OR exactly 4 strings. Try to include a mix of 2-option (true/false or binary) and 4-option questions.
    - "correctAnswerIndex": an integer representing the index of the correct option (0 or 1 for 2 options; 0 to 3 for 4 options).
    ''';

    final aiResponse = await geminiGenerateText(context, aiPrompt);

    if (aiResponse == null || aiResponse.isEmpty) {
      throw Exception('A Inteligência Artificial falhou ao gerar as perguntas.');
    }

    // 3. Clean up potential markdown formatting and parse JSON
    try {
      String cleanJson = aiResponse.trim();
      // Even when instructed not to, Gemini sometimes wraps with ```json ... ```
      if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
      if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
      if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);

      final List<dynamic> parsedData = jsonDecode(cleanJson.trim());
      final questions = parsedData.map((e) => e as Map<String, dynamic>).toList();

      // 4. Save to subcollection
      await _repository.saveQuestions(quizId, questions);
      
    } catch (e) {
       throw Exception('Erro ao processar as perguntas da AI: $e');
    }

    return quizId;
  }
}