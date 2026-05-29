import '/components/popup_perguntas_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORTS PARA FIREBASE E AUTH
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

import 'responder_quiz_model.dart';
export 'responder_quiz_model.dart';

class ResponderQuizWidget extends StatefulWidget {
  const ResponderQuizWidget({super.key});

  static String routeName = 'ResponderQuiz';
  static String routePath = '/responderQuiz';

  @override
  State<ResponderQuizWidget> createState() => _ResponderQuizWidgetState();
}

class _ResponderQuizWidgetState extends State<ResponderQuizWidget> {
  late ResponderQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? quizId;
  Map<String, dynamic>? quizData;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInit = false;
  bool _isFinished = false;

  // Guarda a opção escolhida para cada pergunta (Índice da Pergunta -> Índice da Resposta)
  final Map<int, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResponderQuizModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      quizId = GoRouterState.of(context).uri.queryParameters['quizId'];
      _fetchQuizData();
      _isInit = true;
    }
  }

  Future<void> _fetchQuizData() async {
    if (quizId == null) return;

    try {
      // 1. Obter detalhes do Quiz (para o temporizador)
      final quizDoc = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).get();
      if (quizDoc.exists) {
        quizData = quizDoc.data();
        final durationMinutes = quizData?['durationMinutes'] ?? 10;
        
        // Configurar o Timer
        final durationMs = durationMinutes * 60 * 1000;
        _model.timerController.timer.onStopTimer();
        _model.timerController.timer.onResetTimer();
        _model.timerController.timer.setPresetTime(mSec: durationMs);
        _model.timerMilliseconds = durationMs;
        _model.timerController.timer.onStartTimer();
      }

      // 2. Obter as Perguntas
      final qSnap = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .orderBy('createdAt')
          .get();

      _questions = qSnap.docs.map((d) => d.data()).toList();

    } catch (e) {
      print('Erro ao carregar o quiz para jogar: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- FUNÇÃO PARA FINALIZAR O QUIZ ---
  Future<void> _finishQuiz() async {
    if (_isFinished) return;
    _isFinished = true;
    
    // Pára o relógio
    _model.timerController.timer.onStopTimer();

    // Calcula a Pontuação
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswerIndex']) {
        correctAnswers++;
      }
    }

    // Calcula o Tempo Gasto
    int initialMs = (quizData?['durationMinutes'] ?? 10) * 60 * 1000;
    int timeLeftMs = _model.timerMilliseconds;
    int takenMs = initialMs - timeLeftMs;
    if (takenMs < 0) takenMs = 0; // Prevenção
    
    Duration taken = Duration(milliseconds: takenMs);
    String timeStr = '${taken.inMinutes}:${(taken.inSeconds % 60).toString().padLeft(2, '0')}';

    // GUARDA OS RESULTADOS NA BASE DE DADOS
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('results')
          .add({
        'userId': currentUserUid,
        'userName': currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Anónimo',
        'userPhoto': currentUserPhoto,
        'score': correctAnswers,
        'totalQuestions': _questions.length,
        'timeTaken': timeStr,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao guardar resultado: $e');
    }

    // Navega para o Ecrã Final
    if (mounted) {
      context.goNamed(
        'FimQuiz',
        queryParameters: {
          'quizId': quizId,
          'score': correctAnswers.toString(),
          'totalQuestions': _questions.length.toString(),
          'timeTaken': timeStr,
        }.withoutNulls,
      );
    }
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
                  ...List.generate(_questions.length, (index) {
                    final isActive = index == _currentIndex;
                    final isAnswered = _userAnswers.containsKey(index);
                    
                    Color bgColor;
                    if (isActive) {
                      bgColor = const Color(0xFF42436F);
                    } else if (isAnswered) {
                      bgColor = const Color(0xFF6FC073);
                    } else {
                      bgColor = Colors.white;
                    }

                    Color textColor = (isActive || isAnswered) ? Colors.white : const Color(0xFF42436F);
                    Color borderColor = isActive ? const Color(0xFF42436F) : (isAnswered ? const Color(0xFF6FC073) : const Color(0xFF42436F));

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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
        body: Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(title: const Text('Ops!')),
        body: const Center(child: Text('Este quiz ainda não tem perguntas geradas.')),
      );
    }

    final currentQ = _questions[_currentIndex];
    final options = currentQ['options'] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEBEBF0),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // --- IMAGEM E PERGUNTA ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 8.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                      child: Image.network(
                        currentQ['imageUrl'] ?? 'https://picsum.photos/seed/${quizId ?? '0'}_$_currentIndex/600', 
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
                    Container(
                      width: 344.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentQ['question'] ?? '...',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                fontSize: 16.0,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- TEMPORIZADOR E INDICADOR DE PERGUNTA ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 140.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: FlutterFlowTheme.of(context).primaryText, size: 18.0),
                          const SizedBox(width: 8.0),
                          FlutterFlowTimer(
                            initialTime: _model.timerMilliseconds,
                            getDisplayTime: (value) => StopWatchTimer.getDisplayTime(value, hours: false, milliSecond: false),
                            controller: _model.timerController,
                            updateStateInterval: const Duration(milliseconds: 1000),
                            onChanged: (value, displayTime, shouldUpdate) {
                              _model.timerMilliseconds = value;
                              _model.timerValue = displayTime;
                              if (value <= 0 && !_isFinished) _finishQuiz(); // Termina se o tempo acabar
                              if (shouldUpdate) safeSetState(() {});
                            },
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  fontSize: 16.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40.0,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_currentIndex + 1} de ${_questions.length}',
                        style: FlutterFlowTheme.of(context).titleSmall.override(font: GoogleFonts.interTight(), color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // --- BOTÕES DE OPÇÕES ---
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
                      _buildOptionButton(0, options.isNotEmpty ? options[0] : '', const Color(0xFFF5C4C6), const Color(0xFFFC8883)),
                      _buildOptionButton(1, options.length > 1 ? options[1] : '', const Color(0xFFC3FFB2), const Color(0xFF31AB31)),
                      if (options.length > 2)
                        _buildOptionButton(2, options[2], const Color(0xFF99CCFF), const Color(0xFF4E507A)),
                      if (options.length > 3)
                        _buildOptionButton(3, options[3], const Color(0xFFFFEBB2), const Color(0xFFFECF15)),
                    ],
                  ),
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
                          ? () => setState(() => _currentIndex--)
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
                      onTap: _currentIndex < _questions.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                      child: Container(
                        width: 50.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: _currentIndex < _questions.length - 1 ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: _currentIndex < _questions.length - 1 ? FlutterFlowTheme.of(context).primary : Colors.transparent),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: _currentIndex < _questions.length - 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- BOTÃO DE FINALIZAR ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Finalizar Quiz'),
                        content: const Text('Tens a certeza que queres entregar as tuas respostas?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Entregar', style: TextStyle(color: Colors.blue))),
                        ],
                      ),
                    ) ?? false;

                    if (confirm) {
                      await _finishQuiz();
                    }
                  },
                  text: 'Finalizar Quiz',
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
        ),
      ),
    );
  }

  // Helper visual para os botões coloridos de resposta
  Widget _buildOptionButton(int index, String text, Color bgColor, Color borderColor) {
    if (text.isEmpty) return const SizedBox.shrink();

    bool isSelected = _userAnswers[_currentIndex] == index;

    return FFButtonWidget(
      onPressed: () {
        setState(() => _userAnswers[_currentIndex] = index);
      },
      text: text,
      options: FFButtonOptions(
        padding: const EdgeInsets.all(8.0),
        color: bgColor,
        textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
              color: const Color(0xFF1C1D26), // Cor escura para leitura
            ),
        elevation: isSelected ? 6.0 : 0.0,
        borderSide: BorderSide(
          color: isSelected ? const Color(0xFF1C1D26) : borderColor,
          width: isSelected ? 4.0 : 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}