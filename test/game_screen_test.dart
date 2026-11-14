import 'package:emplake/game/game_difficulty.dart';
import 'package:emplake/game/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('equation sides select directly and Ajuda opens instructions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(difficulty: GameDifficulty.easy)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('equation-side-right')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Toque para selecionar'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Como jogar'), findsOneWidget);
  });
}
