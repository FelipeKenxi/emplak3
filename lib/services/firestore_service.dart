import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_difficulty.dart';

class SolvedSolutionRecord {
  const SolvedSolutionRecord({
    required this.id,
    required this.numbers,
    required this.difficulty,
    required this.expression,
    required this.latex,
    required this.solvedAt,
  });

  final String id;
  final List<int> numbers;
  final GameDifficulty difficulty;
  final String expression;
  final String latex;
  final DateTime? solvedAt;

  factory SolvedSolutionRecord.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final diffName = data['difficulty'] as String? ?? 'easy';
    final difficulty = GameDifficulty.values.firstWhere(
      (d) => d.name == diffName,
      orElse: () => GameDifficulty.easy,
    );

    return SolvedSolutionRecord(
      id: doc.id,
      numbers: List<int>.from(data['numbers'] ?? const <int>[]),
      difficulty: difficulty,
      expression: data['expression'] as String? ?? '',
      latex: data['latex'] as String? ?? '',
      solvedAt: (data['solvedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserProgressData {
  const UserProgressData({
    required this.scores,
    required this.solvedKeys,
  });

  final Map<GameDifficulty, int> scores;
  final Set<String> solvedKeys;

  factory UserProgressData.empty() => const UserProgressData(
        scores: {
          GameDifficulty.easy: 0,
          GameDifficulty.intermediate: 0,
          GameDifficulty.advanced: 0,
          GameDifficulty.hard: 0,
        },
        solvedKeys: {},
      );
}

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Gera uma chave única independente da ordem embaralhada (ex: [6,2,1,3] -> "1-2-3-6").
  static String puzzleKey(List<int> numbers) {
    final sorted = List<int>.from(numbers)..sort();
    return sorted.join('-');
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<UserProgressData> fetchUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) return UserProgressData.empty();

    final snapshot = await _userDoc(user.uid).get();
    if (!snapshot.exists) {
      return UserProgressData.empty();
    }

    final data = snapshot.data() ?? {};
    final rawScores = Map<String, dynamic>.from(data['scores'] ?? {});
    final scores = <GameDifficulty, int>{};

    for (final diff in GameDifficulty.values) {
      scores[diff] = (rawScores[diff.name] as num?)?.toInt() ?? 0;
    }

    final solvedKeys = Set<String>.from(data['solvedKeys'] ?? const <String>[]);

    return UserProgressData(
      scores: scores,
      solvedKeys: solvedKeys,
    );
  }

  Future<void> recordSolvedPuzzle({
    required List<int> numbers,
    required GameDifficulty difficulty,
    required String expression,
    required String latex,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final key = puzzleKey(numbers);
    final userRef = _userDoc(user.uid);
    final solutionRef = userRef.collection('solutions').doc();

    final pointsEarned = switch (difficulty) {
      GameDifficulty.easy => 10,
      GameDifficulty.intermediate => 20,
      GameDifficulty.advanced => 30,
      GameDifficulty.hard => 40,
    };

    final batch = _db.batch();

    batch.set(
      userRef,
      {
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'Jogador',
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
        'scores': {
          difficulty.name: FieldValue.increment(pointsEarned),
        },
        'solvedKeys': FieldValue.arrayUnion([key]),
      },
      SetOptions(merge: true),
    );

    batch.set(solutionRef, {
      'puzzleKey': key,
      'numbers': numbers,
      'difficulty': difficulty.name,
      'expression': expression,
      'latex': latex,
      'points': pointsEarned,
      'solvedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<List<SolvedSolutionRecord>> fetchSolvedHistory() async {
    final user = _auth.currentUser;
    if (user == null) return const [];

    final querySnapshot = await _userDoc(user.uid)
        .collection('solutions')
        .orderBy('solvedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => SolvedSolutionRecord.fromDoc(doc))
        .toList();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userProgressProvider = FutureProvider<UserProgressData>((ref) async {
  return ref.watch(firestoreServiceProvider).fetchUserProgress();
});