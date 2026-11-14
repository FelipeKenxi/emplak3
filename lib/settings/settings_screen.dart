import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

Future<void> showSettingsOverlay(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(dialogContext).height - 80,
        ),
        child: SizedBox(
          width: 560,
          height: 760,
          child: SettingsScreen(
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    ),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  static const colors = [
    Color(0xFF5A56D6),
    Color(0xFF2196F3),
    Color(0xFF009688),
    Color(0xFFE91E63),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: [
          IconButton(
            onPressed: onClose,
            tooltip: l10n.close,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.appearance, style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.systemTheme),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setThemeMode(value);
                    }
                  },
                ),

                RadioListTile<ThemeMode>(
                  title: Text(l10n.lightTheme),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setThemeMode(value);
                    }
                  },
                ),

                RadioListTile<ThemeMode>(
                  title: Text(l10n.darkTheme),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setThemeMode(value);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(l10n.textSection, style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<AppFontFamily>(
                initialValue: settings.textFontFamily,
                decoration: InputDecoration(
                  labelText: l10n.textFont,
                  border: OutlineInputBorder(),
                ),
                items: AppFontFamily.values
                    .map(
                      (font) => DropdownMenuItem(
                        value: font,
                        child: Text(switch (font) {
                          AppFontFamily.system => l10n.fontSystem,
                          AppFontFamily.sansSerif => l10n.fontSansSerif,
                          AppFontFamily.serif => l10n.fontSerif,
                          AppFontFamily.monospace => l10n.fontMonospace,
                        }, style: TextStyle(fontFamily: font.fontFamily)),
                      ),
                    )
                    .toList(),
                onChanged: (font) {
                  if (font != null) {
                    notifier.setTextFontFamily(font);
                  }
                },
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.textSize)),
                      Text('${(settings.textScale * 100).round()}%'),
                    ],
                  ),
                  Slider(
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    value: settings.textScale,
                    label: '${(settings.textScale * 100).round()}%',
                    onChanged: notifier.setTextScale,
                  ),
                  Text(
                    l10n.textExample,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(l10n.appColor, style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 8),

          Text(
            l10n.seedColorHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: colors.map((color) {
              final selected =
                  settings.seedColor.toARGB32() == color.toARGB32();

              return InkWell(
                onTap: () => notifier.setSeedColor(color),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.preview),
              subtitle: Text(l10n.changesImmediate),
              trailing: Icon(Icons.circle, color: settings.seedColor),
            ),
          ),
        ],
      ),
    );
  }
}
