import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fim_quiz_model.dart';
export 'fim_quiz_model.dart';

class FimQuizWidget extends StatefulWidget {
  const FimQuizWidget({super.key});

  static String routeName = 'FimQuiz';
  static String routePath = '/fimQuiz';

  @override
  State<FimQuizWidget> createState() => _FimQuizWidgetState();
}

class _FimQuizWidgetState extends State<FimQuizWidget> {
  late FimQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variáveis para guardar os dados recebidos
  String? quizId;
  int score = 0;
  int totalQuestions = 0;
  String timeTaken = '0:00';
  double percentage = 0.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FimQuizModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // EXTRAIR OS DADOS DO URL (Query Parameters)
    final params = GoRouterState.of(context).uri.queryParameters;
    
    setState(() {
      quizId = params['quizId'];
      score = int.tryParse(params['score'] ?? '0') ?? 0;
      totalQuestions = int.tryParse(params['totalQuestions'] ?? '0') ?? 0;
      timeTaken = params['timeTaken'] ?? '0:00';
      
      // Calcular a percentagem em tempo real
      if (totalQuestions > 0) {
        percentage = (score / totalQuestions) * 100;
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definir cor e mensagem baseada no sucesso
    final isSuccess = percentage >= 50.0;
    final feedbackColor = isSuccess ? const Color(0xFF31AB31) : const Color(0xFFFC8883);
    final feedbackBg = isSuccess ? const Color(0xFFC3FFB2) : const Color(0xFFF5C4C6);
    final feedbackText = isSuccess ? 'Excelente trabalho!' : 'Tente novamente!';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'Quiz Concluído',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 8.0),
                child: Text(
                  'Parabéns, completou o quiz!\nVeja o seu resultado abaixo.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        fontSize: 16.0,
                      ),
                ),
              ),
              
              // --- CÍRCULO DE PONTUAÇÃO ---
              Container(
                width: 340.0,
                height: 340.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 180.0,
                        height: 180.0,
                        decoration: BoxDecoration(
                          color: feedbackBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: FlutterFlowTheme.of(context).displaySmall.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                color: feedbackColor,
                              ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            feedbackText,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  fontSize: 20.0,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '$score de $totalQuestions respostas corretas',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                          ),
                          Text(
                            'Tempo: $timeTaken',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- BOTÕES DE AÇÃO ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              'ResponderQuiz',
                              queryParameters: {'quizId': quizId}.withoutNulls,
                            );
                          },
                          text: 'Repetir',
                          options: FFButtonOptions(
                            width: 150.0,
                            height: 45.0,
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                            borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              'ResultadosQuiz',
                              queryParameters: {'quizId': quizId}.withoutNulls,
                            );
                          },
                          text: 'Leaderboard',
                          options: FFButtonOptions(
                            width: 150.0,
                            height: 45.0,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    FFButtonWidget(
                      onPressed: () async {
                        context.goNamed('UserQuizzes');
                      },
                      text: 'Sair para o Menu',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 45.0,
                        color: FlutterFlowTheme.of(context).alternate,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}