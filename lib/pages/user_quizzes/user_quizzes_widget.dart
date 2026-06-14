import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

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

  // Variável para guardar o texto pesquisado
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserQuizzesModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Listener para atualizar a pesquisa em tempo real enquanto o utilizador digita
    _model.textController!.addListener(() {
      setState(() {
        _searchQuery = _model.textController!.text.toLowerCase();
      });
    });
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
                    fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
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
                                hintText: 'Pesquisar os meus quizzes...',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
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
                            // A barra já pesquisa automaticamente ao digitar, 
                            // fechar o teclado ao clicar na lupa é uma boa prática
                            FocusScope.of(context).unfocus();
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
                              context.pushNamed('AddQuiz');
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
                          return Center(
                            child: Text(
                              'Erro ao carregar os quizzes.\nVerifica a tua ligação.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          );
                        }

                        // Extrair apenas os DADOS REAIS
                        var allQuizzes = snapshot.data?.docs.map((doc) {
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

                        // APLICAR PESQUISA LOCAL (Filtro pelo Título)
                        if (_searchQuery.isNotEmpty) {
                          allQuizzes = allQuizzes.where((q) {
                            final title = (q['title'] ?? '').toString().toLowerCase();
                            return title.contains(_searchQuery);
                          }).toList();
                        }

                        // Mensagens se estiver vazio
                        if (allQuizzes.isEmpty) {
                          if (_searchQuery.isNotEmpty) {
                            return Center(
                              child: Text(
                                'Nenhum quiz encontrado para "$_searchQuery".',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                            );
                          }
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

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          itemCount: allQuizzes.length,
                          itemBuilder: (context, index) {
                            final quizData = allQuizzes[index];
                            
                            final docId = quizData['docId'];
                            final title = quizData['title'] ?? 'Sem Título';
                            final questionCount = quizData['questionCount'] ?? 0;
                            final isPublic = quizData['isPublic'] ?? false;
                            final rawImg = quizData['imageUrl'];
                            final imageUrl = (rawImg == null || rawImg.toString().trim().isEmpty) ? 'https://picsum.photos/seed/$docId/600' : rawImg.toString();

                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                              child: Container(
                                width: double.infinity,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12.0),
                                          bottomLeft: Radius.circular(12.0),
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 100.0,
                                            height: 100.0,
                                            color: Colors.grey[300],
                                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                          ),
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
                                                  InkWell(
                                                    onTap: () async {
                                                      await FirebaseFirestore.instance.collection('quizzes').doc(docId).update({'isPublic': !isPublic});
                                                    },
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                                      decoration: BoxDecoration(
                                                        color: isPublic ? FlutterFlowTheme.of(context).primary : const Color(0xFF6C6C85),
                                                        borderRadius: BorderRadius.circular(20.0),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 4.0,
                                                            offset: Offset(0, 2),
                                                          )
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            isPublic ? Icons.public : Icons.lock,
                                                            color: Colors.white,
                                                            size: 14.0,
                                                          ),
                                                          const SizedBox(width: 6.0),
                                                          Text(
                                                            isPublic ? 'Público' : 'Privado',
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  FlutterFlowIconButton(
                                                    borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFFFFD11E),
                                                    icon: Icon(Icons.edit_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                    onPressed: () async { context.pushNamed('EditarQuiz', queryParameters: {'quizId': docId}); },
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 8.0, buttonSize: 32.0, fillColor: isPublic ? const Color(0xFFB0B0B0) : const Color(0xFF42436F),
                                                    icon: Icon(Icons.share_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                    onPressed: isPublic ? () {} : () async {
                                                      // Gerar código aleatório de 6 caracteres
                                                      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                                      final rand = math.Random();
                                                      final code = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
                                                      
                                                      // Tempo de expiração (10 minutos)
                                                      final expiresAt = Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10)));
                                                      
                                                      // Guardar no Firestore
                                                      await FirebaseFirestore.instance.collection('quizzes').doc(docId).update({
                                                        'shareCode': code,
                                                        'shareCodeExpiresAt': expiresAt,
                                                      });
                                                      
                                                      if (context.mounted) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (ctx) => AlertDialog(
                                                            title: const Text('Código Privado Gerado'),
                                                            content: Text('Partilha este código com os teus amigos:\n\n$code\n\nEste código expira em 10 minutos!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                            actions: [
                                                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFF6FC073),
                                                    icon: Icon(Icons.remove_red_eye_outlined, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                    onPressed: () async { context.pushNamed('ResultadosQuiz', queryParameters: {'quizId': docId}); },
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 8.0, buttonSize: 32.0, fillColor: const Color(0xFFFA8785),
                                                    icon: Icon(Icons.delete_outline_rounded, color: FlutterFlowTheme.of(context).info, size: 16.0),
                                                    onPressed: () async {
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
                            );
                          },
                        );
                      },
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