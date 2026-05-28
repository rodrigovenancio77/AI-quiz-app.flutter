import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// NOVO IMPORT PARA LER DA BD
import 'package:cloud_firestore/cloud_firestore.dart';

import 'participar_model.dart';
export 'participar_model.dart';

class ParticiparWidget extends StatefulWidget {
  const ParticiparWidget({super.key});

  static String routeName = 'Participar';
  static String routePath = '/participar';

  @override
  State<ParticiparWidget> createState() => _ParticiparWidgetState();
}

class _ParticiparWidgetState extends State<ParticiparWidget> {
  late ParticiparModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variável para guardar o texto da pesquisa
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParticiparModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Atualiza a pesquisa enquanto o utilizador escreve
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
            'Explorar Quizzes',
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // --- BARRA DE PESQUISA ---
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
                            hintText: 'Pesquisar quizzes públicos...',
                            hintStyle: FlutterFlowTheme.of(context).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              // ERRO CORRIGIDO AQUI: Remoção do "const" antes do BorderSide
                              borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(Icons.search, color: FlutterFlowTheme.of(context).info, size: 24.0),
                      onPressed: () {
                        // A pesquisa já é feita automaticamente pelo listener
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              ),

              // --- BOTÃO ENTRAR COM CÓDIGO ---
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          final TextEditingController codeController = TextEditingController();
                          
                          final enteredCode = await showDialog<String>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Entrar com Código'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Insere o código de 6 caracteres do quiz privado:'),
                                  const SizedBox(height: 12.0),
                                  TextField(
                                    controller: codeController,
                                    maxLength: 6,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Ex: A1B2C3',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(ctx, codeController.text.trim().toUpperCase()), child: const Text('Entrar')),
                              ],
                            ),
                          );

                          if (enteredCode != null && enteredCode.isNotEmpty) {
                            try {
                              final querySnapshot = await FirebaseFirestore.instance
                                  .collection('quizzes')
                                  .where('shareCode', isEqualTo: enteredCode)
                                  .limit(1)
                                  .get();
                                  
                              if (querySnapshot.docs.isEmpty) {
                                if (context.mounted) showSnackbar(context, 'Código inválido ou quiz apagado.');
                                return;
                              }
                              
                              final quizDoc = querySnapshot.docs.first;
                              final data = quizDoc.data();
                              final expiresAt = data['shareCodeExpiresAt'] as Timestamp?;
                              
                              if (expiresAt == null || expiresAt.toDate().isBefore(DateTime.now())) {
                                if (context.mounted) showSnackbar(context, 'Este código expirou. Pede um novo código ao criador do quiz.');
                                return;
                              }
                              
                              // Código válido e não expirado, vamos entrar no quiz!
                              if (context.mounted) {
                                context.pushNamed(
                                  'ResponderQuiz',
                                  queryParameters: {'quizId': quizDoc.id},
                                );
                              }
                            } catch (e) {
                              if (context.mounted) showSnackbar(context, 'Erro ao verificar o código.');
                            }
                          }
                        },
                        text: 'Entrar com código privado',
                        icon: const Icon(Icons.vpn_key_rounded, size: 15.0),
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

              // --- LISTA DE QUIZZES PÚBLICOS ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // PROCURA APENAS QUIZZES PÚBLICOS
                  stream: FirebaseFirestore.instance
                      .collection('quizzes')
                      .where('isPublic', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar a comunidade.'));
                    }

                    // Extrair e ordenar localmente (mais recentes primeiro)
                    var quizzes = snapshot.data?.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          data['docId'] = doc.id;
                          return data;
                        }).toList() ?? [];

                    quizzes.sort((a, b) {
                      final aTime = a['createdAt'] as Timestamp?;
                      final bTime = b['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });

                    // APLICAR PESQUISA LOCAL
                    if (_searchQuery.isNotEmpty) {
                      quizzes = quizzes.where((q) {
                        final title = (q['title'] ?? '').toString().toLowerCase();
                        return title.contains(_searchQuery);
                      }).toList();
                    }

                    if (quizzes.isEmpty) {
                      return const Center(child: Text('Nenhum quiz público encontrado.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quizData = quizzes[index];
                        final docId = quizData['docId'];
                        final title = quizData['title'] ?? 'Sem Título';
                        final questionCount = quizData['questionCount'] ?? 0;
                        final duration = quizData['durationMinutes'] ?? '--';
                        final imageUrl = quizData['imageUrl'] ?? 'https://picsum.photos/seed/$docId/600';

                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                          child: Container(
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: InkWell(
                              onTap: () async {
                                // Redireciona para jogar
                                context.pushNamed(
                                  ResponderQuizWidget.routeName,
                                  queryParameters: {'quizId': docId},
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Imagem do Quiz
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
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Título
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                  fontSize: 16.0,
                                                ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          // Informações
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(Icons.format_list_bulleted, size: 14.0, color: FlutterFlowTheme.of(context).secondaryText),
                                              const SizedBox(width: 4.0),
                                              Text('$questionCount', style: FlutterFlowTheme.of(context).bodySmall),
                                              const SizedBox(width: 12.0),
                                              Icon(Icons.access_time, size: 14.0, color: FlutterFlowTheme.of(context).secondaryText),
                                              const SizedBox(width: 4.0),
                                              Text('$duration min', style: FlutterFlowTheme.of(context).bodySmall),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Ícone indicativo de Jogar
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 36.0,
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }
}