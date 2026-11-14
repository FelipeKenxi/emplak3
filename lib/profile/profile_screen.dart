import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../l10n/app_localizations.dart';
import '../game/game_difficulty.dart';
import '../game/game_navigation_bar.dart';
import '../services/firestore_service.dart';
import '../settings/settings_screen.dart';
import '../services/route_persistence_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<List<SolvedSolutionRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ref.read(firestoreServiceProvider).fetchSolvedHistory();
  }

  Future<void> _signOut() async {
    final persistence = await RoutePersistenceService.create();
    await persistence.clearRoute();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.justNow;
    return DateFormat.yMd(l10n.localeName).add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? l10n.playerName;

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
        title: Text(l10n.profileAndHistory),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth > 850 ? 760.0 : 620.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  // Cabeçalho do Usuário
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colors.primaryContainer,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 32,
                                    color: colors.onPrimaryContainer,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (user?.email != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user!.email!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.solvedSolutions,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  // FutureBuilder com indicador de progresso customizado (requisito obrigatório)
                  FutureBuilder<List<SolvedSolutionRecord>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: colors.primary,
                              size: 48,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Card(
                          color: colors.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.historyLoadError('${snapshot.error}'),
                              style: TextStyle(color: colors.onErrorContainer),
                            ),
                          ),
                        );
                      }

                      final records = snapshot.data ?? const [];
                      if (records.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_edu_rounded,
                                  size: 44,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.noSolutionsYet,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.completePuzzlePrompt,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: records.map((record) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(
                                            record.difficulty.localizedLabel(
                                              l10n,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Text(
                                          l10n.numbersLabel(
                                            record.numbers.join(', '),
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          record.latex.isNotEmpty
                                              ? record.latex
                                              : record.expression,
                                          textStyle: const TextStyle(
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.solvedAtLabel(
                                        _formatDate(record.solvedAt, l10n),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: GameNavigationBar(
        onHelp: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.help),
            content: Text(l10n.profileHelpText),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.understood),
              ),
            ],
          ),
        ),
        onSettings: () => showSettingsOverlay(context),
      ),
    );
  }
}
