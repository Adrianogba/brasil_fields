/// Valida placas de veículo nos padrões antigo (`AAA9999`) e Mercosul
/// (`AAA9A99`).
///
/// Placa não tem dígito verificador, então a validação é só de formato.
class PlacaVeiculoValidator {
  static final RegExp _antiga = RegExp(r'^[A-Z]{3}\d{4}$');
  static final RegExp _mercosul = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$');

  /// Remove hífen e espaços e converte para maiúsculas.
  static String strip(String? placa) =>
      (placa ?? '').replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

  /// Retorna `true` se [placa] estiver no padrão antigo ou no Mercosul.
  ///
  /// Remove hífen e espaços e ignora maiúsculas/minúsculas quando
  /// [stripBeforeValidation] é `true`.
  static bool isValid(String? placa, {bool stripBeforeValidation = true}) {
    final valor = stripBeforeValidation ? strip(placa) : (placa ?? '');

    return _antiga.hasMatch(valor) || _mercosul.hasMatch(valor);
  }

  /// Retorna `true` se [placa] estiver no padrão Mercosul.
  static bool isMercosul(String? placa) => _mercosul.hasMatch(strip(placa));
}
