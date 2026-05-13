import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '/flutter_flow/flutter_flow_util.dart';

/// Spark-friendly: pass at build/run time, no Cloud Function.
/// `flutter run --dart-define=GEMINI_API_KEY=AIzaSyAXaJ9ZutYPnkRwjOmSa_eQBMkmRSWZvdg`
const String _kGeminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'AIzaSyAXaJ9ZutYPnkRwjOmSa_eQBMkmRSWZvdg',
);

Future<String?> geminiGenerateText(
  BuildContext context,
  String prompt,
) async {
  final model =
      GenerativeModel(model: 'gemini-2.5-flash', apiKey: _kGeminiApiKey);
  final content = [Content.text(prompt)];

  try {
    final response = await model.generateContent(content);
    return response.text;
  } catch (e) {
    showSnackbar(
      context,
      e.toString(),
    );
    return null;
  }
}

Future<String?> geminiCountTokens(
  BuildContext context,
  String prompt,
) async {
  final model =
      GenerativeModel(model: 'gemini-2.5-flash', apiKey: _kGeminiApiKey);
  final content = [Content.text(prompt)];

  try {
    final response = await model.countTokens(content);
    return response.totalTokens.toString();
  } catch (e) {
    showSnackbar(
      context,
      e.toString(),
    );
    return null;
  }
}

Future<Uint8List> loadImageBytesFromUrl(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}

Future<String?> geminiTextFromImage(
  BuildContext context,
  String prompt, {
  String? imageNetworkUrl = '',
  FFUploadedFile? uploadImageBytes,
}) async {
  assert(
    imageNetworkUrl != null || uploadImageBytes != null,
    'Either imageNetworkUrl or uploadImageBytes must be provided.',
  );

  final model =
      GenerativeModel(model: 'gemini-2.5-flash', apiKey: _kGeminiApiKey);
  final imageBytes = uploadImageBytes != null
      ? uploadImageBytes.bytes
      : await loadImageBytesFromUrl(imageNetworkUrl!);
  final content = [
    Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', imageBytes!),
    ])
  ];

  try {
    final response = await model.generateContent(content);
    return response.text;
  } catch (e) {
    showSnackbar(
      context,
      e.toString(),
    );
    return null;
  }
}
