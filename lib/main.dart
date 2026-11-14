import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/login_screen.dart';
import 'firebase_options.dart';
import 'game/difficulty_screen.dart';
import 'game/game_difficulty.dart';
import 'game/game_screen.dart';
import 'l10n/app_localizations.dart';
import 'profile/profile_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/route_persistence_service.dart';

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authListenable = _AuthStateListenable();

GoRouter _createRouter(RoutePersistenceService routePersistence) {
  final isInitiallyLoggedIn = FirebaseAuth.instance.currentUser != null;
  final initialRoute =
      isInitiallyLoggedIn ? routePersistence.getSavedRoute() : '/login';

  final router = GoRouter(
    initialLocation: initialRoute,
    refreshListenable: _authListenable,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return routePersistence.getSavedRoute();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/difficulty',
        builder: (context, state) => const DifficultyScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/game/:difficulty',
        builder: (context, state) {
          final name = state.pathParameters['difficulty'];

          final difficulty = GameDifficulty.values.firstWhere(
            (value) => value.name == name,
            orElse: () => GameDifficulty.easy,
          );

          return GameScreen(difficulty: difficulty);
        },
      ),
    ],
  );

  // Grava toda mudança de página autenticada no SharedPreferences
  router.routerDelegate.addListener(() {
    if (FirebaseAuth.instance.currentUser != null) {
      final currentLocation = router.routerDelegate.currentConfiguration.uri
          .toString();
      routePersistence.saveRoute(currentLocation);
    }
  });

  return router;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: LoginScreen.googleWebClientId),
  ]);

  final routePersistence = await RoutePersistenceService.create();
  final router = _createRouter(routePersistence);

  runApp(
    ProviderScope(
      child: EmplakeApp(router: router),
    ),
  );
}

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Emplak3',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FirebaseUILocalizations.delegate,
      ],
      themeMode: settings.themeMode,
      theme: _buildTheme(
        settings.seedColor,
        Brightness.light,
        settings.textFontFamily,
      ),
      darkTheme: _buildTheme(
        settings.seedColor,
        Brightness.dark,
        settings.textFontFamily,
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final systemScale = mediaQuery.textScaler.scale(1);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(systemScale * settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeData _buildTheme(
    Color seed,
    Brightness brightness,
    AppFontFamily textFontFamily,
  ) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: textFontFamily.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}