/// Valida e formata a chave de acesso de 44 dígitos.
///
/// Usada por NF-e, NFC-e, CT-e e MDF-e, que se distinguem pelo modelo gravado
/// na chave.
class ChaveNFeValidator {
  static const stripRegex = r'[^\d]';

  /// Quantidade de dígitos da chave de acesso.
  static const int length = 44;

  // Módulo 11 com pesos de 2 a 9, da direita para a esquerda.
  static int _verifierDigit(String base) {
    var soma = 0;
    var peso = 2;

    for (var i = base.length - 1; i >= 0; i--) {
      soma += int.parse(base[i], radix: 10) * peso;
      peso = peso == 9 ? 2 : peso + 1;
    }

    final resto = soma % 11;

    return resto < 2 ? 0 : 11 - resto;
  }

  static bool _todosOsDigitosIguais(String chave) =>
      chave.split('').every((digito) => digito == chave[0]);

  /// Formata a chave em 11 grupos de 4 dígitos, como no DANFE.
  static String format(String chave) {
    final digitos = strip(chave);
    if (digitos.length != length) {
      return digitos;
    }

    final grupos = <String>[];
    for (var i = 0; i < length; i += 4) {
      grupos.add(digitos.substring(i, i + 4));
    }

    return grupos.join(' ');
  }

  /// Remove caracteres não numéricos da chave.
  static String strip(String? chave) {
    final regExp = RegExp(stripRegex);
    chave = chave ?? '';

    return chave.replaceAll(regExp, '');
  }

  /// Retorna `true` se [chave] tem 44 dígitos e dígito verificador válido.
  ///
  /// Remove caracteres não numéricos antes da validação quando
  /// [stripBeforeValidation] é `true`. Sequências de dígitos repetidos são
  /// recusadas: passam no módulo 11, mas não correspondem a documento nenhum.
  static bool isValid(String? chave, {bool stripBeforeValidation = true}) {
    if (stripBeforeValidation) {
      chave = strip(chave);
    }

    if (chave == null || chave.isEmpty) {
      return false;
    }

    if (chave.length != length) {
      return false;
    }

    if (!RegExp(r'^\d{44}$').hasMatch(chave)) {
      return false;
    }

    if (_todosOsDigitosIguais(chave)) {
      return false;
    }

    return _verifierDigit(chave.substring(0, 43)).toString() == chave[43];
  }
}
