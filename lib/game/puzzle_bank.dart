import 'dart:math';

import '../services/firestore_service.dart';

class GamePuzzle {
  GamePuzzle(Iterable<int> numbers)
      : numbers = List<int>.unmodifiable(numbers);

  final List<int> numbers;
}

class PuzzleDeck {
  PuzzleDeck({
    Random? random,
    Set<String> solvedKeys = const {},
  })  : _random = random ?? Random(),
        _solvedKeys = Set<String>.from(solvedKeys) {
    _refill();
  }

  final Random _random;
  final Set<String> _solvedKeys;
  List<List<int>> _remaining = [];

  static const List<List<int>> _templates = [
    // --- Originais (16) ---
    [6, 2, 1, 3], // 6 - 2 = 1 + 3
    [9, 3, 4, 2], // 9 - 3 = 4 + 2
    [8, 5, 6, 3], // 8 - 5 = 6 - 3
    [7, 2, 4, 1], // 7 - 2 = 4 + 1
    [8, 2, 3, 3], // 8 - 2 = 3 + 3
    [9, 4, 6, 1], // 9 - 4 = 6 - 1
    [7, 3, 2, 2], // 7 - 3 = 2 + 2
    [9, 2, 5, 2], // 9 - 2 = 5 + 2
    [1, 2, 3, 6], // 1 / 2 = 3 / 6 (fácil) ou 6 / 3 = 2 * 1
    [5, 2, 6, 1], // 5 + 2 = 6 + 1
    [4, 2, 3, 1], // 4 + 1 = 3 + 2
    [8, 4, 5, 1], // 8 - 4 = 5 - 1
    [7, 4, 5, 2], // 7 - 4 = 5 - 2
    [6, 3, 5, 2], // 6 - 3 = 5 - 2
    [9, 6, 5, 2], // 9 - 6 = 5 - 2
    [8, 3, 7, 2], // 8 - 3 = 7 - 2

    // --- Apenas 1 número em um dos lados da igualdade (14) ---
    [9, 4, 3, 2], // 9 = 4 + 3 + 2
    [8, 5, 2, 1], // 8 = 5 + 2 + 1
    [7, 4, 2, 1], // 7 = 4 + 2 + 1
    [9, 5, 3, 1], // 9 = 5 + 3 + 1
    [6, 9, 2, 1], // 6 = 9 - 2 - 1
    [5, 9, 3, 1], // 5 = 9 - 3 - 1
    [4, 8, 3, 1], // 4 = 8 - 3 - 1
    [8, 4, 2, 1], // 8 = 4 * 2 * 1
    [6, 3, 2, 1], // 6 = 3 * 2 * 1
    [9, 3, 3, 1], // 9 = 3 * 3 * 1
    [8, 3, 2, 2], // 8 = (3 * 2) + 2
    [7, 3, 2, 1], // 7 = (3 * 2) + 1
    [9, 4, 2, 1], // 9 = (4 * 2) + 1
    [5, 3, 2, 1], // 5 = (3 * 2) - 1

    // --- Multiplicação e Divisão (14) ---
    [6, 2, 4, 3], // 6 * 2 = 4 * 3
    [8, 2, 4, 4], // 8 * 2 = 4 * 4
    [9, 2, 6, 3], // 9 * 2 = 6 * 3
    [6, 1, 3, 2], // 6 * 1 = 3 * 2
    [8, 1, 4, 2], // 8 * 1 = 4 * 2
    [9, 1, 3, 3], // 9 * 1 = 3 * 3
    [8, 4, 6, 3], // 8 / 4 = 6 / 3
    [9, 3, 6, 2], // 9 / 3 = 6 / 2
    [8, 2, 4, 1], // 8 / 2 = 4 / 1
    [6, 3, 4, 2], // 6 / 3 = 4 / 2
    [6, 2, 9, 6], // 6 / 2 = 9 / 3 (distinto: [2,3,6,9]) -> 6 - 3 = 9 / 3
    [8, 4, 2, 2], // 8 / 4 = 2 / 1 -> 8 / 2 = 4 / 1 (aqui: 8 / 2 = 2 + 2)
    [9, 3, 5, 2], // 9 / 3 = 5 - 2
    [8, 2, 7, 3], // 8 / 2 = 7 - 3
  ];

  bool get allSolved => _templates
      .every((t) => _solvedKeys.contains(FirestoreService.puzzleKey(t)));

  void markSolved(List<int> numbers) {
    _solvedKeys.add(FirestoreService.puzzleKey(numbers));
    _remaining.removeWhere(
      (item) =>
          FirestoreService.puzzleKey(item) ==
          FirestoreService.puzzleKey(numbers),
    );
  }

  void _refill() {
    final unsolved = _templates
        .where(
          (values) => !_solvedKeys.contains(FirestoreService.puzzleKey(values)),
        )
        .map((values) => List<int>.from(values))
        .toList();

    _remaining = unsolved.isNotEmpty
        ? unsolved
        : _templates.map((values) => List<int>.from(values)).toList();

    _remaining.shuffle(_random);
  }

  GamePuzzle next() {
    if (_remaining.isEmpty) _refill();
    final numbers = List<int>.from(_remaining.removeLast())..shuffle(_random);
    return GamePuzzle(numbers);
  }
}