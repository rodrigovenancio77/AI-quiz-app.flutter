import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/quiz/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_quiz_model.dart';
export 'add_quiz_model.dart';

class AddQuizWidget extends StatefulWidget {
  const AddQuizWidget({super.key});

  static String routeName = 'AddQuiz';
  static String routePath = '/addQuiz';

  @override
  State<AddQuizWidget> createState() => _AddQuizWidgetState();
}

class _AddQuizWidgetState extends State<AddQuizWidget> {
  late AddQuizModel _model;
  final _quizService = QuizService();
  bool _isSaving = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddQuizModel());

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Adicionar Quiz',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          // 1. SingleChildScrollView resolve o problema do teclado cobrir o texto
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SECÇÃO SUPERIOR: Imagem e Textos
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      // 2. errorBuilder garante que a app não rebenta se a imagem falhar
                      child: Image.asset(
                        'assets/images/idea_6368837.png',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 80.0,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // 3. Expanded evita que o texto empurre os limites do ecrã e faça crash
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Para começar,\nescreva o tema do quiz',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  fontSize: 18.0,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Indique o tema seguido do número de perguntas (Máximo 40).',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: const Color(0xFF9095A1),
                                  fontSize: 14.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40.0),

                // SECÇÃO INFERIOR: Caixa de Texto
                TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: true, // Abre o teclado automaticamente!
                  enabled: !_isSaving, // Bloqueia a caixa enquanto a IA pensa
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) async {
                    await _handleCreateQuiz(context);
                  },
                  decoration: InputDecoration(
                    labelText: 'Tema e Número',
                    hintText: 'Ex: História de Portugal 10',
                    labelStyle: FlutterFlowTheme.of(context).labelMedium,
                    hintStyle: FlutterFlowTheme.of(context).labelMedium,
                    // Borda visível adicionada para garantir que se vê sempre
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
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    // 4. Spinner de Loading ou botão de enviar
                    suffixIcon: _isSaving
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            onPressed: () async {
                              await _handleCreateQuiz(context);
                            },
                          ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                  validator: _model.textControllerValidator.asValidator(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<void> _handleCreateQuiz(BuildContext context) async {
    if (_isSaving) return;

    final prompt = _model.textController?.text ?? '';
    setState(() => _isSaving = true);
    
    showSnackbar(context, 'A gerar o quiz com Inteligência Artificial...');
    
    try {
      final quizId = await _quizService.createQuizFromPrompt(
        context: context, 
        ownerUid: currentUserUid,
        prompt: prompt,
      );

      if (!context.mounted) return;
      
      showSnackbar(context, 'Quiz criado com sucesso!');
      _model.textController?.clear();
      
      // REDIRECIONAMENTO ATIVADO:
      // Navega para a página de edição passando o ID do novo quiz
      context.pushNamed(
        'EditarQuiz',
        queryParameters: {
          'quizId': quizId,
        }.withoutNulls,
      );

    } catch (e) {
      if (!context.mounted) return;
      showSnackbar(
          context, e.toString().replaceFirst('Invalid argument(s): ', '').replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
}