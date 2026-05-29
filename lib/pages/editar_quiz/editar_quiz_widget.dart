import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'editar_quiz_model.dart';
export 'editar_quiz_model.dart';

class EditarQuizWidget extends StatefulWidget {
  const EditarQuizWidget({super.key});

  static String routeName = 'EditarQuiz';
  static String routePath = '/editarQuiz';

  @override
  State<EditarQuizWidget> createState() => _EditarQuizWidgetState();
}

class _EditarQuizWidgetState extends State<EditarQuizWidget> {
  late EditarQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // VARIÁVEIS DE ESTADO NOVAS
  String? quizId;
  Map<String, dynamic>? quizData;
  bool isLoading = true;
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditarQuizModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.titleController ??= TextEditingController();
    _model.titleFocusNode ??= FocusNode();
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmara'),
                onTap: () {
                  Navigator.pop(context);
                  _model.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _model.pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Apanha o ID do URL logo que a página é carregada
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      quizId = GoRouterState.of(context).uri.queryParameters['quizId'];
      _loadQuizData();
      isInit = true;
    }
  }

  // Vai buscar os dados do Quiz ao Firebase
  Future<void> _loadQuizData() async {
    if (quizId == null || quizId!.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        quizData = doc.data();
        
        // Carrega a duração (se já existir) ou estima 1 min por pergunta
        final duration = quizData?['durationMinutes'] as int?;
        final qCount = quizData?['questionCount'] as int? ?? 10;
        
        if (_model.textController!.text.isEmpty) {
          _model.textController!.text = (duration ?? qCount).toString();
        }
        
        if (_model.titleController!.text.isEmpty) {
          _model.titleController!.text = quizData?['title'] ?? 'Quiz sem Título';
        }
      }
    } catch (e) {
      print('Erro ao carregar o quiz: $e');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MOSTRA UM SPINNER ENQUANTO CARREGA OS DADOS
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBEBF0),
        body: Center(
          child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEBEBF0),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                           Stack(
                             alignment: Alignment.bottomRight,
                             children: [
                               ClipRRect(
                                 borderRadius: const BorderRadius.only(
                                   topLeft: Radius.circular(8.0),
                                   topRight: Radius.circular(8.0),
                                 ),
                                 child: _model.pickedImageBytes != null 
                                     ? Image.memory(
                                         _model.pickedImageBytes!,
                                         width: 344.0,
                                         height: 200.0,
                                         fit: BoxFit.cover,
                                       )
                                     : Image.network(
                                         quizData?['imageUrl'] ?? 'https://picsum.photos/seed/${quizId ?? '762'}/600',
                                         width: 344.0,
                                         height: 200.0,
                                         fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(
                                           width: 344.0,
                                           height: 200.0,
                                           color: Colors.grey[300],
                                           child: const Icon(Icons.image, size: 50),
                                         ),
                                       ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: FlutterFlowIconButton(
                                   borderColor: Colors.transparent,
                                   borderRadius: 30.0,
                                   borderWidth: 1.0,
                                   buttonSize: 40.0,
                                   fillColor: FlutterFlowTheme.of(context).primary,
                                   icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20.0),
                                   onPressed: () {
                                     _showImageSourceSheet(context);
                                   },
                                 ),
                               ),
                               if (_model.isUploading)
                                 Container(
                                   width: 344.0,
                                   height: 200.0,
                                   color: Colors.black45,
                                   child: Center(
                                     child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                                   ),
                                 ),
                             ],
                           ),
                           Container(
                             width: 344.0,
                             decoration: BoxDecoration(
                               color: FlutterFlowTheme.of(context).primary,
                               borderRadius: const BorderRadius.only(
                                 bottomLeft: Radius.circular(8.0),
                                 bottomRight: Radius.circular(8.0),
                               ),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.max,
                               mainAxisAlignment:
                                   MainAxisAlignment.spaceBetween,
                               children: [
                                 Expanded(
                                   child: Padding(
                                     padding: const EdgeInsets.all(12.0),
                                     child: TextFormField(
                                       controller: _model.titleController,
                                       focusNode: _model.titleFocusNode,
                                       style: FlutterFlowTheme.of(context).bodyMedium.override(
                                         font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                         color: FlutterFlowTheme.of(context).primaryBackground,
                                         fontSize: 18.0,
                                       ),
                                       decoration: InputDecoration(
                                         isDense: true,
                                         hintText: 'Título do Quiz',
                                         hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                           font: GoogleFonts.inter(),
                                           color: FlutterFlowTheme.of(context).primaryBackground.withOpacity(0.7),
                                         ),
                                         enabledBorder: InputBorder.none,
                                         focusedBorder: InputBorder.none,
                                       ),
                                     ),
                                   ),
                                 ),
                                 Padding(
                                   padding: const EdgeInsets.only(right: 12.0),
                                   child: Icon(
                                     Icons.edit_outlined,
                                     color: FlutterFlowTheme.of(context).info,
                                     size: 24.0,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: Text(
                                  'Duração (Minutos):',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      SizedBox(
                        width: 80.0,
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          textAlign: TextAlign.center,
                          validator: _model.textControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Espaçador para empurrar os botões para o fundo
                const SizedBox(height: 250.0),

                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          context.goNamed(UserQuizzesWidget.routeName);
                        },
                        text: 'Cancelar',
                        icon: const Icon(Icons.close_rounded, size: 15.0),
                        options: FFButtonOptions(
                          width: 150.0,
                          height: 40.0,
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.interTight(),
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: _model.isUploading ? null : () async {
                          if (quizId != null) {
                            setState(() => _model.isUploading = true);
                            
                            String? newImageUrl;
                            if (_model.pickedImageBytes != null) {
                              newImageUrl = await _model.uploadToImageBB();
                            }

                            final duration = int.tryParse(_model.textController!.text) ?? 10;
                            final updates = <String, dynamic>{
                              'durationMinutes': duration,
                              'title': _model.titleController!.text.isNotEmpty ? _model.titleController!.text : 'Quiz sem Título',
                            };
                            if (newImageUrl != null) {
                              updates['imageUrl'] = newImageUrl;
                            }

                            await FirebaseFirestore.instance
                                .collection('quizzes')
                                .doc(quizId)
                                .update(updates);

                            setState(() => _model.isUploading = false);

                            // 2. NAVEGA PARA A EDIÇÃO DAS PERGUNTAS E PASSA O ID
                            if (context.mounted) {
                              context.pushNamed(
                                EditarQuizPerguntasWidget.routeName,
                                queryParameters: {'quizId': quizId!},
                              );
                            }
                          }
                        },
                        text: _model.isUploading ? 'Aguardar...' : 'Continuar',
                        icon: const Icon(Icons.arrow_forward, size: 15.0),
                        options: FFButtonOptions(
                          width: 150.0,
                          height: 40.0,
                          iconAlignment: IconAlignment.end,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.interTight(),
                                color: Colors.white,
                              ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      // POP-UP DE CONFIRMAÇÃO PARA ELIMINAR QUIZ
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: const Text('Eliminar Quiz'),
                            content: const Text('Tem a certeza que deseja eliminar este quiz de forma permanente?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(alertDialogContext, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(alertDialogContext, true),
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      ) ?? false;

                      if (confirm && quizId != null) {
                        // APAGA O DOCUMENTO NO FIREBASE
                        await FirebaseFirestore.instance.collection('quizzes').doc(quizId).delete();
                        if (context.mounted) {
                          context.goNamed(UserQuizzesWidget.routeName);
                        }
                      }
                    },
                    text: 'Eliminar Quiz',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 40.0,
                      color: FlutterFlowTheme.of(context).error,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(),
                                color: Colors.white,
                              ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}