import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../settings/settings_screen.dart';
import 'equation_engine.dart';
import 'game_difficulty.dart';
import 'game_navigation_bar.dart';
import 'puzzle_bank.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final GameDifficulty difficulty;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late PuzzleDeck _deck;
  late Future<void> _initFuture;
  final List<_PlacedToken> _leftTokens = [];
  final List<_PlacedToken> _rightTokens = [];

  late GamePuzzle _puzzle;
  Timer? _autoAdvanceTimer;
  GameDifficulty get _difficulty => widget.difficulty;
  bool _leftSideSelected = true;
  String? _feedback;
  bool _feedbackIsSuccess = false;
  bool _isTransitioningPuzzle = false;

  late final AnimationController _fadeInController;
  late final AnimationController _fadeOutController;
  late final List<Animation<double>> _tileFadeInAnimations;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    // Controlador para entrada escalonada (1 número por vez)
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controlador para saída simultânea (todos os 4 números juntos)
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1.0,
    );

    _tileFadeInAnimations = List.generate(4, (index) {
      final start = index * 0.2;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _fadeInController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _initFuture = _initializeDeck();
  }

  Future<void> _initializeDeck() async {
    try {
      final progress = await ref
          .read(firestoreServiceProvider)
          .fetchUserProgress();
      _deck = PuzzleDeck(solvedKeys: progress.solvedKeys);
    } catch (_) {
      _deck = PuzzleDeck();
    }
    _puzzle = _deck.next();
    if (mounted) {
      _fadeInController.forward(from: 0.0);
    }
  }

  List<_PlacedToken> get _activeTokens =>
      _leftSideSelected ? _leftTokens : _rightTokens;

  String _expressionFor(List<_PlacedToken> tokens) =>
      tokens.map((token) => token.text).join(' ');

  String get _leftExpression => _expressionFor(_leftTokens);
  String get _rightExpression => _expressionFor(_rightTokens);

  bool _isNumberUsed(int index) => [
        ..._leftTokens,
        ..._rightTokens,
      ].any((token) => token.numberIndex == index);

  void _appendOperator(String operator) {
    if (_isTransitioningPuzzle) return;
    _cancelAutoAdvance();
    setState(() {
      _activeTokens.add(_PlacedToken(operator));
      _feedback = null;
    });
  }

  void _appendNumber(int index) {
    if (_isTransitioningPuzzle || _isNumberUsed(index)) return;
    _cancelAutoAdvance();
    setState(() {
      _activeTokens.add(
        _PlacedToken(_puzzle.numbers[index].toString(), numberIndex: index),
      );
      _feedback = null;
    });
  }

  void _removeLastToken() {
    if (_isTransitioningPuzzle || _activeTokens.isEmpty) return;
    _cancelAutoAdvance();
    setState(() {
      _activeTokens.removeLast();
      _feedback = null;
    });
  }

  void _clearExpressions() {
    _cancelAutoAdvance();
    _leftTokens.clear();
    _rightTokens.clear();
    _feedback = null;
    _feedbackIsSuccess = false;
  }

  /// Faz todos os números sumirem juntos (fade out) e depois traz os novos
  /// números 1 por vez (fade in).
  Future<void> _nextPuzzleAnimated() async {
    if (_isTransitioningPuzzle) return;
    _cancelAutoAdvance();

    setState(() {
      _isTransitioningPuzzle = true;
    });

    // 1. Fade out simultâneo de todos os números atuais
    await _fadeOutController.reverse();

    if (!mounted) return;

    // 2. Troca o desafio, limpa o quadro e prepara o fade-in do zero
    _fadeInController.value = 0.0;
    setState(() {
      _puzzle = _deck.next();
      _clearExpressions();
      _leftSideSelected = true;
      _isTransitioningPuzzle = false;
    });

    // Restaura a opacidade do grupo para 1.0 e dispara a entrada 1 por vez
    _fadeOutController.value = 1.0;
    await _fadeInController.forward(from: 0.0);
  }

  void _verify() {
    if (_isTransitioningPuzzle) return;
    _cancelAutoAdvance();
    final usedIndexes = <int>{
      ..._leftTokens
          .where((token) => token.numberIndex != null)
          .map((token) => token.numberIndex!),
      ..._rightTokens
          .where((token) => token.numberIndex != null)
          .map((token) => token.numberIndex!),
    };

    if (usedIndexes.length != _puzzle.numbers.length) {
      setState(() {
        _feedback = _l10n.useAllFourNumbers;
        _feedbackIsSuccess = false;
      });
      return;
    }

    final result = EquationEngine.validate(
      left: _leftExpression,
      right: _rightExpression,
      puzzleNumbers: _puzzle.numbers,
      difficulty: _difficulty,
      l10n: _l10n,
    );

    setState(() {
      _feedback = result.message;
      _feedbackIsSuccess = result.isCorrect;
    });
    if (result.isCorrect) {
      final verifiedPuzzle = _puzzle;
      _deck.markSolved(verifiedPuzzle.numbers);

      ref
          .read(firestoreServiceProvider)
          .recordSolvedPuzzle(
            numbers: verifiedPuzzle.numbers,
            difficulty: _difficulty,
            expression: '$_leftExpression = $_rightExpression',
            latex: result.latex ?? _latexPreview,
          )
          .catchError((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_l10n.saveSolutionError)),
            );
          });

      _autoAdvanceTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted &&
            identical(_puzzle, verifiedPuzzle) &&
            _feedbackIsSuccess) {
          _nextPuzzleAnimated();
        }
      });
    }
  }

  void _cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    final l10n = _l10n;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.howToPlay),
        content: SingleChildScrollView(child: Text(l10n.gameHelpText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }

  String _operatorLabel(String operator) => switch (operator) {
        '*' => '×',
        '/' => '÷',
        '**' => 'xʸ',
        '|' => '|  |',
        '⌊' => '⌊',
        '⌋' => '⌋',
        '⌈' => '⌈',
        '⌉' => '⌉',
        _ => operator,
      };

  String _draftLatex(List<_PlacedToken> tokens) {
    if (tokens.isEmpty) return r'\square';

    final latex = StringBuffer();
    var moduleIsOpen = false;
    for (var index = 0; index < tokens.length; index++) {
      final token = tokens[index].text;
      switch (token) {
        case '√':
        case '∛':
          final isCubeRoot = token == '∛';
          final nextToken = index + 1 < tokens.length
              ? tokens[index + 1].text
              : r'\square';
          latex.write(isCubeRoot ? r'\sqrt[3]{' : r'\sqrt{');
          latex.write(nextToken);
          latex.write('}');
          if (index + 1 < tokens.length) index++;
          break;
        case '**':
          final nextToken = index + 1 < tokens.length
              ? tokens[index + 1].text
              : r'\square';
          latex.write('^{$nextToken}');
          if (index + 1 < tokens.length) index++;
          break;
        case '*':
          latex.write(r'\times ');
          break;
        case '/':
          latex.write(r'\div ');
          break;
        case '|':
          if (moduleIsOpen) {
            latex.write(r'\right|');
          } else {
            latex.write(r'\left|');
          }
          moduleIsOpen = !moduleIsOpen;
          break;
        case '⌊':
          latex.write(r'\lfloor ');
          break;
        case '⌋':
          latex.write(r'\rfloor ');
          break;
        case '⌈':
          latex.write(r'\lceil ');
          break;
        case '⌉':
          latex.write(r'\rceil ');
          break;
        default:
          latex.write(token);
          latex.write(' ');
      }
    }

    if (moduleIsOpen) latex.write(r'\right.');
    return latex.toString();
  }

  String get _latexPreview =>
      EquationEngine.tryBuildLatex(
        _leftExpression,
        _rightExpression,
        l10n: _l10n,
      ) ??
      '${_draftLatex(_leftTokens)} = ${_draftLatex(_rightTokens)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = _l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backToDifficulties,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/difficulty');
            }
          },
        ),
        title: Text('${l10n.appTitle} • ${_difficulty.localizedLabel(l10n)}'),
        actions: [
          IconButton(
            tooltip: l10n.profileAndHistory,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.inkDrop(
                color: colors.primary,
                size: 46,
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth =
                  constraints.maxWidth > 720 ? 680.0 : 560.0;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _buildFormulaBoard(colors)),
                            const SizedBox(width: 8),
                            _buildEquationActions(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildFormulaPreview(colors),
                        const SizedBox(height: 12),
                        _buildNumberTiles(colors),
                        const SizedBox(height: 12),
                        _buildOperatorPalette(colors),
                        const SizedBox(height: 12),
                        if (_feedback != null) ...[
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Container(
                              key: ValueKey('$_feedback|$_feedbackIsSuccess'),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _feedbackIsSuccess
                                    ? colors.primaryContainer
                                    : colors.errorContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _feedbackIsSuccess
                                        ? Icons.check_circle
                                        : Icons.info_outline,
                                    color: _feedbackIsSuccess
                                        ? colors.onPrimaryContainer
                                        : colors.onErrorContainer,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _feedback!,
                                      style: TextStyle(
                                        color: _feedbackIsSuccess
                                            ? colors.onPrimaryContainer
                                            : colors.onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: GameNavigationBar(
        onHelp: _showHelpDialog,
        onSettings: () => showSettingsOverlay(context),
      ),
    );
  }

  Widget _buildNumberTiles(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // FadeTransition externo controla o fade-out simultâneo de todos os 4 números
        child: FadeTransition(
          opacity: _fadeOutController,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_puzzle.numbers.length, (index) {
              final used = _isNumberUsed(index);
              final fadeAnimation = _tileFadeInAnimations[index];

              // FadeTransition individual controla a entrada 1 por vez
              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(fadeAnimation),
                  child: SizedBox(
                    width: 66,
                    height: 58,
                    child: FilledButton.tonal(
                      onPressed: used ? null : () => _appendNumber(index),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: used
                            ? colors.surfaceContainerHighest
                            : colors.secondaryContainer,
                        foregroundColor: colors.onSecondaryContainer,
                        disabledBackgroundColor: colors.surfaceContainerHighest,
                        disabledForegroundColor: colors.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _puzzle.numbers[index].toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (used) const Icon(Icons.check, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEquationActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          tooltip: _l10n.verifyEquation,
          onPressed: _isTransitioningPuzzle ? null : _verify,
          icon: const Icon(Icons.check_rounded),
        ),
        IconButton(
          tooltip: _l10n.undoLast,
          onPressed: (_isTransitioningPuzzle || _activeTokens.isEmpty)
              ? null
              : _removeLastToken,
          icon: const Icon(Icons.undo_rounded),
        ),
        IconButton(
          tooltip: _l10n.skipPuzzle,
          onPressed: _isTransitioningPuzzle ? null : _nextPuzzleAnimated,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }

  Widget _buildFormulaPreview(ColorScheme colors) {
    return Container(
      key: const ValueKey('equation-latex-preview'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Math.tex(
            _latexPreview,
            mathStyle: MathStyle.display,
            textStyle: const TextStyle(fontSize: 22),
            onErrorFallback: (error) => Text(
              _l10n.enterMathExpression,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaBoard(ColorScheme colors) {
    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _expressionSide(
                _leftTokens,
                isSelected: _leftSideSelected,
                isLeft: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '=',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ),
            Expanded(
              child: _expressionSide(
                _rightTokens,
                isSelected: !_leftSideSelected,
                isLeft: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expressionSide(
    List<_PlacedToken> tokens, {
    required bool isSelected,
    required bool isLeft,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: _l10n.selectEquationSide(
        isLeft ? _l10n.leftSide : _l10n.rightSide,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(isLeft ? 'equation-side-left' : 'equation-side-right'),
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _leftSideSelected = isLeft),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primaryContainer.withValues(alpha: 0.7)
                  : colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? colors.primary : colors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: tokens.isEmpty
                ? Center(
                    child: Text(
                      isSelected ? _l10n.tapToAdd : _l10n.tapToSelect,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 7,
                    children: tokens
                        .map(
                          (token) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: token.numberIndex == null
                                  ? colors.surfaceContainerHighest
                                  : colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _operatorLabel(token.text),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: token.numberIndex == null
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorPalette(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _difficulty.availableOperators.map((operator) {
            return Semantics(
              button: true,
              label: _l10n.addOperator(_operatorLabel(operator)),
              child: OutlinedButton(
                onPressed: _isTransitioningPuzzle
                    ? null
                    : () => _appendOperator(operator),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  side: BorderSide(color: colors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _operatorLabel(operator),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PlacedToken {
  const _PlacedToken(this.text, {this.numberIndex});

  final String text;
  final int? numberIndex;
}