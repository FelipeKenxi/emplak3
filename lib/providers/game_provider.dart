
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_difficulty.dart';

class SelectedDifficultyNotifier extends Notifier<GameDifficulty> {
  @override
  GameDifficulty build() => GameDifficulty.easy;

  void select(GameDifficulty difficulty) {
    state = difficulty;
  }
}

final selectedDifficultyProvider =
    NotifierProvider<SelectedDifficultyNotifier, GameDifficulty>(
  SelectedDifficultyNotifier.new,
);
