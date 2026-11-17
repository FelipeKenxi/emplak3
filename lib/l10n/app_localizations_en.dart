// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplak3';

  @override
  String get betaVersion => 'Beta version';

  @override
  String get groupMembersTitle => 'Group members:';

  @override
  String get copyrightNotice =>
      'Project based on the Emplake program. All rights reserved to Walter Alexandre Carnielli.';

  @override
  String get languageLabel => 'Language';

  @override
  String get playerName => 'Player';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemTheme => 'Device default';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get textSection => 'Text';

  @override
  String get textFont => 'Text font';

  @override
  String get fontSystem => 'System default';

  @override
  String get fontSansSerif => 'Sans serif';

  @override
  String get fontSerif => 'Serif';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get textSize => 'Text size';

  @override
  String get textExample => 'Sample text';

  @override
  String get appColor => 'App color';

  @override
  String get seedColorHint =>
      'Choose a seed color to generate the theme palette.';

  @override
  String get preview => 'Preview';

  @override
  String get changesImmediate => 'Changes are applied immediately.';

  @override
  String get justNow => 'Just now';

  @override
  String historyLoadError(String error) {
    return 'Could not load history: $error';
  }

  @override
  String get profileHelpText =>
      'Here you can see all equations you have solved in your account.';

  @override
  String get leftSide => 'left';

  @override
  String get rightSide => 'right';

  @override
  String selectEquationSide(String side) {
    return 'Select the $side side of the equation';
  }

  @override
  String addOperator(String operator) {
    return 'Add $operator';
  }

  @override
  String get powerOperator => 'power';

  @override
  String get moduloOperator => 'modulo';

  @override
  String get floorOperator => 'floor';

  @override
  String get ceilingOperator => 'ceiling';

  @override
  String helloPlayer(String name) {
    return 'Hello, $name!';
  }

  @override
  String get tapToViewHistory => 'Tap here to view your solution history.';

  @override
  String get yourScores => 'Your scores';

  @override
  String get points => 'points';

  @override
  String get chooseDifficulty => 'Choose a difficulty';

  @override
  String startWithDifficulty(String difficulty) {
    return 'Start • $difficulty';
  }

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffIntermediate => 'Intermediate';

  @override
  String get diffAdvanced => 'Advanced';

  @override
  String get diffHard => 'Hard';

  @override
  String get descEasy => 'All operators available.';

  @override
  String get descIntermediate => 'Includes powers, roots, and factorial.';

  @override
  String get descAdvanced => 'A smaller set of operators.';

  @override
  String get descHard => 'Basic operations only.';

  @override
  String get help => 'Help';

  @override
  String get settings => 'Settings';

  @override
  String get understood => 'Got it';

  @override
  String get difficultyHelpText =>
      'Choose a difficulty and tap Start to begin a new challenge. Tap your name at the top to view your profile and solution history.';

  @override
  String get backToDifficulties => 'Back to difficulties';

  @override
  String get profileAndHistory => 'Profile & History';

  @override
  String get tapToAdd => 'Tap to add';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get verifyEquation => 'Verify equation';

  @override
  String get undoLast => 'Undo last item';

  @override
  String get skipPuzzle => 'Skip challenge';

  @override
  String get howToPlay => 'How to play';

  @override
  String get gameHelpText =>
      'Tap one side of the equals sign to choose where to insert the next elements. Then, tap the four numbers and operators to build an expression on each side. Each number must be used exactly once.\n\nYou can also tap any placed token (or before the first one) to move the cursor and insert parentheses, modulo, or operators at any position in the equation.\n\nWhen finished, tap Verify. Available operators vary by difficulty. For absolute value, use | before and after the expression; for floor and ceiling, use ⌊…⌋ and ⌈…⌉.';

  @override
  String get useAllFourNumbers =>
      'Use all four numbers before verifying the equation.';

  @override
  String get fillBothSides => 'Fill in both sides of the equation.';

  @override
  String equationMismatch(String left, String right) {
    return 'The equality does not hold: $left ≠ $right.';
  }

  @override
  String get equationCorrect => 'Correct! You found a valid equality.';

  @override
  String get outOfRange =>
      'The expression produces a value outside the allowed range.';

  @override
  String operatorNotAllowed(String operator, String difficulty) {
    return 'The operator “$operator” is not available on $difficulty level.';
  }

  @override
  String get useProvidedNumbersOnly =>
      'Use only the numbers provided by the challenge.';

  @override
  String get useEachNumberOnce =>
      'You must use each of the four numbers exactly once.';

  @override
  String get noExtraNumbers =>
      'Use each provided number exactly once, without adding other numbers.';

  @override
  String unrecognizedChar(String char) {
    return 'Unrecognized character: “$char”.';
  }

  @override
  String get enterMathExpression => 'Enter a mathematical expression.';

  @override
  String get negativeSqrt =>
      'Cannot compute the real square root of a negative number.';

  @override
  String get invalidFactorial =>
      'Factorial can only be applied to non-negative integers.';

  @override
  String get factorialTooLarge =>
      'The factorial result is too large for this game.';

  @override
  String get divisionByZero => 'Division by zero is not allowed.';

  @override
  String integerDivisionOnly(String difficulty) {
    return 'On $difficulty level, every division must result in an integer.';
  }

  @override
  String get notFiniteResult =>
      'The operation does not produce a finite real number.';

  @override
  String unexpectedToken(String token) {
    return 'Unexpected token: “$token”.';
  }

  @override
  String get incompleteExpression =>
      'The expression ended before being completed.';

  @override
  String expectedNumberOrParen(String token) {
    return 'Expected a number or “(”, but found “$token”.';
  }

  @override
  String expectedToken(String expected) {
    return 'Expected “$expected”.';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get solvedSolutions => 'Solved Solutions';

  @override
  String get noSolutionsYet => 'You haven\'t solved any challenges yet.';

  @override
  String get completePuzzlePrompt =>
      'Complete an equation in the game to record it here!';

  @override
  String numbersLabel(String numbers) {
    return 'Numbers: $numbers';
  }

  @override
  String solvedAtLabel(String date) {
    return 'Solved on $date';
  }

  @override
  String get saveSolutionError =>
      'Could not save your score to the cloud. Check your connection.';
}
