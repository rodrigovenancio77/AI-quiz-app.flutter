import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rever_quiz_model.dart';
export 'rever_quiz_model.dart';

class ReverQuizWidget extends StatefulWidget {
  const ReverQuizWidget({super.key});

  static String routeName = 'ReverQuiz';
  static String routePath = '/reverQuiz';

  @override
  State<ReverQuizWidget> createState() => _ReverQuizWidgetState();
}

class _ReverQuizWidgetState extends State<ReverQuizWidget> {
  late ReverQuizModel _model;
  final ScrollController _questionScrollController = ScrollController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  String? quizId;
  String? resultId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  List<int> _userAnswers = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReverQuizModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _questions.isNotEmpty) return; // avoid multiple calls
    final params = GoRouterState.of(context).uri.queryParameters;
    
    if (quizId == null && resultId == null) {
      quizId = params['quizId'];
      resultId = params['resultId'];
      if (quizId != null && resultId != null) {
        _loadData();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadData() async {
    try {
      // Load user answers
      final resultDoc = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).collection('results').doc(resultId).get();
      if (resultDoc.exists) {
        final data = resultDoc.data()!;
        _userAnswers = List<int>.from(data['userAnswers'] ?? []);
      }

      // Load questions
      final questionsSnapshot = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).collection('questions').orderBy('createdAt').get();
      _questions = questionsSnapshot.docs.map((doc) => doc.data()).toList();
      
    } catch (e) {
      print('Error loading review: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _questionScrollController.dispose();
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
    
    if (_questions.isEmpty || _userAnswers.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(title: const Text('Revisão')),
        body: Center(child: Text('Erro ao carregar dados da revisão.')),
      );
    }

    final question = _questions[_currentIndex];
    final options = List<String>.from(question['options'] ?? []);
    final correctAnswerIndex = question['correctAnswerIndex'] as int? ?? 0;
    final userAnswerIndex = _userAnswers.length > _currentIndex ? _userAnswers[_currentIndex] : -1;
    final imageUrl = question['imageUrl'] as String? ?? 'https://picsum.photos/seed/${quizId ?? '0'}_$_currentIndex/600';
    final questionText = question['question'] ?? '...';

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 200.0,
                          color: Colors.grey,
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 90.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Scrollbar(
                          controller: _questionScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _questionScrollController,
                            child: Text(
                              questionText,
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    fontSize: 16.0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0),
                      ),
                      child: Text(
                        'Modo de Revisão',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${_questions.length}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, idx) {
                      final optionText = options[idx];
                      
                      Color bgColor = FlutterFlowTheme.of(context).secondaryBackground;
                      Color borderColor = FlutterFlowTheme.of(context).alternate;
                      Color textColor = FlutterFlowTheme.of(context).primaryText;

                      if (idx == correctAnswerIndex) {
                        bgColor = const Color(0xFFC3FFB2);
                        borderColor = const Color(0xFF31AB31);
                      } else if (idx == userAnswerIndex) {
                        bgColor = const Color(0xFFF5C4C6);
                        borderColor = const Color(0xFFFC8883);
                      }
                      
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: borderColor,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6.0,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: Text(
                              optionText,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                    color: textColor,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FFButtonWidget(
                      onPressed: _currentIndex > 0
                          ? () => setState(() => _currentIndex--)
                          : null,
                      text: 'Anterior',
                      icon: const Icon(Icons.arrow_back, size: 15.0),
                      options: FFButtonOptions(
                        width: 140.0,
                        height: 40.0,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                        borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                        borderRadius: BorderRadius.circular(8.0),
                        disabledColor: const Color(0xFFE0E0E0),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: _currentIndex < _questions.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                      text: 'Próxima',
                      icon: const Icon(Icons.arrow_forward, size: 15.0),
                      options: FFButtonOptions(
                        width: 140.0,
                        height: 40.0,
                        iconAlignment: IconAlignment.end,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(8.0),
                        disabledColor: const Color(0xFFE0E0E0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                child: FFButtonWidget(
                  onPressed: () {
                    context.pop();
                  },
                  text: 'Voltar ao Resultado',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 45.0,
                    color: FlutterFlowTheme.of(context).alternate,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
      ),
    );
  }
}
