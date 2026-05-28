import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTS PARA BASE DE DADOS
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

import 'dashboard_model.dart';
export 'dashboard_model.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'Dashboard';
  static String routePath = '/dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
  }

  // Função para calcular o tempo amigável (ex: "há 2 horas")
  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'agora mesmo';
    final date = timestamp.toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 1) return 'há ${diff.inDays} dias';
    if (diff.inDays == 1) return 'há 1 dia';
    if (diff.inHours > 1) return 'há ${diff.inHours} horas';
    if (diff.inHours == 1) return 'há 1 hora';
    if (diff.inMinutes > 1) return 'há ${diff.inMinutes} minutos';
    return 'agora mesmo';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Proteção: Se ainda não tiver o ID do utilizador, mostra loading
    if (currentUserUid.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFFEBEBF0),
          automaticallyImplyLeading: false,
          title: Text(
            'Início',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<QuerySnapshot>(
            // FAZ UMA ÚNICA PESQUISA SIMPLES (Não precisa de índices compostos)
            stream: FirebaseFirestore.instance
                .collection('quizzes')
                .where('ownerUid', isEqualTo: currentUserUid)
                .snapshots(),
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary));
              }

              // --- PROCESSAMENTO LOCAL (DART) ---
              int pub = 0;
              int priv = 0;
              int totalQuestions = 0;
              List<Map<String, dynamic>> allQuizzes = [];

              final docs = snapshot.data?.docs ?? [];

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                data['docId'] = doc.id;
                allQuizzes.add(data);

                // Contar Públicos vs Privados
                if (data['isPublic'] == true) {
                  pub++;
                } else {
                  priv++;
                }

                // Somar todas as perguntas criadas
                totalQuestions += (data['questionCount'] as int?) ?? 0;
              }

              // ORDENAÇÃO LOCAL (Evita o erro do .orderBy no Firebase)
              allQuizzes.sort((a, b) {
                final aTime = a['createdAt'] as Timestamp?;
                final bTime = b['createdAt'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime); // Ordena do mais recente para o mais antigo
              });

              // Apanha apenas os 5 primeiros para a secção de recentes
              final recentQuizzes = allQuizzes.take(5).toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // --- CARTÕES DE ESTATÍSTICAS ---
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 24.0, 8.0),
                      child: GridView(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.4,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard('Quizzes Públicos', pub.toString(), Icons.menu_book_rounded, const Color(0xFF99CCFF), const Color(0xFF4E507A)),
                          _buildStatCard('Quizzes Privados', priv.toString(), Icons.lock, const Color(0xFFFC8883), const Color(0xFFE1656A)),
                          _buildStatCard('Perguntas Criadas', totalQuestions.toString(), Icons.format_list_numbered_rounded, const Color(0xFFFFEBB2), const Color(0xFFFECF15)),
                          _buildStatCard('Total de Quizzes', allQuizzes.length.toString(), Icons.folder_special_rounded, const Color(0xFFC3FFB2), const Color(0xFF31AB31)),
                        ],
                      ),
                    ),

                    // --- TÍTULO RECENTES ---
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 8.0),
                      child: Row(
                        children: [
                          Text('Quizzes recentes', 
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.bold), 
                              fontSize: 16.0
                            )
                          ),
                        ],
                      ),
                    ),

                    // --- GRELHA DE RECENTES ---
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentQuizzes.length + 1,
                        itemBuilder: (context, index) {
                          if (index == recentQuizzes.length) {
                            return _buildAddButton();
                          }
                          final data = recentQuizzes[index];
                          return _buildRecentQuizCard(data['docId'], data);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPEZA DE CÓDIGO ---

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8.0), border: Border.all(color: iconColor)),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 32.0),
              Text(value, style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold), fontSize: 32.0)),
            ],
          ),
          Align(alignment: Alignment.centerLeft, child: Text(label, style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), fontSize: 13.0))),
        ],
      ),
    );
  }

  Widget _buildRecentQuizCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Sem Título';
    final isPublic = data['isPublic'] ?? false;
    final imageUrl = data['imageUrl'] ?? 'https://picsum.photos/seed/$id/400';

    return InkWell(
      onTap: () => context.pushNamed('EditarQuiz', queryParameters: {'quizId': id}),
      child: Container(
        decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)), 
                child: Image.network(imageUrl, fit: BoxFit.cover)
              )
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(color: Color(0xFFC2C2DD), borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.0))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Icon(isPublic ? Icons.public : Icons.lock, size: 12),
                  ]),
                  Align(alignment: Alignment.centerLeft, child: Text(_timeAgo(data['createdAt'] as Timestamp?), style: const TextStyle(fontSize: 10))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(8.0)),
      child: IconButton(
        icon: Icon(Icons.add_rounded, color: FlutterFlowTheme.of(context).alternate, size: 48.0),
        onPressed: () => context.pushNamed(AddQuizWidget.routeName),
      ),
    );
  }
}