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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 1.5,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard('Quizzes Públicos', pub.toString(), Icons.menu_book_rounded, const Color(0xFF99CCFF), const Color(0xFF2B2D4A)),
                          _buildStatCard('Quizzes Privados', priv.toString(), Icons.lock, const Color(0xFFFC8883), const Color(0xFFB33036)),
                          _buildStatCard('Perguntas Criadas', totalQuestions.toString(), Icons.format_list_numbered_rounded, const Color(0xFFFFEBB2), const Color(0xFF997A00)),
                          _buildStatCard('Total de Quizzes', allQuizzes.length.toString(), Icons.folder_special_rounded, const Color(0xFFC3FFB2), const Color(0xFF1C6B1C)),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 6 : (MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2)),
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.9,
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
                    const SizedBox(height: 80.0),
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
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(12.0), 
        border: Border.all(color: iconColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 36.0),
              Text(value, style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold), fontSize: 36.0, color: iconColor)),
            ],
          ),
          Align(alignment: Alignment.centerLeft, child: Text(label, style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), fontSize: 14.0, color: iconColor))),
        ],
      ),
    );
  }

  Widget _buildRecentQuizCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Sem Título';
    final isPublic = data['isPublic'] ?? false;
    final rawImg = data['imageUrl'];
    final imageUrl = (rawImg == null || rawImg.toString().trim().isEmpty) ? 'https://picsum.photos/seed/$id/400' : rawImg.toString();

    return InkWell(
      onTap: () => context.pushNamed('EditarQuiz', queryParameters: {'quizId': id}),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground, 
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)), 
                child: Image.network(
                  imageUrl, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                )
              )
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Color(0xFFEBEBF0), 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0))
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B1C33)))),
                    Icon(isPublic ? Icons.public : Icons.lock, size: 14, color: const Color(0xFF1B1C33)),
                  ]),
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerLeft, child: Text(_timeAgo(data['createdAt'] as Timestamp?), style: const TextStyle(fontSize: 11, color: Color(0xFF5A5A5A)))),
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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground, 
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.add_rounded, color: FlutterFlowTheme.of(context).alternate, size: 48.0),
        onPressed: () => context.pushNamed(AddQuizWidget.routeName),
      ),
    );
  }
}