import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/deterministic_random.dart';

void main() {
  test('Test título de eleitor validator', () {
    expect(TituloEleitorValidator.isValid('472054680167'), true);
    expect(TituloEleitorValidator.isValid('110104700264'), true);
    expect(TituloEleitorValidator.isValid('684140020302'), true);
    expect(TituloEleitorValidator.isValid('4720 5468 0167'), true);

    // Dígitos verificadores incorretos.
    expect(TituloEleitorValidator.isValid('472054680168'), false);
    expect(TituloEleitorValidator.isValid('472054680177'), false);

    // Tamanho inválido.
    expect(TituloEleitorValidator.isValid('47205468016'), false);
    expect(TituloEleitorValidator.isValid('4720546801670'), false);

    // Valores vazios ou nulos.
    expect(TituloEleitorValidator.isValid(null), false);
    expect(TituloEleitorValidator.isValid(''), false);

    // Validação sem remover a máscara.
    expect(
      TituloEleitorValidator.isValid(
        '4720 5468 0167',
        stripBeforeValidation: false,
      ),
      false,
    );
  });

  test('SP e MG seguem a mesma regra dos outros estados', () {
    // Resto 0 no primeiro dígito de um título de SP. A regra antiga dava 1
    // para SP e MG, mas ela não está na Resolução TSE nº 23.659/2021.
    expect(TituloEleitorValidator.isValid('471335770108'), isTrue);
    expect(TituloEleitorValidator.isValid('471335770118'), isFalse);
  });

  test('recusa código de UF fora da tabela do TSE', () {
    // UF 00 e 29 com os dígitos verificadores corretos.
    expect(TituloEleitorValidator.isValid('472054680060'), isFalse);
    expect(TituloEleitorValidator.isValid('472054682968'), isFalse);
  });

  test('nenhuma sequência repetida é aceita', () {
    for (var digit = 0; digit <= 9; digit++) {
      final repetido = digit.toString() * 12;
      expect(
        TituloEleitorValidator.isValid(repetido),
        isFalse,
        reason: repetido,
      );
    }
  });

  test('Test título de eleitor format e strip', () {
    expect(TituloEleitorValidator.format('472054680167'), '4720 5468 0167');
    expect(TituloEleitorValidator.format('4720 5468 0167'), '4720 5468 0167');
    expect(TituloEleitorValidator.strip('4720 5468 0167'), '472054680167');
    expect(TituloEleitorValidator.strip(null), '');
  });

  test('obterUf usa a tabela do TSE', () {
    expect(TituloEleitorValidator.obterUf('472054680167'), 'SP');
    expect(TituloEleitorValidator.obterUf('110104700264'), 'MG');
    expect(TituloEleitorValidator.obterUf('684140020302'), 'RJ');
    expect(TituloEleitorValidator.obterUf('280810762488'), 'AC');
    expect(TituloEleitorValidator.obterUf('602405082046'), 'DF');
    expect(TituloEleitorValidator.siglas, hasLength(28));
    expect(TituloEleitorValidator.siglas.last, 'ZZ');
    expect(
      () => TituloEleitorValidator.obterUf('472054680168'),
      throwsArgumentError,
    );
  });

  test('generate usa o Random injetado', () {
    final random = RecordingRandom(<int>[0, 1, 2, 3, 4, 5, 6, 7, 4]);
    final gerado = TituloEleitorValidator.generate(random: random);

    expect(gerado, '012345670590');
    expect(TituloEleitorValidator.isValid(gerado), isTrue);
    expect(TituloEleitorValidator.obterUf(gerado), 'BA');
    expect(random.requestedMaxValues, [...List.filled(8, 10), 28]);
  });

  test('generate com máscara', () {
    final gerado = TituloEleitorValidator.generate(
      useFormat: true,
      random: RecordingRandom(<int>[0, 1, 2, 3, 4, 5, 6, 7, 4]),
    );

    expect(gerado, '0123 4567 0590');
  });
}
