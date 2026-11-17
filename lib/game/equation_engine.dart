import 'dart:math' as math;

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_pt.dart';
import 'game_difficulty.dart';

/// Resultado de uma tentativa de verificação.
class EquationValidationResult {
  const EquationValidationResult({
    required this.isCorrect,
    required this.message,
    this.leftValue,
    this.rightValue,
    this.latex,
  });

  final bool isCorrect;
  final String message;
  final double? leftValue;
  final double? rightValue;
  final String? latex;
}

/// Motor independente da interface Flutter.
///
/// A interface monta os lados esquerdo e direito como strings. Este motor
/// tokeniza, analisa, avalia e verifica se a expressão respeita a dificuldade.
class EquationEngine {
  EquationEngine._();

  static const double _epsilon = 1e-9;

  static EquationValidationResult validate({
    required String left,
    required String right,
    required List<int> puzzleNumbers,
    required GameDifficulty difficulty,
    AppLocalizations? l10n,
  }) {
    final strings = l10n ?? AppLocalizationsPt();
    try {
      if (left.trim().isEmpty || right.trim().isEmpty) {
        throw FormatException(strings.fillBothSides);
      }

      final leftTokens = _tokenize(left, strings);
      final rightTokens = _tokenize(right, strings);
      final allTokens = <_Token>[...leftTokens, ...rightTokens];

      _checkAllowedOperators(allTokens, difficulty, strings);
      _checkNumbersUsedExactlyOnce(allTokens, puzzleNumbers, strings);

      final leftTree = _ExpressionParser(leftTokens, strings).parse();
      final rightTree = _ExpressionParser(rightTokens, strings).parse();
      final leftValue = leftTree.evaluate(difficulty, strings);
      final rightValue = rightTree.evaluate(difficulty, strings);
      final latex = '${leftTree.toLatex()} = ${rightTree.toLatex()}';

      if (!_approximatelyEqual(leftValue, rightValue)) {
        return EquationValidationResult(
          isCorrect: false,
          message: strings.equationMismatch(
            _formatNumber(leftValue),
            _formatNumber(rightValue),
          ),
          leftValue: leftValue,
          rightValue: rightValue,
          latex: latex,
        );
      }

      return EquationValidationResult(
        isCorrect: true,
        message: strings.equationCorrect,
        leftValue: leftValue,
        rightValue: rightValue,
        latex: latex,
      );
    } on FormatException catch (error) {
      return EquationValidationResult(
        isCorrect: false,
        message: _cleanExceptionMessage(error.message.toString()),
      );
    } on RangeError {
      return EquationValidationResult(
        isCorrect: false,
        message: strings.outOfRange,
      );
    }
  }

  /// Converte ambos os lados para TeX. Retorna null enquanto a expressão
  /// estiver incompleta, para a interface poder continuar aceitando tokens.
  static String? tryBuildLatex(
    String left,
    String right, {
    AppLocalizations? l10n,
  }) {
    final strings = l10n ?? AppLocalizationsPt();
    if (left.trim().isEmpty || right.trim().isEmpty) return null;
    try {
      final leftTree = _ExpressionParser(
        _tokenize(left, strings),
        strings,
      ).parse();
      final rightTree = _ExpressionParser(
        _tokenize(right, strings),
        strings,
      ).parse();
      return '${leftTree.toLatex()} = ${rightTree.toLatex()}';
    } on FormatException {
      return null;
    }
  }

  static void _checkAllowedOperators(
    List<_Token> tokens,
    GameDifficulty difficulty,
    AppLocalizations l10n,
  ) {
    const operators = {
      '+',
      '-',
      '*',
      '/',
      '**',
      '!',
      '√',
      '∛',
      '|',
      '⌊',
      '⌋',
      '⌈',
      '⌉',
    };

    for (final token in tokens) {
      if (operators.contains(token.text) &&
          !difficulty.allowsOperator(token.text)) {
        throw FormatException(
          l10n.operatorNotAllowed(
            _displayOperator(token.text, l10n),
            difficulty.localizedLabel(l10n),
          ),
        );
      }
    }
  }

  static void _checkNumbersUsedExactlyOnce(
    List<_Token> tokens,
    List<int> puzzleNumbers,
    AppLocalizations l10n,
  ) {
    final usedNumbers = tokens
        .where((token) => token.type == _TokenType.number)
        .map((token) => int.tryParse(token.text))
        .toList();

    if (usedNumbers.any((value) => value == null)) {
      throw FormatException(l10n.useProvidedNumbersOnly);
    }

    final expected = List<int>.from(puzzleNumbers)..sort();
    final actual = usedNumbers.cast<int>()..sort();

    if (actual.length != expected.length) {
      throw FormatException(l10n.useEachNumberOnce);
    }

    for (var index = 0; index < expected.length; index++) {
      if (actual[index] != expected[index]) {
        throw FormatException(l10n.noExtraNumbers);
      }
    }
  }

  static List<_Token> _tokenize(String expression, AppLocalizations l10n) {
    final tokens = <_Token>[];
    var index = 0;

    while (index < expression.length) {
      final character = expression[index];

      if (character.trim().isEmpty) {
        index++;
        continue;
      }

      if (_isDigit(character)) {
        final start = index;
        while (index < expression.length && _isDigit(expression[index])) {
          index++;
        }
        tokens.add(
          _Token(_TokenType.number, expression.substring(start, index)),
        );
        continue;
      }

      if (expression.startsWith('**', index)) {
        tokens.add(const _Token(_TokenType.operator, '**'));
        index += 2;
        continue;
      }

      const symbols = <String>{
        '+',
        '-',
        '*',
        '/',
        '(',
        ')',
        '√',
        '∛',
        '!',
        '|',
        '⌊',
        '⌋',
        '⌈',
        '⌉',
      };
      if (symbols.contains(character)) {
        tokens.add(_Token(_TokenType.operator, character));
        index++;
        continue;
      }

      throw FormatException(l10n.unrecognizedChar(character));
    }

    if (tokens.isEmpty) {
      throw FormatException(l10n.enterMathExpression);
    }

    return tokens;
  }

  static bool _isDigit(String character) =>
      character.codeUnitAt(0) >= 48 && character.codeUnitAt(0) <= 57;

  static bool _approximatelyEqual(double left, double right) {
    if (!left.isFinite || !right.isFinite) return false;
    final scale = math.max(1.0, math.max(left.abs(), right.abs()));
    return (left - right).abs() <= _epsilon * scale;
  }

  static String _formatNumber(double value) {
    if ((value - value.roundToDouble()).abs() < _epsilon) {
      return value.round().toString();
    }
    return value.toStringAsPrecision(8);
  }

  static String _displayOperator(String operator, AppLocalizations l10n) =>
      switch (operator) {
        '*' => '×',
        '/' => '÷',
        '**' => l10n.powerOperator,
        '|' => l10n.moduloOperator,
        '⌊' || '⌋' => l10n.floorOperator,
        '⌈' || '⌉' => l10n.ceilingOperator,
        _ => operator,
      };

  static String _cleanExceptionMessage(String message) {
    // FormatException.message é Object em algumas versões do Dart.
    final normalized = message.toString();
    return normalized.replaceFirst(RegExp(r'^FormatException: '), '');
  }
}

enum _TokenType { number, operator }

class _Token {
  const _Token(this.type, this.text);

  final _TokenType type;
  final String text;
}

abstract class _ExpressionNode {
  double evaluate(GameDifficulty difficulty, AppLocalizations l10n);
  String toLatex();
}

class _NumberNode implements _ExpressionNode {
  const _NumberNode(this.lexeme);

  final String lexeme;

  @override
  double evaluate(GameDifficulty difficulty, AppLocalizations l10n) =>
      double.parse(lexeme);

  @override
  String toLatex() => lexeme;
}

class _GroupNode implements _ExpressionNode {
  const _GroupNode(this.child);

  final _ExpressionNode child;

  @override
  double evaluate(GameDifficulty difficulty, AppLocalizations l10n) =>
      child.evaluate(difficulty, l10n);

  @override
  String toLatex() => '\\left(${child.toLatex()}\\right)';
}

class _UnaryNode implements _ExpressionNode {
  const _UnaryNode(this.operator, this.operand);

  final String operator;
  final _ExpressionNode operand;

  @override
  double evaluate(GameDifficulty difficulty, AppLocalizations l10n) {
    final value = operand.evaluate(difficulty, l10n);
    switch (operator) {
      case '+':
        return value;
      case '-':
        return -value;
      case 'sqrt':
        if (value < 0) {
          throw FormatException(l10n.negativeSqrt);
        }
        return math.sqrt(value);
      case 'cbrt':
        return value < 0
            ? -math.pow(-value, 1 / 3).toDouble()
            : math.pow(value, 1 / 3).toDouble();
      case 'abs':
        return value.abs();
      case 'floor':
        return value.floorToDouble();
      case 'ceil':
        return value.ceilToDouble();
      case 'factorial':
        if (value < 0 || (value - value.roundToDouble()).abs() > 1e-9) {
          throw FormatException(l10n.invalidFactorial);
        }
        if (value > 170) {
          throw FormatException(l10n.factorialTooLarge);
        }
        var result = 1.0;
        for (var factor = 2; factor <= value.round(); factor++) {
          result *= factor;
        }
        return result;
      default:
        throw FormatException('Operador unário desconhecido: $operator.');
    }
  }

  @override
  String toLatex() {
    final value = operand.toLatex();
    return switch (operator) {
      '+' => '+$value',
      '-' => '-$value',
      'sqrt' => '\\sqrt{$value}',
      'cbrt' => '\\sqrt[3]{$value}',
      'abs' => '\\left|$value\\right|',
      'floor' => '\\left\\lfloor$value\\right\\rfloor',
      'ceil' => '\\left\\lceil$value\\right\\rceil',
      'factorial' => '$value!',
      _ => value,
    };
  }
}

class _BinaryNode implements _ExpressionNode {
  const _BinaryNode(this.left, this.operator, this.right);

  final _ExpressionNode left;
  final String operator;
  final _ExpressionNode right;

  @override
  double evaluate(GameDifficulty difficulty, AppLocalizations l10n) {
    final leftValue = left.evaluate(difficulty, l10n);
    final rightValue = right.evaluate(difficulty, l10n);
    late final double result;

    switch (operator) {
      case '+':
        result = leftValue + rightValue;
        break;
      case '-':
        result = leftValue - rightValue;
        break;
      case '*':
        result = leftValue * rightValue;
        break;
      case '/':
        if (rightValue == 0) {
          throw FormatException(l10n.divisionByZero);
        }
        result = leftValue / rightValue;
        if (!difficulty.allowsFractionalDivision &&
            (result - result.roundToDouble()).abs() > 1e-9) {
          throw FormatException(
            l10n.integerDivisionOnly(difficulty.localizedLabel(l10n)),
          );
        }
        break;
      case '**':
        result = math.pow(leftValue, rightValue).toDouble();
        break;
      default:
        throw FormatException('Operador binário desconhecido: $operator.');
    }

    if (!result.isFinite) {
      throw FormatException(l10n.notFiniteResult);
    }
    return result;
  }

  @override
  String toLatex() {
    final leftLatex = left.toLatex();
    final rightLatex = right.toLatex();
    return switch (operator) {
      '+' => '$leftLatex + $rightLatex',
      '-' => '$leftLatex - $rightLatex',
      '*' => '$leftLatex \\times $rightLatex',
      '/' => '\\frac{$leftLatex}{$rightLatex}',
      '**' => '$leftLatex^{$rightLatex}',
      _ => '$leftLatex $operator $rightLatex',
    };
  }
}

class _ExpressionParser {
  _ExpressionParser(this.tokens, this.l10n);

  final List<_Token> tokens;
  final AppLocalizations l10n;
  int _index = 0;

  _ExpressionNode parse() {
    final expression = _parseAddition();
    if (!_atEnd) {
      throw FormatException(l10n.unexpectedToken(_current!.text));
    }
    return expression;
  }

  _ExpressionNode _parseAddition() {
    var node = _parseMultiplication();
    while (_matches('+') || _matches('-')) {
      final operator = _advance().text;
      final right = _parseMultiplication();
      node = _BinaryNode(node, operator, right);
    }
    return node;
  }

  _ExpressionNode _parseMultiplication() {
    var node = _parseUnary();
    while (_matches('*') || _matches('/')) {
      final operator = _advance().text;
      final right = _parseUnary();
      node = _BinaryNode(node, operator, right);
    }
    return node;
  }

  _ExpressionNode _parseUnary() {
    if (_matches('+') || _matches('-')) {
      final operator = _advance().text;
      return _UnaryNode(operator, _parseUnary());
    }
    if (_matches('√')) {
      _advance();
      return _UnaryNode('sqrt', _parsePostfix());
    }
    if (_matches('∛')) {
      _advance();
      return _UnaryNode('cbrt', _parsePostfix());
    }
    if (_matches('|')) {
      _advance();
      final inner = _parseAddition();
      _expect('|');
      return _UnaryNode('abs', inner);
    }
    if (_matches('⌊')) {
      _advance();
      final inner = _parseAddition();
      _expect('⌋');
      return _UnaryNode('floor', inner);
    }
    if (_matches('⌈')) {
      _advance();
      final inner = _parseAddition();
      _expect('⌉');
      return _UnaryNode('ceil', inner);
    }
    return _parsePower();
  }

  _ExpressionNode _parsePower() {
    var node = _parsePostfix();
    if (_matches('**')) {
      _advance();
      node = _BinaryNode(node, '**', _parseUnary());
    }
    return node;
  }

  _ExpressionNode _parsePostfix() {
    var node = _parsePrimary();
    while (_matches('!')) {
      _advance();
      node = _UnaryNode('factorial', node);
    }
    return node;
  }

  _ExpressionNode _parsePrimary() {
    if (_atEnd) {
      throw FormatException(l10n.incompleteExpression);
    }

    if (_current!.type == _TokenType.number) {
      return _NumberNode(_advance().text);
    }

    if (_matches('(')) {
      _advance();
      final inner = _parseAddition();
      _expect(')');
      return _GroupNode(inner);
    }

    throw FormatException(l10n.expectedNumberOrParen(_current!.text));
  }

  void _expect(String expected) {
    if (!_matches(expected)) {
      throw FormatException(l10n.expectedToken(expected));
    }
    _advance();
  }

  bool _matches(String text) => !_atEnd && _current!.text == text;

  _Token _advance() => tokens[_index++];

  bool get _atEnd => _index >= tokens.length;

  _Token? get _current => _atEnd ? null : tokens[_index];
}
