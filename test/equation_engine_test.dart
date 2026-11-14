import 'package:flutter_test/flutter_test.dart';
import 'package:emplake/game/equation_engine.dart';
import 'package:emplake/game/game_difficulty.dart';

void main() {
  group('EquationEngine', () {
    test('aceita uma igualdade aritmética no nível difícil', () {
      final result = EquationEngine.validate(
        left: '6 - 2',
        right: '1 + 3',
        puzzleNumbers: [6, 2, 1, 3],
        difficulty: GameDifficulty.hard,
      );

      expect(result.isCorrect, isTrue);
    });

    test('permite divisão não inteira apenas no nível fácil', () {
      final easyResult = EquationEngine.validate(
        left: '1 / 2',
        right: '3 / 6',
        puzzleNumbers: [1, 2, 3, 6],
        difficulty: GameDifficulty.easy,
      );
      final hardResult = EquationEngine.validate(
        left: '1 / 2',
        right: '3 / 6',
        puzzleNumbers: [1, 2, 3, 6],
        difficulty: GameDifficulty.hard,
      );

      expect(easyResult.isCorrect, isTrue);
      expect(hardResult.isCorrect, isFalse);
      expect(hardResult.message, contains('divisão deve ter resultado inteiro'));
    });

    test('recusa uma expressão que não utiliza todos os números', () {
      final result = EquationEngine.validate(
        left: '6 - 2',
        right: '1',
        puzzleNumbers: [6, 2, 1, 3],
        difficulty: GameDifficulty.easy,
      );

      expect(result.isCorrect, isFalse);
      expect(result.message, contains('quatro números'));
    });

    test('produz LaTeX para raiz e potência', () {
      final latex = EquationEngine.tryBuildLatex('√ ( 8 + 1 )', '3 ** 1');

      expect(latex, isNotNull);
      expect(latex, contains(r'\sqrt'));
      expect(latex, contains('^{1}'));
    });
  });
}
