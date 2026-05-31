import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'editar_quiz_widget.dart' show EditarQuizWidget;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditarQuizModel extends FlutterFlowModel<EditarQuizWidget> {
  // Variáveis para a imagem compatíveis com Web e Mobile
  XFile? pickedFileObj;
  Uint8List? pickedImageBytes;
  bool isUploading = false;

  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  FocusNode? titleFocusNode;
  TextEditingController? titleController;
  String? Function(BuildContext, String?)? titleControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    titleFocusNode?.dispose();
    titleController?.dispose();
  }

  // Permite ao utilizador escolher uma imagem (Web & Mobile)
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      pickedFileObj = pickedFile;
      pickedImageBytes = await pickedFile.readAsBytes();
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    }
  }

  // Faz o upload para o ImageBB
  Future<String?> uploadToImageBB() async {
    if (pickedFileObj == null || pickedImageBytes == null) return null;

    const String apiKey = 'f6410412e00acf455624e31a0f54d46b';
    const String uploadUrl = 'https://api.imgbb.com/1/upload';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['key'] = apiKey;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pickedImageBytes!,
          filename: pickedFileObj!.name.isNotEmpty ? pickedFileObj!.name : 'quiz_image.jpg',
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['data']['url'] as String?;
      } else {
        print('Erro no ImageBB: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Erro de rede: $e');
      return null;
    }
  }
}
