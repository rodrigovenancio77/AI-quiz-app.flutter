import '/flutter_flow/flutter_flow_util.dart';
import 'editar_perfil_widget.dart' show EditarPerfilWidget;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditarPerfilModel extends FlutterFlowModel<EditarPerfilWidget> {
  final formKey = GlobalKey<FormState>();
  
  // Variáveis para a imagem compatíveis com Web e Mobile
  XFile? pickedFileObj;
  Uint8List? pickedImageBytes;
  bool isUploading = false;

  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  late bool passwordVisibility1;
  String? Function(BuildContext, String?)? textController3Validator;

  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  late bool passwordVisibility2;
  String? Function(BuildContext, String?)? textController4Validator;

  @override
  void initState(BuildContext context) {
    passwordVisibility1 = false;
    passwordVisibility2 = false;
  }

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
  }

  // Permite ao utilizador escolher uma imagem (Web & Mobile)
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      pickedFileObj = pickedFile;
      // Lê os bytes (Isto funciona na Web perfeitamente!)
      pickedImageBytes = await pickedFile.readAsBytes();
      // ignore: use_build_context_synchronously
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
      
      // Usa fromBytes que é 100% suportado em Flutter Web
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pickedImageBytes!,
          filename: pickedFileObj!.name.isNotEmpty ? pickedFileObj!.name : 'profile.jpg',
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