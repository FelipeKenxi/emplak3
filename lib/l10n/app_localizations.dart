import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplak3'**
  String get appTitle;

  /// No description provided for @betaVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão beta'**
  String get betaVersion;

  /// No description provided for @groupMembersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Integrantes do grupo:'**
  String get groupMembersTitle;

  /// No description provided for @copyrightNotice.
  ///
  /// In pt, this message translates to:
  /// **'Projeto baseado no programa Emplake. Direitos reservados a Walter Alexandre Carnielli.'**
  String get copyrightNotice;

  /// No description provided for @languageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageLabel;

  /// No description provided for @playerName.
  ///
  /// In pt, this message translates to:
  /// **'Jogador'**
  String get playerName;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In pt, this message translates to:
  /// **'Padrão do dispositivo'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get darkTheme;

  /// No description provided for @textSection.
  ///
  /// In pt, this message translates to:
  /// **'Texto'**
  String get textSection;

  /// No description provided for @textFont.
  ///
  /// In pt, this message translates to:
  /// **'Fonte do texto'**
  String get textFont;

  /// No description provided for @fontSystem.
  ///
  /// In pt, this message translates to:
  /// **'Padrão'**
  String get fontSystem;

  /// No description provided for @fontSansSerif.
  ///
  /// In pt, this message translates to:
  /// **'Sem serifa'**
  String get fontSansSerif;

  /// No description provided for @fontSerif.
  ///
  /// In pt, this message translates to:
  /// **'Serifada'**
  String get fontSerif;

  /// No description provided for @fontMonospace.
  ///
  /// In pt, this message translates to:
  /// **'Monoespaçada'**
  String get fontMonospace;

  /// No description provided for @textSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da fonte'**
  String get textSize;

  /// No description provided for @textExample.
  ///
  /// In pt, this message translates to:
  /// **'Exemplo de texto'**
  String get textExample;

  /// No description provided for @appColor.
  ///
  /// In pt, this message translates to:
  /// **'Cor do aplicativo'**
  String get appColor;

  /// No description provided for @seedColorHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a cor semente para gerar a paleta do tema.'**
  String get seedColorHint;

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualização'**
  String get preview;

  /// No description provided for @changesImmediate.
  ///
  /// In pt, this message translates to:
  /// **'As mudanças são aplicadas imediatamente.'**
  String get changesImmediate;

  /// No description provided for @justNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora mesmo'**
  String get justNow;

  /// No description provided for @historyLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o histórico: {error}'**
  String historyLoadError(String error);

  /// No description provided for @profileHelpText.
  ///
  /// In pt, this message translates to:
  /// **'Aqui você acompanha todas as equações que já resolveu em sua conta.'**
  String get profileHelpText;

  /// No description provided for @leftSide.
  ///
  /// In pt, this message translates to:
  /// **'esquerdo'**
  String get leftSide;

  /// No description provided for @rightSide.
  ///
  /// In pt, this message translates to:
  /// **'direito'**
  String get rightSide;

  /// No description provided for @selectEquationSide.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar lado {side} da equação'**
  String selectEquationSide(String side);

  /// No description provided for @addOperator.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar {operator}'**
  String addOperator(String operator);

  /// No description provided for @powerOperator.
  ///
  /// In pt, this message translates to:
  /// **'potência'**
  String get powerOperator;

  /// No description provided for @moduloOperator.
  ///
  /// In pt, this message translates to:
  /// **'módulo'**
  String get moduloOperator;

  /// No description provided for @floorOperator.
  ///
  /// In pt, this message translates to:
  /// **'piso'**
  String get floorOperator;

  /// No description provided for @ceilingOperator.
  ///
  /// In pt, this message translates to:
  /// **'teto'**
  String get ceilingOperator;

  /// No description provided for @helloPlayer.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}!'**
  String helloPlayer(String name);

  /// No description provided for @tapToViewHistory.
  ///
  /// In pt, this message translates to:
  /// **'Toque aqui para ver seu histórico de soluções.'**
  String get tapToViewHistory;

  /// No description provided for @yourScores.
  ///
  /// In pt, this message translates to:
  /// **'Suas pontuações'**
  String get yourScores;

  /// No description provided for @points.
  ///
  /// In pt, this message translates to:
  /// **'pontos'**
  String get points;

  /// No description provided for @chooseDifficulty.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma dificuldade'**
  String get chooseDifficulty;

  /// No description provided for @startWithDifficulty.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar • {difficulty}'**
  String startWithDifficulty(String difficulty);

  /// No description provided for @diffEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get diffEasy;

  /// No description provided for @diffIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get diffIntermediate;

  /// No description provided for @diffAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get diffAdvanced;

  /// No description provided for @diffHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get diffHard;

  /// No description provided for @descEasy.
  ///
  /// In pt, this message translates to:
  /// **'Todos os operadores disponíveis.'**
  String get descEasy;

  /// No description provided for @descIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Inclui potências, raízes e fatorial.'**
  String get descIntermediate;

  /// No description provided for @descAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Um conjunto menor de operadores.'**
  String get descAdvanced;

  /// No description provided for @descHard.
  ///
  /// In pt, this message translates to:
  /// **'Somente operações básicas.'**
  String get descHard;

  /// No description provided for @help.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get help;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Config.'**
  String get settings;

  /// No description provided for @understood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get understood;

  /// No description provided for @difficultyHelpText.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma dificuldade e toque em Iniciar para começar um novo desafio. Toque no seu nome no topo para ver seu perfil e o histórico de soluções.'**
  String get difficultyHelpText;

  /// No description provided for @backToDifficulties.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para dificuldades'**
  String get backToDifficulties;

  /// No description provided for @profileAndHistory.
  ///
  /// In pt, this message translates to:
  /// **'Perfil e histórico'**
  String get profileAndHistory;

  /// No description provided for @tapToAdd.
  ///
  /// In pt, this message translates to:
  /// **'Toque para adicionar'**
  String get tapToAdd;

  /// No description provided for @tapToSelect.
  ///
  /// In pt, this message translates to:
  /// **'Toque para selecionar'**
  String get tapToSelect;

  /// No description provided for @verifyEquation.
  ///
  /// In pt, this message translates to:
  /// **'Verificar equação'**
  String get verifyEquation;

  /// No description provided for @undoLast.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer último elemento'**
  String get undoLast;

  /// No description provided for @skipPuzzle.
  ///
  /// In pt, this message translates to:
  /// **'Pular desafio'**
  String get skipPuzzle;

  /// No description provided for @howToPlay.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get howToPlay;

  /// No description provided for @gameHelpText.
  ///
  /// In pt, this message translates to:
  /// **'Toque em um dos lados da igualdade para escolher onde inserir os próximos elementos. Depois, toque nos quatro números e nos operadores para montar uma expressão em cada lado. Cada número deve ser usado uma única vez.\n\nVocê também pode tocar em qualquer peça já inserida (ou antes da primeira) para mover o cursor e acrescentar parênteses, módulo ou operadores em qualquer posição da equação.\n\nQuando terminar, toque em Verificar. Os operadores disponíveis variam conforme a dificuldade. Para módulo, use | antes e depois da expressão; para piso e teto, use ⌊…⌋ e ⌈…⌉.'**
  String get gameHelpText;

  /// No description provided for @useAllFourNumbers.
  ///
  /// In pt, this message translates to:
  /// **'Use os quatro números antes de verificar a equação.'**
  String get useAllFourNumbers;

  /// No description provided for @fillBothSides.
  ///
  /// In pt, this message translates to:
  /// **'Preencha os dois lados da equação.'**
  String get fillBothSides;

  /// No description provided for @equationMismatch.
  ///
  /// In pt, this message translates to:
  /// **'A igualdade não confere: {left} ≠ {right}.'**
  String equationMismatch(String left, String right);

  /// No description provided for @equationCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Correto! Você encontrou uma igualdade válida.'**
  String get equationCorrect;

  /// No description provided for @outOfRange.
  ///
  /// In pt, this message translates to:
  /// **'A expressão produz um valor fora do intervalo permitido.'**
  String get outOfRange;

  /// No description provided for @operatorNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'O operador “{operator}” não está disponível no nível {difficulty}.'**
  String operatorNotAllowed(String operator, String difficulty);

  /// No description provided for @useProvidedNumbersOnly.
  ///
  /// In pt, this message translates to:
  /// **'Use apenas os números fornecidos pelo desafio.'**
  String get useProvidedNumbersOnly;

  /// No description provided for @useEachNumberOnce.
  ///
  /// In pt, this message translates to:
  /// **'Você precisa usar cada um dos quatro números exatamente uma vez.'**
  String get useEachNumberOnce;

  /// No description provided for @noExtraNumbers.
  ///
  /// In pt, this message translates to:
  /// **'Use cada número fornecido exatamente uma vez, sem acrescentar outros números.'**
  String get noExtraNumbers;

  /// No description provided for @unrecognizedChar.
  ///
  /// In pt, this message translates to:
  /// **'Caractere não reconhecido: “{char}”.'**
  String unrecognizedChar(String char);

  /// No description provided for @enterMathExpression.
  ///
  /// In pt, this message translates to:
  /// **'Digite uma expressão matemática.'**
  String get enterMathExpression;

  /// No description provided for @negativeSqrt.
  ///
  /// In pt, this message translates to:
  /// **'Não é possível calcular a raiz quadrada real de um número negativo.'**
  String get negativeSqrt;

  /// No description provided for @invalidFactorial.
  ///
  /// In pt, this message translates to:
  /// **'O fatorial só pode ser aplicado a inteiros não negativos.'**
  String get invalidFactorial;

  /// No description provided for @factorialTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'O resultado do fatorial é grande demais para este jogo.'**
  String get factorialTooLarge;

  /// No description provided for @divisionByZero.
  ///
  /// In pt, this message translates to:
  /// **'Não é permitido dividir por zero.'**
  String get divisionByZero;

  /// No description provided for @integerDivisionOnly.
  ///
  /// In pt, this message translates to:
  /// **'No nível {difficulty}, toda divisão deve ter resultado inteiro.'**
  String integerDivisionOnly(String difficulty);

  /// No description provided for @notFiniteResult.
  ///
  /// In pt, this message translates to:
  /// **'A operação não produz um número real finito.'**
  String get notFiniteResult;

  /// No description provided for @unexpectedToken.
  ///
  /// In pt, this message translates to:
  /// **'Token inesperado: “{token}”.'**
  String unexpectedToken(String token);

  /// No description provided for @incompleteExpression.
  ///
  /// In pt, this message translates to:
  /// **'A expressão terminou antes de ser concluída.'**
  String get incompleteExpression;

  /// No description provided for @expectedNumberOrParen.
  ///
  /// In pt, this message translates to:
  /// **'Era esperado um número ou “(”, mas foi encontrado “{token}”.'**
  String expectedNumberOrParen(String token);

  /// No description provided for @expectedToken.
  ///
  /// In pt, this message translates to:
  /// **'Era esperado “{expected}”.'**
  String expectedToken(String expected);

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get signOut;

  /// No description provided for @solvedSolutions.
  ///
  /// In pt, this message translates to:
  /// **'Soluções Resolvidas'**
  String get solvedSolutions;

  /// No description provided for @noSolutionsYet.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não resolveu nenhum desafio.'**
  String get noSolutionsYet;

  /// No description provided for @completePuzzlePrompt.
  ///
  /// In pt, this message translates to:
  /// **'Complete uma equação no jogo para registrá-la aqui!'**
  String get completePuzzlePrompt;

  /// No description provided for @numbersLabel.
  ///
  /// In pt, this message translates to:
  /// **'Números: {numbers}'**
  String numbersLabel(String numbers);

  /// No description provided for @solvedAtLabel.
  ///
  /// In pt, this message translates to:
  /// **'Resolvido em {date}'**
  String solvedAtLabel(String date);

  /// No description provided for @saveSolutionError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar sua pontuação na nuvem. Verifique sua conexão.'**
  String get saveSolutionError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
