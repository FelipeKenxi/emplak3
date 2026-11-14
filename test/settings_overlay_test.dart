import 'package:emplake/game/game_navigation_bar.dart';
import 'package:emplake/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings overlay closes without replacing the current screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: const Text('Current screen'),
              bottomNavigationBar: GameNavigationBar(
                onHelp: () {},
                onSettings: () => showSettingsOverlay(context),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Config.'));
    await tester.pumpAndSettle();

    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Current screen'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byTooltip('Config.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aparência'), findsNothing);
    expect(find.text('Current screen'), findsOneWidget);
  });
}
