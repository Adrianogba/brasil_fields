/// Valida e converte boletos bancários (cobrança): linha digitável de 47
/// dígitos e código de barras de 44.
///
/// Boletos de arrecadação (contas de consumo e tributos, que começam com 8)
/// não são cobertos.
class BoletoValidator {
  static const stripRegex = r'[^\d]';

  // Pesos 2 e 1 alternados da direita para a esquerda, somando os algarismos
  // de cada produto.
  static int _modulo10(String numero) {
    var soma = 0;
    var peso = 2;

    for (var i = numero.length - 1; i >= 0; i--) {
      final produto = int.parse(numero[i]) * peso;
      soma += produto ~/ 10 + produto % 10;
      peso = peso == 2 ? 1 : 2;
    }

    final digito = 10 - soma % 10;
    return digito == 10 ? 0 : digito;
  }

  // DV geral do código de barras: módulo 11 com pesos de 2 a 9. Pela regra do
  // BACEN ele nunca é 0; quando daria 0, 10 ou 11, vira 1.
  static int _digitoGeral(String codigoSemDigito) {
    var soma = 0;
    var peso = 2;

    for (var i = codigoSemDigito.length - 1; i >= 0; i--) {
      soma += int.parse(codigoSemDigito[i]) * peso;
      peso = peso == 9 ? 2 : peso + 1;
    }

    final digito = 11 - soma % 11;
    return digito >= 10 ? 1 : digito;
  }

  /// Remove caracteres não numéricos.
  static String strip(String? codigo) {
    final regExp = RegExp(stripRegex);
    codigo = codigo ?? '';

    return codigo.replaceAll(regExp, '');
  }

  /// Retorna `true` se [codigo] for um código de barras de boleto bancário
  /// com dígito verificador válido.
  static bool isCodigoBarrasValido(
    String? codigo, {
    bool stripBeforeValidation = true,
  }) {
    if (stripBeforeValidation) {
      codigo = strip(codigo);
    }

    if (codigo == null || !RegExp(r'^\d{44}$').hasMatch(codigo)) {
      return false;
    }

    if (codigo.startsWith('8')) {
      return false;
    }

    final semDigito = codigo.substring(0, 4) + codigo.substring(5);
    return _digitoGeral(semDigito).toString() == codigo[4];
  }

  /// Retorna `true` se [linha] for uma linha digitável de boleto bancário com
  /// os três dígitos dos campos e o dígito geral válidos.
  static bool isLinhaDigitavelValida(
    String? linha, {
    bool stripBeforeValidation = true,
  }) {
    if (stripBeforeValidation) {
      linha = strip(linha);
    }

    if (linha == null || !RegExp(r'^\d{47}$').hasMatch(linha)) {
      return false;
    }

    final camposConferem =
        _modulo10(linha.substring(0, 9)).toString() == linha[9] &&
            _modulo10(linha.substring(10, 20)).toString() == linha[20] &&
            _modulo10(linha.substring(21, 31)).toString() == linha[31];

    return camposConferem &&
        isCodigoBarrasValido(_paraCodigoBarras(linha),
            stripBeforeValidation: false);
  }

  /// Retorna `true` se [codigo] for uma linha digitável (47 dígitos) ou um
  /// código de barras (44 dígitos) válido.
  static bool isValid(String? codigo) {
    final digitos = strip(codigo);

    return digitos.length == 47
        ? isLinhaDigitavelValida(digitos)
        : isCodigoBarrasValido(digitos);
  }

  static String _paraCodigoBarras(String linha) =>
      linha.substring(0, 4) +
      linha[32] +
      linha.substring(33, 47) +
      linha.substring(4, 9) +
      linha.substring(10, 20) +
      linha.substring(21, 31);

  /// Converte uma linha digitável válida no código de barras.
  ///
  /// Lança [ArgumentError] se a linha for inválida.
  static String paraCodigoBarras(String linha) {
    if (!isLinhaDigitavelValida(linha)) {
      throw ArgumentError.value(linha, 'linha', 'Linha digitável inválida!');
    }
    return _paraCodigoBarras(strip(linha));
  }

  /// Converte um código de barras válido na linha digitável, sem máscara.
  ///
  /// Lança [ArgumentError] se o código for inválido.
  static String paraLinhaDigitavel(String codigo) {
    if (!isCodigoBarrasValido(codigo)) {
      throw ArgumentError.value(codigo, 'codigo', 'Código de barras inválido!');
    }

    final digitos = strip(codigo);
    final livre = digitos.substring(19);
    final campo1 = digitos.substring(0, 4) + livre.substring(0, 5);
    final campo2 = livre.substring(5, 15);
    final campo3 = livre.substring(15, 25);

    return '$campo1${_modulo10(campo1)}'
        '$campo2${_modulo10(campo2)}'
        '$campo3${_modulo10(campo3)}'
        '${digitos[4]}${digitos.substring(5, 19)}';
  }

  /// Formata a linha digitável como
  /// `00000.00000 00000.000000 00000.000000 0 00000000000000`.
  ///
  /// Valores com outro tamanho voltam só sem os separadores.
  static String format(String linha) {
    final d = strip(linha);
    if (d.length != 47) {
      return d;
    }

    return '${d.substring(0, 5)}.${d.substring(5, 10)} '
        '${d.substring(10, 15)}.${d.substring(15, 21)} '
        '${d.substring(21, 26)}.${d.substring(26, 32)} '
        '${d[32]} ${d.substring(33)}';
  }
}
