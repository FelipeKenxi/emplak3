import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../l10n/app_localizations.dart';
import '../providers/game_provider.dart';
import '../services/firestore_service.dart';
import '../settings/settings_screen.dart';
import 'game_difficulty.dart';
import 'game_navigation_bar.dart';

class DifficultyScreen extends ConsumerStatefulWidget {
  const DifficultyScreen({super.key});

  @override
  ConsumerState<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends ConsumerState<DifficultyScreen> {
  late Future<UserProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ref.read(firestoreServiceProvider).fetchUserProgress();
  }

  void _refreshProgress() {
    setState(() {
      _progressFuture = ref.read(firestoreServiceProvider).fetchUserProgress();
    });
  }

  Future<void> _startGame() async {
    final difficulty = ref.read(selectedDifficultyProvider);
    await context.push('/game/${difficulty.name}');
    // Atualiza pontuações ao voltar da partida
    _refreshProgress();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? l10n.playerName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ActionChip(
                avatar: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person_rounded, size: 16)
                      : null,
                ),
                label: Text(userName),
                tooltip: l10n.profileAndHistory,
                onPressed: () async {
                  await context.push('/profile');
                  _refreshProgress();
                },
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth > 850 ? 760.0 : 620.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeCard(colors, userName, l10n),
                    const SizedBox(height: 24),
                    Text(
                      l10n.yourScores,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<UserProgressData>(
                      future: _progressFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: colors.primary,
                                size: 38,
                              ),
                            ),
                          );
                        }

                        final scores =
                            snapshot.data?.scores ??
                            UserProgressData.empty().scores;


                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if(snapshot.hasError)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  l10n.historyLoadError('${snapshot.error}'),
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                              _buildScoreGrid(context, scores),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    Text(
                      l10n.chooseDifficulty,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ...GameDifficulty.values.map(
                      (difficulty) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildDifficultyOption(
                          context,
                          difficulty,
                          selected: difficulty == selectedDifficulty,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        l10n.startWithDifficulty(
                          selectedDifficulty.localizedLabel(l10n),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: GameNavigationBar(
        onSettings: () => showSettingsOverlay(context),
        onHelp: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.help),
            content: Text(l10n.difficultyHelpText),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.understood),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(
    ColorScheme colors,
    String userName,
    AppLocalizations l10n,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.secondaryContainer],
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.account_circle_rounded, size: 48, color: colors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helloPlayer(userName),
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tapToViewHistory,
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.onPrimaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreGrid(
    BuildContext context,
    Map<GameDifficulty, int> scores,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 430 ? 2 : 4;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 10) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: GameDifficulty.values.map((difficulty) {
            return SizedBox(
              width: itemWidth,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        difficulty.localizedLabel(l10n),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${scores[difficulty] ?? 0}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        l10n.points,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDifficultyOption(
    BuildContext context,
    GameDifficulty difficulty, {
    required bool selected,
  }) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(selectedDifficultyProvider.notifier).select(difficulty);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.localizedLabel(l10n),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      switch (difficulty) {
                        GameDifficulty.easy => l10n.descEasy,
                        GameDifficulty.intermediate => l10n.descIntermediate,
                        GameDifficulty.advanced => l10n.descAdvanced,
                        GameDifficulty.hard => l10n.descHard,
                      },
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
