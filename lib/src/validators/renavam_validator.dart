import 'dart:math';

/// Valida, formata e gera números de Renavam.
///
/// O Renavam tem 11 dígitos, sendo o último o verificador.
class RenavamValidator {
  /// Sequências de dígitos repetidos são consideradas inválidas.
  static const List<String> blockList = [
    '00000000000',
    '11111111111',
    '22222222222',
    '33333333333',
    '44444444444',
    '55555555555',
    '66666666666',
    '77777777777',
    '88888888888',
    '99999999999',
  ];

  static const stripRegex = r'[^\d]';
  static const int _maxGenerationAttempts = 100;

  static const List<int> _pesos = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  // Soma ponderada vezes 10, módulo 11; resto 10 vira 0.
  static int _verifierDigit(String base) {
    var soma = 0;
    for (var i = 0; i < _pesos.length; i++) {
      soma += int.parse(base[i]) * _pesos[i];
    }

    final resto = (soma * 10) % 11;
    return resto == 10 ? 0 : resto;
  }

  /// Formata o Renavam como `XXXXXXXXXX-X`.
  static String format(String renavam) {
    final regExp = RegExp(r'^(\d{10})(\d)$');

    return strip(renavam)
        .replaceAllMapped(regExp, (Match m) => '${m[1]}-${m[2]}');
  }

  /// Remove caracteres não numéricos do Renavam.
  static String strip(String? renavam) {
    final regExp = RegExp(stripRegex);
    renavam = renavam ?? '';

    return renavam.replaceAll(regExp, '');
  }

  /// Retorna `true` se [renavam] tem 11 dígitos e dígito verificador válido.
  ///
  /// Remove caracteres não numéricos antes da validação quando
  /// [stripBeforeValidation] é `true`.
  static bool isValid(String? renavam, {bool stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      renavam = strip(renavam);
    }

    if (renavam == null || !RegExp(r'^\d{11}$').hasMatch(renavam)) {
      return false;
    }

    if (blockList.contains(renavam)) {
      return false;
    }

    return _verifierDigit(renavam).toString() == renavam[10];
  }

  /// Gera um Renavam válido, formatado quando [useFormat] é `true`.
  static String generate({bool useFormat = false, Random? random}) {
    final generator = random ?? Random();

    for (var attempt = 0; attempt < _maxGenerationAttempts; attempt++) {
      var base = '';
      for (var i = 0; i < 10; i++) {
        base += generator.nextInt(10).toString();
      }

      final renavam = '$base${_verifierDigit(base)}';
      if (!blockList.contains(renavam)) {
        return useFormat ? format(renavam) : renavam;
      }
    }

    throw StateError(
      'Não foi possível gerar um Renavam fora da lista de bloqueio após '
      '$_maxGenerationAttempts tentativas.',
    );
  }
}
