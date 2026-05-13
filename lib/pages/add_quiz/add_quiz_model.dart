import '/flutter_flow/flutter_flow_util.dart';
import 'add_quiz_widget.dart' show AddQuizWidget;
import 'package:flutter/material.dart';

class AddQuizModel extends FlutterFlowModel<AddQuizWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
