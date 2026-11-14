import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

import '../providers/locale_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const String googleWebClientId =
      '288950992316-n2c3j6or86eq1ljcll06ochn4bi4rq4h.apps.googleusercontent.com';


  Widget _buildBrandHeader(
    BuildContext context,
    WidgetRef ref, {
    bool isSide = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seletor de idioma com bandeiras (requisito obrigatório na tela de login)
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<String>(value: 'pt', label: Text('🇧🇷 Português')),
              ButtonSegment<String>(value: 'en', label: Text('🇺🇸 English')),
            ],
            selected: {currentLocale.languageCode},
            onSelectionChanged: (selection) {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(selection.first));
            },
          ),
          SizedBox(height: isSide ? 28 : 14),
          Icon(
            Icons.calculate_rounded,
            size: isSide ? 72 : 48,
            color: colors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.appTitle,
            style:
                (isSide
                        ? Theme.of(context).textTheme.displayMedium
                        : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(clientId: googleWebClientId),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          context.go('/difficulty');
        }),
        AuthStateChangeAction<UserCreated>((context, state) {
          context.go('/difficulty');
        }),
      ],
      // Exibido em telas estreitas (< 800px)
      headerMaxExtent: 250,
      headerBuilder: (context, constraints, shrinkOffset) {
        return _buildBrandHeader(context, ref, isSide: false);
      },
      // Exibido em telas largas / Web (>= 800px)
      sideBuilder: (context, constraints) {
        return Container(
          color: colors.surfaceContainerLow,
          child: Center(child: _buildBrandHeader(context, ref, isSide: true)),
        );
      },
      footerBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.groupMembersTitle,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Felipe Pregnolatto Melo',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.copyrightNotice,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    l10n.betaVersion,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
