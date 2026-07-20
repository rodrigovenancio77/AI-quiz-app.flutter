import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'editar_quiz_perguntas_widget.dart' show EditarQuizPerguntasWidget;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditarQuizPerguntasModel
    extends FlutterFlowModel<EditarQuizPerguntasWidget> {
  // Variáveis para a imagem compatíveis com Web e Mobile
  XFile? pickedFileObj;
  Uint8List? pickedImageBytes;
  bool isUploading = false;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    textFieldFocusNode5?.dispose();
    textController5?.dispose();
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

    const String apiKey = 'YOUR_IMGBB_API_KEY_HERE';
    const String uploadUrl = 'https://api.imgbb.com/1/upload';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['key'] = apiKey;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pickedImageBytes!,
          filename: pickedFileObj!.name.isNotEmpty ? pickedFileObj!.name : 'question_image.jpg',
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
