import 'package:cloud_firestore/cloud_firestore.dart';

class QuizCreateRequest {
  const QuizCreateRequest({
    required this.ownerUid,
    required this.title,
    required this.topic,
    required this.requestedQuestionCount,
    this.isPublic = true,
    this.sourcePrompt,
  });

  final String ownerUid;
  final String title;
  final String topic;
  final int requestedQuestionCount;
  final bool isPublic;
  final String? sourcePrompt;
}

class QuizRepository {
  QuizRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createQuiz(QuizCreateRequest request) async {
    final docRef = await _firestore.collection('quizzes').add({
      'ownerUid': request.ownerUid,
      'title': request.title,
      'topic': request.topic,
      'requestedQuestionCount': request.requestedQuestionCount,
      'questionCount': 0,
      'isPublic': request.isPublic,
      'status': 'draft', // Starts as draft while AI generates questions
      'sourcePrompt': request.sourcePrompt ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // NEW: Save AI generated questions in a subcollection
  Future<void> saveQuestions(String quizId, List<Map<String, dynamic>> questions) async {
    final batch = _firestore.batch();
    final quizRef = _firestore.collection('quizzes').doc(quizId);

    for (final q in questions) {
      final questionDoc = quizRef.collection('questions').doc();
      batch.set(questionDoc, {
        ...q,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Update parent quiz document to 'ready'
    batch.update(quizRef, {
      'status': 'ready',
      'questionCount': questions.length,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // NEW: Stream query to get user quizzes for the UserQuizzes screen
// NEW: Stream query to get user quizzes for the UserQuizzes screen
  Stream<QuerySnapshot> getUserQuizzesStream(String ownerUid) {
    return _firestore
        .collection('quizzes')
        .where('ownerUid', isEqualTo: ownerUid)
        // A ordenação (.orderBy) foi removida daqui para evitar o erro 
        // de 'Missing Composite Index' no Firebase.
        // Vamos ordenar os dados do lado do cliente (no widget).
        .snapshots();
  }

  // Obter os detalhes básicos do Quiz (Título, Duração, etc)
  Future<DocumentSnapshot> getQuiz(String quizId) {
    return _firestore.collection('quizzes').doc(quizId).get();
  }

  // Obter a lista de perguntas geradas pela IA
  Future<List<QueryDocumentSnapshot>> getQuizQuestions(String quizId) async {
    final snapshot = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs;
  }
}