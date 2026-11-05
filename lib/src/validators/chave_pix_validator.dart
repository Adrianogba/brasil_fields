import 'cnpj_alfanumerico_validator.dart';
import 'cpf_validator.dart';

/// Tipos de chave aceitos pelo Pix.
enum TipoChavePix { cpf, cnpj, email, telefone, aleatoria }

/// Valida chaves Pix nos cinco tipos aceitos pelo DICT.
///
/// A chave é validada como foi cadastrada, sem máscara: CPF e CNPJ só com
/// dígitos e celular no padrão internacional (`+5561912345678`), como no
/// Manual de Padrões para Iniciação do Pix.
class ChavePixValidator {
  /// Tamanho máximo de uma chave, conforme a API Pix do Banco Central.
  static const int maxLength = 77;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _telefone = RegExp(r'^\+55\d{2}9\d{8}$');
  static final RegExp _aleatoria = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
    r'-[0-9a-fA-F]{12}$',
  );
  static final RegExp _somenteDigitos = RegExp(r'^\d+$');
  static final RegExp _cnpjAlfanumerico = RegExp(r'^[0-9A-Z]{14}$');

  /// Retorna o tipo de [chave], ou `null` quando não for uma chave válida.
  ///
  /// CPF e CNPJ têm os dígitos verificadores conferidos.
  static TipoChavePix? obterTipo(String? chave) {
    if (chave == null || chave.isEmpty || chave.length > maxLength) {
      return null;
    }

    if (_aleatoria.hasMatch(chave)) {
      return TipoChavePix.aleatoria;
    }

    if (chave.contains('@')) {
      return _email.hasMatch(chave) ? TipoChavePix.email : null;
    }

    if (chave.startsWith('+')) {
      return _telefone.hasMatch(chave) ? TipoChavePix.telefone : null;
    }

    if (_somenteDigitos.hasMatch(chave)) {
      if (chave.length == 11) {
        return CPFValidator.isValid(chave, stripBeforeValidation: false)
            ? TipoChavePix.cpf
            : null;
      }
      if (chave.length == 14) {
        return CnpjAlfanumericoValidator.isValid(chave)
            ? TipoChavePix.cnpj
            : null;
      }
      return null;
    }

    if (_cnpjAlfanumerico.hasMatch(chave)) {
      return CnpjAlfanumericoValidator.isValid(chave)
          ? TipoChavePix.cnpj
          : null;
    }

    return null;
  }

  /// Retorna `true` se [chave] for uma chave Pix válida.
  static bool isValid(String? chave) => obterTipo(chave) != null;
}
