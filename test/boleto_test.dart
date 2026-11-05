import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Exemplo resolvido da especificação de boleto do Banco do Brasil
  // (Anexos V e VI): DVs dos campos 5, 9 e 4, DV geral 3.
  const codigoBarrasBB = '00193373700000001000500940144816060680935031';
  const linhaBB = '00190500954014481606906809350314337370000000100';
  const linhaBBFormatada =
      '00190.50095 40144.816069 06809.350314 3 37370000000100';

  test('valida o exemplo da especificação do Banco do Brasil', () {
    expect(BoletoValidator.isCodigoBarrasValido(codigoBarrasBB), isTrue);
    expect(BoletoValidator.isLinhaDigitavelValida(linhaBB), isTrue);
    expect(BoletoValidator.isLinhaDigitavelValida(linhaBBFormatada), isTrue);
    expect(BoletoValidator.isValid(codigoBarrasBB), isTrue);
    expect(BoletoValidator.isValid(linhaBBFormatada), isTrue);
  });

  test('converte nos dois sentidos', () {
    expect(BoletoValidator.paraLinhaDigitavel(codigoBarrasBB), linhaBB);
    expect(BoletoValidator.paraCodigoBarras(linhaBB), codigoBarrasBB);
    expect(BoletoValidator.paraCodigoBarras(linhaBBFormatada), codigoBarrasBB);
  });

  test('format', () {
    expect(BoletoValidator.format(linhaBB), linhaBBFormatada);
    expect(BoletoValidator.format(linhaBBFormatada), linhaBBFormatada);
    expect(BoletoValidator.format('00190.500'), '00190500');
  });

  test('DV geral vira 1 quando o cálculo daria 0, 10 ou 11', () {
    // Resto 0 e resto 1 na soma. Uma regra que devolve 0 nesses casos
    // recusaria os dois.
    const resto0 = '23791999900000001013381260000000000300000000';
    const resto1 = '23791999900000001053381260000000000300000000';

    expect(BoletoValidator.isCodigoBarrasValido(resto0), isTrue);
    expect(BoletoValidator.isCodigoBarrasValido(resto1), isTrue);
    expect(
      BoletoValidator.isCodigoBarrasValido(
        '${resto0.substring(0, 4)}0${resto0.substring(5)}',
      ),
      isFalse,
    );
    expect(
      BoletoValidator.isLinhaDigitavelValida(
        '23793381286000000000403000000004199990000000101',
      ),
      isTrue,
    );
  });

  test('o DV geral nunca é 0', () {
    for (var i = 0; i <= 9; i++) {
      final codigo =
          '${codigoBarrasBB.substring(0, 4)}0${codigoBarrasBB.substring(5, 43)}$i';
      expect(
        BoletoValidator.isCodigoBarrasValido(codigo),
        isFalse,
        reason: codigo,
      );
    }
  });

  test('recusa DV de campo errado na linha digitável', () {
    // Cada um dos três DVs de campo trocado.
    for (final posicao in <int>[9, 20, 31]) {
      final digito = (int.parse(linhaBB[posicao]) + 1) % 10;
      final linha = linhaBB.substring(0, posicao) +
          digito.toString() +
          linhaBB.substring(posicao + 1);

      expect(
        BoletoValidator.isLinhaDigitavelValida(linha),
        isFalse,
        reason: 'posição $posicao',
      );
    }
  });

  test('recusa linha com DVs de campo certos e DV geral errado', () {
    final linha = '${linhaBB.substring(0, 32)}4${linhaBB.substring(33)}';

    expect(BoletoValidator.isLinhaDigitavelValida(linha), isFalse);
  });

  test('recusa arrecadação, tamanhos errados e vazios', () {
    expect(
      BoletoValidator.isCodigoBarrasValido(
        '8${codigoBarrasBB.substring(1)}',
      ),
      isFalse,
    );
    expect(BoletoValidator.isValid(codigoBarrasBB.substring(1)), isFalse);
    expect(BoletoValidator.isValid('${linhaBB}0'), isFalse);
    expect(BoletoValidator.isValid(null), isFalse);
    expect(BoletoValidator.isValid(''), isFalse);
  });

  test('sem normalizar, recusa a linha formatada', () {
    expect(
      BoletoValidator.isLinhaDigitavelValida(
        linhaBBFormatada,
        stripBeforeValidation: false,
      ),
      isFalse,
    );
  });

  test('as conversões recusam valores inválidos', () {
    expect(
      () => BoletoValidator.paraLinhaDigitavel('${codigoBarrasBB}0'),
      throwsArgumentError,
    );
    expect(
      () => BoletoValidator.paraCodigoBarras(linhaBB.substring(1)),
      throwsArgumentError,
    );
  });
}
