import '/components/popup_perguntas_edit_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// NOVO IMPORT: Para falar com o Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editar_quiz_perguntas_model.dart';
export 'editar_quiz_perguntas_model.dart';

class EditarQuizPerguntasWidget extends StatefulWidget {
  const EditarQuizPerguntasWidget({super.key});

  static String routeName = 'EditarQuizPerguntas';
  static String routePath = '/editarQuizPerguntas';

  @override
  State<EditarQuizPerguntasWidget> createState() =>
      _EditarQuizPerguntasWidgetState();
}

class _EditarQuizPerguntasWidgetState extends State<EditarQuizPerguntasWidget> {
  late EditarQuizPerguntasModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // VARIÁVEIS DE ESTADO PARA O FIREBASE
  String? quizId;
  List<DocumentSnapshot> _questionDocs = [];
  List<Map<String, dynamic>> _localQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditarQuizPerguntasModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.switchValue = true; // Mantém a UI de 4 opções ativa
    
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      quizId = GoRouterState.of(context).uri.queryParameters['quizId'];
      _fetchQuestions();
      _isInit = true;
    }
  }

  // VAI BUSCAR AS PERGUNTAS GERADAS PELO GEMINI
  Future<void> _fetchQuestions() async {
    if (quizId == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .orderBy('createdAt') // Ordenar pela ordem de criação
          .get();

      _questionDocs = snap.docs;
      _localQuestions = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();

      if (_localQuestions.isNotEmpty) {
        _populateUI();
      }
    } catch (e) {
      print('Erro ao carregar perguntas: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // PREENCHE AS CAIXAS DE TEXTO COM A PERGUNTA ATUAL
  void _populateUI() {
    if (_localQuestions.isEmpty) return;

    final q = _localQuestions[_currentIndex];
    
    _model.textController1!.text = q['question'] ?? '';
    
    List<dynamic> opts = q['options'] ?? ['', '', '', ''];
    _model.textController2!.text = opts.length > 0 ? opts[0] : '';
    _model.textController3!.text = opts.length > 1 ? opts[1] : '';
    _model.textController4!.text = opts.length > 2 ? opts[2] : '';
    _model.textController5!.text = opts.length > 3 ? opts[3] : '';

    int correct = q['correctAnswerIndex'] ?? 0;
    _setCorrectAnswer(correct);
  }

  // GUARDA A PERGUNTA ATUAL NA MEMÓRIA ANTES DE MUDAR DE PÁGINA
  void _saveCurrentToLocal() {
    if (_localQuestions.isEmpty) return;

    int correctIdx = 0;
    if (_model.checkboxValue2 == true) correctIdx = 1;
    if (_model.checkboxValue3 == true) correctIdx = 2;
    if (_model.checkboxValue4 == true) correctIdx = 3;

    _localQuestions[_currentIndex] = {
      'question': _model.textController1!.text,
      'options': [
        _model.textController2!.text,
        _model.textController3!.text,
        _model.textController4!.text,
        _model.textController5!.text,
      ],
      'correctAnswerIndex': correctIdx,
    };
  }

  // FORÇA AS CHECKBOXES A COMPORTAREM-SE COMO RÁDIOS (Apenas 1 correta)
  void _setCorrectAnswer(int index) {
    setState(() {
      _model.checkboxValue1 = (index == 0);
      _model.checkboxValue2 = (index == 1);
      _model.checkboxValue3 = (index == 2);
      _model.checkboxValue4 = (index == 3);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBEBF0),
        body: Center(
          child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    if (_localQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Nenhuma pergunta gerada para este quiz.')),
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
        floatingActionButton: Align(
          alignment: const AlignmentDirectional(-0.75, -0.8),
          child: FloatingActionButton(
            onPressed: () async {
              context.pushNamed(EditarQuizWidget.routeName, queryParameters: {'quizId': quizId});
            },
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            elevation: 8.0,
            child: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // --- IMAGEM E CAIXA DA PERGUNTA ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: Image.network(
                                'https://picsum.photos/seed/$quizId/600',
                                width: 344.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _model.textController1,
                                  focusNode: _model.textFieldFocusNode1,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Escreve a pergunta aqui...',
                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                        ),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        fontSize: 16.0,
                                      ),
                                  maxLines: 3,
                                  minLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // --- BARRA INTERMÉDIA (Nº de Opções e Indicador de Pergunta) ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 180.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
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
                              Text('Nº Opções:', style: FlutterFlowTheme.of(context).bodyMedium),
                              const SizedBox(width: 8.0),
                              Text('4', style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        // MOSTRADOR DA PERGUNTA ATUAL
                        Container(
                          height: 40.0,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pergunta ${_currentIndex + 1} de ${_localQuestions.length}',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- GRELHA DAS 4 RESPOSTAS ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: GridView(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                        children: [
                          // RESPOSTA 1 (VERMELHO)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5C4C6),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: const Color(0xFFFC8883), width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextFormField(
                                    controller: _model.textController2,
                                    focusNode: _model.textFieldFocusNode2,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Opção 1'),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                    maxLines: 2,
                                    minLines: 1,
                                  ),
                                ),
                                Checkbox(
                                  value: _model.checkboxValue1 ??= false,
                                  onChanged: (val) { if (val == true) _setCorrectAnswer(0); },
                                  activeColor: FlutterFlowTheme.of(context).primaryBackground,
                                  checkColor: FlutterFlowTheme.of(context).success,
                                ),
                              ],
                            ),
                          ),
                          // RESPOSTA 2 (VERDE)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFC3FFB2),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: const Color(0xFF31AB31), width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextFormField(
                                    controller: _model.textController3,
                                    focusNode: _model.textFieldFocusNode3,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Opção 2'),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                    maxLines: 2,
                                    minLines: 1,
                                  ),
                                ),
                                Checkbox(
                                  value: _model.checkboxValue2 ??= false,
                                  onChanged: (val) { if (val == true) _setCorrectAnswer(1); },
                                  activeColor: FlutterFlowTheme.of(context).primaryBackground,
                                  checkColor: FlutterFlowTheme.of(context).success,
                                ),
                              ],
                            ),
                          ),
                          // RESPOSTA 3 (AZUL)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF99CCFF),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: const Color(0xFF4E507A), width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextFormField(
                                    controller: _model.textController4,
                                    focusNode: _model.textFieldFocusNode4,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Opção 3'),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                    maxLines: 2,
                                    minLines: 1,
                                  ),
                                ),
                                Checkbox(
                                  value: _model.checkboxValue3 ??= false,
                                  onChanged: (val) { if (val == true) _setCorrectAnswer(2); },
                                  activeColor: FlutterFlowTheme.of(context).primaryBackground,
                                  checkColor: FlutterFlowTheme.of(context).success,
                                ),
                              ],
                            ),
                          ),
                          // RESPOSTA 4 (AMARELO)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBB2),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: const Color(0xFFFECF15), width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextFormField(
                                    controller: _model.textController5,
                                    focusNode: _model.textFieldFocusNode5,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Opção 4'),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                    maxLines: 2,
                                    minLines: 1,
                                  ),
                                ),
                                Checkbox(
                                  value: _model.checkboxValue4 ??= false,
                                  onChanged: (val) { if (val == true) _setCorrectAnswer(3); },
                                  activeColor: FlutterFlowTheme.of(context).primaryBackground,
                                  checkColor: FlutterFlowTheme.of(context).success,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- BOTÕES NAVEGAR (Anterior e Próxima) ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BOTÃO ANTERIOR
                        FFButtonWidget(
                          onPressed: _currentIndex > 0
                              ? () {
                                  _saveCurrentToLocal();
                                  setState(() {
                                    _currentIndex--;
                                    _populateUI();
                                  });
                                }
                              : null,
                          text: 'Anterior',
                          icon: const Icon(Icons.arrow_back, size: 15.0),
                          options: FFButtonOptions(
                            width: 150.0,
                            height: 40.0,
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                            borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                            borderRadius: BorderRadius.circular(8.0),
                            disabledColor: const Color(0xFFD0D0D0),
                          ),
                        ),
                        // BOTÃO PRÓXIMA
                        FFButtonWidget(
                          onPressed: _currentIndex < _localQuestions.length - 1
                              ? () {
                                  _saveCurrentToLocal();
                                  setState(() {
                                    _currentIndex++;
                                    _populateUI();
                                  });
                                }
                              : null,
                          text: 'Próxima',
                          icon: const Icon(Icons.arrow_forward, size: 15.0),
                          options: FFButtonOptions(
                            width: 150.0,
                            height: 40.0,
                            iconAlignment: IconAlignment.end,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(8.0),
                            disabledColor: const Color(0xFFD0D0D0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BOTÃO GUARDAR QUIZ (ENVIA PARA O FIREBASE) ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        // 1. Guardar a última pergunta editada
                        _saveCurrentToLocal();
                        setState(() => _isLoading = true);

                        try {
                          // 2. Fazer um Batch Update ao Firestore com todas as alterações
                          final batch = FirebaseFirestore.instance.batch();
                          for (int i = 0; i < _questionDocs.length; i++) {
                            batch.update(_questionDocs[i].reference, {
                              'question': _localQuestions[i]['question'],
                              'options': _localQuestions[i]['options'],
                              'correctAnswerIndex': _localQuestions[i]['correctAnswerIndex'],
                            });
                          }
                          await batch.commit();

                          // 3. Atualizar o Quiz pai para estado "Ready"
                          await FirebaseFirestore.instance.collection('quizzes').doc(quizId).update({
                            'status': 'ready',
                          });

                          if (mounted) {
                            showSnackbar(context, 'O teu Quiz está pronto a jogar!');
                            // Volta para a página dos Meus Quizzes
                            context.goNamed('UserQuizzes'); 
                          }
                        } catch (e) {
                          if (mounted) {
                            showSnackbar(context, 'Erro ao guardar: $e');
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      text: 'Guardar Quiz Final',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 45.0,
                        color: FlutterFlowTheme.of(context).alternate,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}