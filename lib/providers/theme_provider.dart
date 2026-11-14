
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFontFamily {
  system('Padrão', null),
  sansSerif('Sem serifa', 'sans-serif'),
  serif('Serifada', 'serif'),
  monospace('Monoespaçada', 'monospace');

  const AppFontFamily(this.label, this.fontFamily);

  final String label;
  final String? fontFamily;
}

class ThemeSettings {
  final ThemeMode themeMode;
  final Color seedColor;
  final AppFontFamily textFontFamily;
  final double textScale;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.seedColor = const Color(0xFF5A56D6),
    this.textFontFamily = AppFontFamily.system,
    this.textScale = 1,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    AppFontFamily? textFontFamily,
    double? textScale,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      textScale: textScale ?? this.textScale,
    );
  }
}

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() => const ThemeSettings();

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
  }

  void setTextFontFamily(AppFontFamily fontFamily) {
    state = state.copyWith(textFontFamily: fontFamily);
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }
}

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
  ThemeSettingsNotifier.new,
);
