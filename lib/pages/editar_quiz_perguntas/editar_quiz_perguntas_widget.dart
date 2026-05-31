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
import 'package:image_picker/image_picker.dart';

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
  List<DocumentSnapshot?> _questionDocs = [];
  List<DocumentSnapshot> _deletedDocs = [];
  List<Map<String, dynamic>> _localQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInit = false;
  int _currentOptionsCount = 4;

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

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmara'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _model.pickImage(context, ImageSource.camera);
                  _uploadImageAndSetUrl();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _model.pickImage(context, ImageSource.gallery);
                  _uploadImageAndSetUrl();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImageAndSetUrl() async {
    if (_model.pickedImageBytes != null) {
      setState(() => _model.isUploading = true);
      String? url = await _model.uploadToImageBB();
      if (url != null && _localQuestions.isNotEmpty) {
        setState(() {
           _localQuestions[_currentIndex]['imageUrl'] = url;
           _model.pickedImageBytes = null;
           _model.pickedFileObj = null;
        });
      }
      setState(() => _model.isUploading = false);
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
      _localQuestions = snap.docs.map((d) => d.data()).toList();

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
    _currentOptionsCount = opts.length == 2 ? 2 : 4;

    _model.textController2!.text = opts.isNotEmpty ? opts[0] : '';
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

    if (_currentOptionsCount == 2 && correctIdx > 1) {
      correctIdx = 0;
    }

    final existingImageUrl = _localQuestions[_currentIndex]['imageUrl'];

    _localQuestions[_currentIndex] = {
      'question': _model.textController1!.text,
      'options': _currentOptionsCount == 2
          ? [
              _model.textController2!.text,
              _model.textController3!.text,
            ]
          : [
              _model.textController2!.text,
              _model.textController3!.text,
              _model.textController4!.text,
              _model.textController5!.text,
            ],
      'correctAnswerIndex': correctIdx,
      if (existingImageUrl != null) 'imageUrl': existingImageUrl,
    };
  }

  void _addNewQuestion() {
    _saveCurrentToLocal();
    setState(() {
      _localQuestions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswerIndex': 0,
      });
      _questionDocs.add(null);
      _currentIndex = _localQuestions.length - 1;
      _populateUI();
    });
  }

  void _removeCurrentQuestion() {
    if (_localQuestions.length <= 1) {
      showSnackbar(context, 'O quiz deve ter pelo menos uma pergunta.');
      return;
    }
    
    final docToRemove = _questionDocs[_currentIndex];
    if (docToRemove != null) {
      _deletedDocs.add(docToRemove);
    }
    
    setState(() {
      _localQuestions.removeAt(_currentIndex);
      _questionDocs.removeAt(_currentIndex);
      if (_currentIndex >= _localQuestions.length) {
        _currentIndex = _localQuestions.length - 1;
      }
      _populateUI();
    });
  }

  void _toggleOptionsCount() {
    setState(() {
      _currentOptionsCount = _currentOptionsCount == 2 ? 4 : 2;
      if (_currentOptionsCount == 2) {
        if (_model.checkboxValue3 == true || _model.checkboxValue4 == true) {
          _setCorrectAnswer(0);
        }
      }
    });
  }

  void _showQuestionsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text(
                'Perguntas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ...List.generate(_localQuestions.length, (index) {
                    final isActive = index == _currentIndex;
                    return InkWell(
                      onTap: () {
                        _saveCurrentToLocal();
                        setState(() {
                          _currentIndex = index;
                          _populateUI();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF42436F) : Colors.white,
                          border: Border.all(color: const Color(0xFF42436F)),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF42436F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  InkWell(
                    onTap: () {
                      _addNewQuestion();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF42436F)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        '+',
                        style: TextStyle(
                          color: Color(0xFF42436F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  child: Image.network(
                                    (_localQuestions.isNotEmpty && _localQuestions[_currentIndex]['imageUrl'] != null) 
                                        ? _localQuestions[_currentIndex]['imageUrl'] 
                                        : 'https://picsum.photos/seed/${quizId ?? '0'}_${_currentIndex}/600',
                                    width: 344.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
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
                        InkWell(
                          onTap: _toggleOptionsCount,
                          child: Container(
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
                                Text('$_currentOptionsCount', style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 8.0),
                                Icon(Icons.sync, size: 16.0, color: FlutterFlowTheme.of(context).primary),
                              ],
                            ),
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
                      child: Center(
                        child: GridView(
                          shrinkWrap: true,
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
                          if (_currentOptionsCount == 4) ...[
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
                        ],
                      ),
                      ),
                    ),
                  ),

                  // --- BOTÕES ADICIONAR E REMOVER ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FFButtonWidget(
                          onPressed: _removeCurrentQuestion,
                          text: 'Remover',
                          icon: const Icon(Icons.delete_outline, size: 15.0),
                          options: FFButtonOptions(
                            height: 35.0,
                            color: FlutterFlowTheme.of(context).error,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: _addNewQuestion,
                          text: 'Adicionar',
                          icon: const Icon(Icons.add, size: 15.0),
                          options: FFButtonOptions(
                            height: 35.0,
                            color: const Color(0xFF6FC073),
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- NAVEGADOR DE PERGUNTAS (POP-UP e Setas) ---
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botão Anterior
                        InkWell(
                          onTap: _currentIndex > 0
                              ? () {
                                  _saveCurrentToLocal();
                                  setState(() {
                                    _currentIndex--;
                                    _populateUI();
                                  });
                                }
                              : null,
                          child: Container(
                            width: 50.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: _currentIndex > 0 ? FlutterFlowTheme.of(context).secondaryBackground : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: _currentIndex > 0 ? FlutterFlowTheme.of(context).alternate : Colors.transparent),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: _currentIndex > 0 ? FlutterFlowTheme.of(context).alternate : Colors.grey,
                            ),
                          ),
                        ),
                        
                        // Botão Pop-up
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: InkWell(
                              onTap: () => _showQuestionsPopup(),
                              child: Container(
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botão Próxima
                        InkWell(
                          onTap: _currentIndex < _localQuestions.length - 1
                              ? () {
                                  _saveCurrentToLocal();
                                  setState(() {
                                    _currentIndex++;
                                    _populateUI();
                                  });
                                }
                              : null,
                          child: Container(
                            width: 50.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: _currentIndex < _localQuestions.length - 1 ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: _currentIndex < _localQuestions.length - 1 ? FlutterFlowTheme.of(context).primary : Colors.transparent),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: _currentIndex < _localQuestions.length - 1 ? Colors.white : Colors.grey,
                            ),
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
                          
                          // Apagar as removidas
                          for (var doc in _deletedDocs) {
                            batch.delete(doc.reference);
                          }

                          // Atualizar ou Criar novas
                          final questionsRef = FirebaseFirestore.instance.collection('quizzes').doc(quizId).collection('questions');
                          for (int i = 0; i < _localQuestions.length; i++) {
                            final qData = <String, dynamic>{
                              'question': _localQuestions[i]['question'],
                              'options': _localQuestions[i]['options'],
                              'correctAnswerIndex': _localQuestions[i]['correctAnswerIndex'],
                              'createdAt': FieldValue.serverTimestamp(),
                            };
                            if (_localQuestions[i]['imageUrl'] != null) {
                              qData['imageUrl'] = _localQuestions[i]['imageUrl'];
                            }
                            
                            final docSnap = _questionDocs[i];
                            if (docSnap != null) {
                              // Atualiza
                              qData.remove('createdAt'); // não alterar a ordem original
                              batch.update(docSnap.reference, qData);
                            } else {
                              // Cria nova
                              final newDocRef = questionsRef.doc();
                              batch.set(newDocRef, qData);
                            }
                          }
                          await batch.commit();

                          // 3. Atualizar o Quiz pai para estado "Ready" e a contagem
                          await FirebaseFirestore.instance.collection('quizzes').doc(quizId).update({
                            'status': 'ready',
                            'questionCount': _localQuestions.length,
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