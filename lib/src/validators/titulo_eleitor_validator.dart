import 'dart:math';

/// Valida, formata e gera números de título de eleitor.
///
/// O número tem 12 dígitos: 8 sequenciais, 2 do código da UF e 2
/// verificadores, conforme o art. 36 da Resolução TSE nº 23.659/2021.
class TituloEleitorValidator {
  static const stripRegex = r'[^\d]';

  /// Siglas por código de UF, na ordem da tabela do TSE. `ZZ` é o exterior.
  static const List<String> siglas = [
    'SP', 'MG', 'RJ', 'RS', 'BA', 'PR', 'CE', 'PE', 'SC', 'GO', //
    'MA', 'PB', 'PA', 'ES', 'PI', 'RN', 'AL', 'MT', 'MS', 'DF', //
    'SE', 'AM', 'RO', 'AC', 'AP', 'RR', 'TO', 'ZZ',
  ];

  // Módulo 11; resto 10 vira 0.
  static int _digito(int soma) {
    final resto = soma % 11;
    return resto == 10 ? 0 : resto;
  }

  static String _comDigitos(String base) {
    var soma = 0;
    for (var i = 0; i < 8; i++) {
      soma += int.parse(base[i]) * (i + 2);
    }
    final primeiro = _digito(soma);
    final segundo = _digito(
      int.parse(base[8]) * 7 + int.parse(base[9]) * 8 + primeiro * 9,
    );

    return '$base$primeiro$segundo';
  }

  /// Formata o título como `XXXX XXXX XXXX`.
  static String format(String titulo) {
    final regExp = RegExp(r'^(\d{4})(\d{4})(\d{4})$');

    return strip(titulo)
        .replaceAllMapped(regExp, (Match m) => '${m[1]} ${m[2]} ${m[3]}');
  }

  /// Remove caracteres não numéricos do título.
  static String strip(String? titulo) {
    final regExp = RegExp(stripRegex);
    titulo = titulo ?? '';

    return titulo.replaceAll(regExp, '');
  }

  /// Retorna `true` se [titulo] tem formato, código de UF e dígitos
  /// verificadores válidos.
  ///
  /// Remove caracteres não numéricos antes da validação quando
  /// [stripBeforeValidation] é `true`.
  static bool isValid(String? titulo, {bool stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      titulo = strip(titulo);
    }

    if (titulo == null || !RegExp(r'^\d{12}$').hasMatch(titulo)) {
      return false;
    }

    final uf = int.parse(titulo.substring(8, 10));
    if (uf < 1 || uf > siglas.length) {
      return false;
    }

    return _comDigitos(titulo.substring(0, 10)) == titulo;
  }

  /// Retorna a sigla da UF de origem do título, ou `ZZ` para o exterior.
  ///
  /// Lança [ArgumentError] se o título for inválido.
  static String obterUf(String titulo) {
    if (!isValid(titulo)) {
      throw ArgumentError.value(
          titulo, 'titulo', 'Título de eleitor inválido!');
    }
    return siglas[int.parse(strip(titulo).substring(8, 10)) - 1];
  }

  /// Gera um título de eleitor válido, formatado quando [useFormat] é `true`.
  static String generate({bool useFormat = false, Random? random}) {
    final generator = random ?? Random();

    var sequencial = '';
    for (var i = 0; i < 8; i++) {
      sequencial += generator.nextInt(10).toString();
    }
    final uf =
        (generator.nextInt(siglas.length) + 1).toString().padLeft(2, '0');
    final titulo = _comDigitos('$sequencial$uf');

    return useFormat ? format(titulo) : titulo;
  }
}
