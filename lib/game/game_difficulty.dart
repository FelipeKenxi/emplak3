import '../l10n/app_localizations.dart';

enum GameDifficulty { easy, intermediate, advanced, hard }

extension GameDifficultyRules on GameDifficulty {
  String get label => switch (this) {
    GameDifficulty.easy => 'Fácil',
    GameDifficulty.intermediate => 'Intermediário',
    GameDifficulty.advanced => 'Avançado',
    GameDifficulty.hard => 'Difícil',
  };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    GameDifficulty.easy => l10n.diffEasy,
    GameDifficulty.intermediate => l10n.diffIntermediate,
    GameDifficulty.advanced => l10n.diffAdvanced,
    GameDifficulty.hard => l10n.diffHard,
  };

  /// Somente o nível Fácil permite que uma divisão produza um valor fracionário.
  bool get allowsFractionalDivision => this == GameDifficulty.easy;

  /// Operadores que aparecem na paleta da interface.
  /// Parênteses são permitidos em todos os níveis.
  List<String> get availableOperators => switch (this) {
    GameDifficulty.easy => const [
      '+',
      '-',
      '*',
      '/',
      '(',
      ')',
      '√',
      '∛',
      '!',
      '**',
      '|',
      '⌊',
      '⌋',
      '⌈',
      '⌉',
    ],
    GameDifficulty.intermediate => const [
      '+',
      '-',
      '*',
      '/',
      '(',
      ')',
      '√',
      '∛',
      '!',
      '**',
      '|',
    ],
    GameDifficulty.advanced => const [
      '+',
      '-',
      '*',
      '/',
      '(',
      ')',
      '√',
      '!',
      '|',
    ],
    GameDifficulty.hard => const ['+', '-', '*', '/', '(', ')', '|'],
  };

  bool allowsOperator(String operator) {
    if (operator == '(' || operator == ')') return true;
    return availableOperators.contains(operator);
  }
}
