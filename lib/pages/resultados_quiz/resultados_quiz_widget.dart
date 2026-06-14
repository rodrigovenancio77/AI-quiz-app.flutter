import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// NOVOS IMPORTS PARA LER DA BD
import 'package:cloud_firestore/cloud_firestore.dart';

import 'resultados_quiz_model.dart';
export 'resultados_quiz_model.dart';

class ResultadosQuizWidget extends StatefulWidget {
  const ResultadosQuizWidget({super.key});

  static String routeName = 'ResultadosQuiz';
  static String routePath = '/resultadosQuiz';

  @override
  State<ResultadosQuizWidget> createState() => _ResultadosQuizWidgetState();
}

class _ResultadosQuizWidgetState extends State<ResultadosQuizWidget> {
  late ResultadosQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? quizId;
  String quizTitle = 'A carregar...';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultadosQuizModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    quizId = GoRouterState.of(context).uri.queryParameters['quizId'];
    if (quizId != null) {
      // Vai buscar o Título do Quiz para pôr no cabeçalho
      FirebaseFirestore.instance.collection('quizzes').doc(quizId).get().then((doc) {
        if (doc.exists && mounted) {
          setState(() => quizTitle = doc.data()?['title'] ?? 'Quiz sem Título');
        }
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFEBEBF0),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(Icons.arrow_back_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 30.0),
          onPressed: () async => context.pop(),
        ),
        title: Text(
          'Resultados do Quiz',
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
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  quizTitle,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        fontSize: 24.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
              ),
            ),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Lê a sub-coleção de 'results' e ordena por quem teve mais pontos
                stream: quizId == null 
                    ? const Stream.empty() 
                    : FirebaseFirestore.instance.collection('quizzes').doc(quizId).collection('results').orderBy('score', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Ainda ninguém concluiu este quiz.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    );
                  }

                  final results = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final r = results[index].data() as Map<String, dynamic>;
                      final photo = r['userPhoto'] ?? '';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Foto do Jogador
                                Container(
                                  width: 50.0, height: 50.0,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    photo.isNotEmpty ? photo : 'https://images.unsplash.com/photo-1562788869-4ed32648eb72?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw2fHxwcm9mZXNzb3J8ZW58MHx8fHwxNzc3MjM5ODQ3fDA&ixlib=rb-4.1.0&q=80&w=400',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.person, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                
                                // Estatísticas
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['userName'] ?? 'Desconhecido',
                                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                            ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Corretas: ${r['score']}/${r['totalQuestions']}', style: FlutterFlowTheme.of(context).bodyMedium),
                                          Text('Tempo: ${r['timeTaken']}', style: FlutterFlowTheme.of(context).bodyMedium),
                                        ],
                                      ),
                                    ],
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
    );
  }
}