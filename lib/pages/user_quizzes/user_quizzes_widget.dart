import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// NEW IMPORTS FOR FIRESTORE AND AUTH
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/quiz/quiz_repository.dart';

import 'user_quizzes_model.dart';
export 'user_quizzes_model.dart';

class UserQuizzesWidget extends StatefulWidget {
  const UserQuizzesWidget({super.key});

  static String routeName = 'UserQuizzes';
  static String routePath = '/userQuizzes';

  @override
  State<UserQuizzesWidget> createState() => _UserQuizzesWidgetState();
}

class _UserQuizzesWidgetState extends State<UserQuizzesWidget> {
  late UserQuizzesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Initialize repository
  final _quizRepository = QuizRepository();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserQuizzesModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEBEBF0),
          automaticallyImplyLeading: false,
          title: Text(
            'Os Meus Quizzes',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  ),
                  color: Colors.black,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 200.0,
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Pesquisar',
                            hintStyle: FlutterFlowTheme.of(context).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          validator: _model.textControllerValidator.asValidator(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.search,
                        color: FlutterFlowTheme.of(context).info,
                        size: 24.0,
                      ),
                      onPressed: () {
                        // Lógica de pesquisa futura
                      },
                    ),
                  ],
                ),
              ),
              
              // --- BOTÃO ADICIONAR ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          context.pushNamed(AddQuizWidget.routeName);
                        },
                        text: 'Adicionar Quiz',
                        icon: const Icon(Icons.add, size: 15.0),
                        options: FFButtonOptions(
                          height: 40.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(),
                                color: Colors.white,
                              ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- LISTA DE QUIZZES (STREAM BUILDER) ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _quizRepository.getUserQuizzesStream(currentUserUid),
                  builder: (context, snapshot) {
                    // Estado de Carregamento
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Estado de Erro
                    if (snapshot.hasError) {
                      print('Erro no Firestore: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'Erro ao carregar os quizzes.\nVerifica a tua ligação.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      );
                    }

                    // Extrair apenas os DADOS REAIS
                    final allQuizzes = snapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['docId'] = doc.id; 
                      return data;
                    }).toList() ?? [];

                    // ORDENAR OS DADOS DO MAIS RECENTE PARA O MAIS ANTIGO AQUI (Dart)
                    allQuizzes.sort((a, b) {
                      final aTime = a['createdAt'] as Timestamp?;
                      final bTime = b['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });

                    // Se o utilizador não tiver quizzes
                    if (allQuizzes.isEmpty) {
                      return Center(
                        child: Text(
                          'Ainda não criaste nenhum quiz.\nClica em "Adicionar Quiz" para começar!',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(allQuizzes.length, (index) {
                          final quizData = allQuizzes[index];
                          
                          // Variáveis para a UI
                          final docId = quizData['docId'];
                          final title = quizData['title'] ?? 'Sem Título';
                          final questionCount = quizData['questionCount'] ?? 0;
                          final isPublic = quizData['isPublic'] ?? false;
                          // Gera uma imagem aleatória baseada no ID do Quiz para ser sempre a mesma para esse Quiz
                          final imageUrl = quizData['imageUrl'] ?? 'https://picsum.photos/seed/$docId/600';

                          return Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                            child: Container(
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  context.pushNamed(
                                    ResponderQuizWidget.routeName,
                                    queryParameters: {'quizId': docId},
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        bottomLeft: Radius.circular(8.0),
                                      ),
                                      child: Image.network(
                                        imageUrl,
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Título e Switch de Publico/Privado
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    FaIcon(FontAwesomeIcons.lock, color: FlutterFlowTheme.of(context).primaryText, size: 14.0),
                                                    const SizedBox(width: 4.0),
                                                    SizedBox(
                                                      width: 28.0,
                                                      height: 18.0,
                                                      child: custom_widgets.HalfSizeSwitch(
                                                        width: 28.0,
                                                        height: 18.0,
                                                        initialValue: isPublic,
                                                        activeColor: FlutterFlowTheme.of(context).primary,
                                                        onChanged: (newValue) async {
                                                          await FirebaseFirestore.instance.collection('quizzes').doc(docId).update({'isPublic': newValue});
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Icon(Icons.public, color: FlutterFlowTheme.of(context).primaryText, size: 14.0),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // Detalhes (Questões, Tempo)
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text('$questionCount questões', style: FlutterFlowTheme.of(context).bodySmall),
                                                const SizedBox(width: 8.0),
                                                SizedBox(height: 12.0, child: VerticalDivider(thickness: 1.0, color: FlutterFlowTheme.of(context).alternate)),
                                                const SizedBox(width: 8.0),
                                                Text('${quizData['durationMinutes'] ?? '--'} min', style: FlutterFlowTheme.of(context).bodySmall),
                                              ],
                                            ),
                                            // Botões de Ação
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFFFFD11E),
                                                  icon: Icon(Icons.edit_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                  onPressed: () async { context.pushNamed(EditarQuizWidget.routeName, queryParameters: {'quizId': docId}); },
                                                ),
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFF42436F),
                                                  icon: Icon(Icons.share_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                  onPressed: () {},
                                                ),
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFF6FC073),
                                                  icon: Icon(Icons.remove_red_eye_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                  onPressed: () async { context.pushNamed(ResultadosQuizWidget.routeName, queryParameters: {'quizId': docId}); },
                                                ),
                                                FlutterFlowIconButton(
                                                  borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFFFA8785),
                                                  icon: Icon(Icons.delete_outline_rounded, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                  onPressed: () async {
                                                    // Confirmação antes de apagar
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text('Apagar Quiz'),
                                                        content: const Text('Tens a certeza que queres eliminar este quiz?'),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apagar', style: TextStyle(color: Colors.red))),
                                                        ],
                                                      ),
                                                    ) ?? false;

                                                    if (confirm) {
                                                      await FirebaseFirestore.instance.collection('quizzes').doc(docId).delete();
                                                    }
                                                  },
                                                ),
                                              ].divide(const SizedBox(width: 8.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}