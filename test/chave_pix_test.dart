import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('identifica os cinco tipos de chave', () {
    expect(ChavePixValidator.obterTipo('33461671002'), TipoChavePix.cpf);
    expect(
      ChavePixValidator.obterTipo('12175094000119'),
      TipoChavePix.cnpj,
    );
    expect(
      ChavePixValidator.obterTipo('contato@exemplo.com.br'),
      TipoChavePix.email,
    );
    expect(
      ChavePixValidator.obterTipo('+5511999998877'),
      TipoChavePix.telefone,
    );
    expect(
      ChavePixValidator.obterTipo('7d9f0335-8dcc-4054-9bf9-0dbd61d36906'),
      TipoChavePix.aleatoria,
    );
  });

  test('aceita CNPJ alfanumérico', () {
    expect(ChavePixValidator.obterTipo('14890N2J709Y05'), TipoChavePix.cnpj);
  });

  test('confere os dígitos verificadores de CPF e CNPJ', () {
    expect(ChavePixValidator.isValid('33461671001'), isFalse);
    expect(ChavePixValidator.isValid('12175094000118'), isFalse);
    expect(ChavePixValidator.isValid('00000000000'), isFalse);
  });

  test('recusa CPF e CNPJ com máscara', () {
    expect(ChavePixValidator.isValid('334.616.710-02'), isFalse);
    expect(ChavePixValidator.isValid('12.175.094/0001-19'), isFalse);
  });

  test('telefone precisa ser celular com o código do país', () {
    expect(ChavePixValidator.isValid('+5511999998877'), isTrue);
    expect(ChavePixValidator.isValid('+5561912345678'), isTrue);

    // O manual do Pix só prevê celular.
    expect(ChavePixValidator.isValid('+551133334444'), isFalse);
    expect(ChavePixValidator.isValid('+5511899998877'), isFalse);

    expect(ChavePixValidator.isValid('11999998877'), isFalse);
    expect(ChavePixValidator.isValid('+5511'), isFalse);
    expect(ChavePixValidator.isValid('+551199999887766'), isFalse);
    expect(ChavePixValidator.isValid('+1511999998877'), isFalse);
  });

  test('e-mail precisa de domínio com ponto', () {
    expect(ChavePixValidator.isValid('a@b.co'), isTrue);
    expect(ChavePixValidator.isValid('contato@exemplo'), isFalse);
    expect(ChavePixValidator.isValid('contato exemplo@teste.com'), isFalse);
    expect(ChavePixValidator.isValid('@exemplo.com'), isFalse);
  });

  test('chave aleatória segue o formato de UUID', () {
    expect(
      ChavePixValidator.isValid('7D9F0335-8DCC-4054-9BF9-0DBD61D36906'),
      isTrue,
    );
    expect(
      ChavePixValidator.isValid('7d9f0335-8dcc-4054-9bf9-0dbd61d3690'),
      isFalse,
    );
    expect(
      ChavePixValidator.isValid('7d9f03358dcc40549bf90dbd61d36906'),
      isFalse,
    );
  });

  test('recusa valores vazios, nulos e acima do limite', () {
    expect(ChavePixValidator.isValid(null), isFalse);
    expect(ChavePixValidator.isValid(''), isFalse);
    expect(ChavePixValidator.obterTipo(null), isNull);

    final emailLongo = '${'a' * 70}@teste.com';
    expect(emailLongo.length, greaterThan(ChavePixValidator.maxLength));
    expect(ChavePixValidator.isValid(emailLongo), isFalse);
  });
}
