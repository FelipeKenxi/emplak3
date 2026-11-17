// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplak3';

  @override
  String get betaVersion => 'Versão beta';

  @override
  String get groupMembersTitle => 'Integrantes do grupo:';

  @override
  String get copyrightNotice =>
      'Projeto baseado no programa Emplake. Direitos reservados a Walter Alexandre Carnielli.';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get playerName => 'Jogador';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get close => 'Fechar';

  @override
  String get appearance => 'Aparência';

  @override
  String get systemTheme => 'Padrão do dispositivo';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get textSection => 'Texto';

  @override
  String get textFont => 'Fonte do texto';

  @override
  String get fontSystem => 'Padrão';

  @override
  String get fontSansSerif => 'Sem serifa';

  @override
  String get fontSerif => 'Serifada';

  @override
  String get fontMonospace => 'Monoespaçada';

  @override
  String get textSize => 'Tamanho da fonte';

  @override
  String get textExample => 'Exemplo de texto';

  @override
  String get appColor => 'Cor do aplicativo';

  @override
  String get seedColorHint =>
      'Escolha a cor semente para gerar a paleta do tema.';

  @override
  String get preview => 'Pré-visualização';

  @override
  String get changesImmediate => 'As mudanças são aplicadas imediatamente.';

  @override
  String get justNow => 'Agora mesmo';

  @override
  String historyLoadError(String error) {
    return 'Não foi possível carregar o histórico: $error';
  }

  @override
  String get profileHelpText =>
      'Aqui você acompanha todas as equações que já resolveu em sua conta.';

  @override
  String get leftSide => 'esquerdo';

  @override
  String get rightSide => 'direito';

  @override
  String selectEquationSide(String side) {
    return 'Selecionar lado $side da equação';
  }

  @override
  String addOperator(String operator) {
    return 'Adicionar $operator';
  }

  @override
  String get powerOperator => 'potência';

  @override
  String get moduloOperator => 'módulo';

  @override
  String get floorOperator => 'piso';

  @override
  String get ceilingOperator => 'teto';

  @override
  String helloPlayer(String name) {
    return 'Olá, $name!';
  }

  @override
  String get tapToViewHistory =>
      'Toque aqui para ver seu histórico de soluções.';

  @override
  String get yourScores => 'Suas pontuações';

  @override
  String get points => 'pontos';

  @override
  String get chooseDifficulty => 'Escolha uma dificuldade';

  @override
  String startWithDifficulty(String difficulty) {
    return 'Iniciar • $difficulty';
  }

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffIntermediate => 'Intermediário';

  @override
  String get diffAdvanced => 'Avançado';

  @override
  String get diffHard => 'Difícil';

  @override
  String get descEasy => 'Todos os operadores disponíveis.';

  @override
  String get descIntermediate => 'Inclui potências, raízes e fatorial.';

  @override
  String get descAdvanced => 'Um conjunto menor de operadores.';

  @override
  String get descHard => 'Somente operações básicas.';

  @override
  String get help => 'Ajuda';

  @override
  String get settings => 'Config.';

  @override
  String get understood => 'Entendi';

  @override
  String get difficultyHelpText =>
      'Escolha uma dificuldade e toque em Iniciar para começar um novo desafio. Toque no seu nome no topo para ver seu perfil e o histórico de soluções.';

  @override
  String get backToDifficulties => 'Voltar para dificuldades';

  @override
  String get profileAndHistory => 'Perfil e histórico';

  @override
  String get tapToAdd => 'Toque para adicionar';

  @override
  String get tapToSelect => 'Toque para selecionar';

  @override
  String get verifyEquation => 'Verificar equação';

  @override
  String get undoLast => 'Desfazer último elemento';

  @override
  String get skipPuzzle => 'Pular desafio';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get gameHelpText =>
      'Toque em um dos lados da igualdade para escolher onde inserir os próximos elementos. Depois, toque nos quatro números e nos operadores para montar uma expressão em cada lado. Cada número deve ser usado uma única vez.\n\nVocê também pode tocar em qualquer peça já inserida (ou antes da primeira) para mover o cursor e acrescentar parênteses, módulo ou operadores em qualquer posição da equação.\n\nQuando terminar, toque em Verificar. Os operadores disponíveis variam conforme a dificuldade. Para módulo, use | antes e depois da expressão; para piso e teto, use ⌊…⌋ e ⌈…⌉.';

  @override
  String get useAllFourNumbers =>
      'Use os quatro números antes de verificar a equação.';

  @override
  String get fillBothSides => 'Preencha os dois lados da equação.';

  @override
  String equationMismatch(String left, String right) {
    return 'A igualdade não confere: $left ≠ $right.';
  }

  @override
  String get equationCorrect => 'Correto! Você encontrou uma igualdade válida.';

  @override
  String get outOfRange =>
      'A expressão produz um valor fora do intervalo permitido.';

  @override
  String operatorNotAllowed(String operator, String difficulty) {
    return 'O operador “$operator” não está disponível no nível $difficulty.';
  }

  @override
  String get useProvidedNumbersOnly =>
      'Use apenas os números fornecidos pelo desafio.';

  @override
  String get useEachNumberOnce =>
      'Você precisa usar cada um dos quatro números exatamente uma vez.';

  @override
  String get noExtraNumbers =>
      'Use cada número fornecido exatamente uma vez, sem acrescentar outros números.';

  @override
  String unrecognizedChar(String char) {
    return 'Caractere não reconhecido: “$char”.';
  }

  @override
  String get enterMathExpression => 'Digite uma expressão matemática.';

  @override
  String get negativeSqrt =>
      'Não é possível calcular a raiz quadrada real de um número negativo.';

  @override
  String get invalidFactorial =>
      'O fatorial só pode ser aplicado a inteiros não negativos.';

  @override
  String get factorialTooLarge =>
      'O resultado do fatorial é grande demais para este jogo.';

  @override
  String get divisionByZero => 'Não é permitido dividir por zero.';

  @override
  String integerDivisionOnly(String difficulty) {
    return 'No nível $difficulty, toda divisão deve ter resultado inteiro.';
  }

  @override
  String get notFiniteResult => 'A operação não produz um número real finito.';

  @override
  String unexpectedToken(String token) {
    return 'Token inesperado: “$token”.';
  }

  @override
  String get incompleteExpression =>
      'A expressão terminou antes de ser concluída.';

  @override
  String expectedNumberOrParen(String token) {
    return 'Era esperado um número ou “(”, mas foi encontrado “$token”.';
  }

  @override
  String expectedToken(String expected) {
    return 'Era esperado “$expected”.';
  }

  @override
  String get signOut => 'Sair da conta';

  @override
  String get solvedSolutions => 'Soluções Resolvidas';

  @override
  String get noSolutionsYet => 'Você ainda não resolveu nenhum desafio.';

  @override
  String get completePuzzlePrompt =>
      'Complete uma equação no jogo para registrá-la aqui!';

  @override
  String numbersLabel(String numbers) {
    return 'Números: $numbers';
  }

  @override
  String solvedAtLabel(String date) {
    return 'Resolvido em $date';
  }

  @override
  String get saveSolutionError =>
      'Não foi possível salvar sua pontuação na nuvem. Verifique sua conexão.';
}
