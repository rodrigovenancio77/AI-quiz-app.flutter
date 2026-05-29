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
    Cria um quiz sobre o tema "${parsed.topic}" com ${parsed.questionCount} perguntas de escolha múltipla.
    Todo o conteúdo gerado (perguntas e opções de resposta) DEVE estar OBRIGATORIAMENTE em Português de Portugal (pt-pt).
    Devolve APENAS um array JSON válido de objetos. Não incluas blocos de código markdown, explicações, ou qualquer outro texto.
    Cada objeto deve ter exatamente estas chaves:
    - "question": uma string com o texto da pergunta em pt-pt
    - "options": um array de strings com as opções de resposta em pt-pt. Este array DEVE conter EXATAMENTE 2 OU EXATAMENTE 4 strings. Tenta incluir uma mistura de perguntas com 2 opções (verdadeiro/falso ou binárias) e com 4 opções.
    - "correctAnswerIndex": um número inteiro que representa o índice da opção correta (0 ou 1 para 2 opções; 0 a 3 para 4 opções).
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