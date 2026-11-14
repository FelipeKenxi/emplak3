import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class GameNavigationBar extends StatelessWidget {
  const GameNavigationBar({
    super.key,
    required this.onHelp,
    required this.onSettings,
    this.selectedIndex = 0,
  });

  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final int selectedIndex;

  void _onTap(BuildContext context, int index) {
    if (index == 0) {
      onHelp();
    } else if (index == 1) {
      onSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return CurvedNavigationBar(
      index: selectedIndex,
      height: 66,
      color: colors.primary,
      buttonBackgroundColor: colors.primary,
      backgroundColor: colors.surface,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 250),
      onTap: (index) => _onTap(context, index),
      items: [
        _item(Icons.help_outline_rounded, l10n.help, colors.onPrimary),
        _item(Icons.settings_outlined, l10n.settings, colors.onPrimary),
      ],
    );
  }

  Widget _item(IconData icon, String label, Color color) {
    return Tooltip(
      message: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 9)),
        ],
      ),
    );
  }
}
