import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/deterministic_random.dart';

void main() {
  test('Test Renavam validator', () {
    expect(RenavamValidator.isValid('47556567702'), true);
    expect(RenavamValidator.isValid('63050646948'), true);
    expect(RenavamValidator.isValid('4755656770-2'), true);

    // Resto 10 vira 0.
    expect(RenavamValidator.isValid('17939188010'), true);
    expect(RenavamValidator.isValid('65984390400'), true);

    // Dígito verificador incorreto.
    expect(RenavamValidator.isValid('47556567703'), false);

    // Tamanho inválido.
    expect(RenavamValidator.isValid('4755656770'), false);
    expect(RenavamValidator.isValid('475565677022'), false);

    // Valores vazios ou nulos.
    expect(RenavamValidator.isValid(null), false);
    expect(RenavamValidator.isValid(''), false);

    // Validação sem remover a máscara.
    expect(
      RenavamValidator.isValid('4755656770-2', stripBeforeValidation: false),
      false,
    );
  });

  test('a lista de bloqueio é necessária para os zeros', () {
    // 00000000000 passa no cálculo; as outras sequências já falham nele.
    for (final repetido in RenavamValidator.blockList) {
      expect(RenavamValidator.isValid(repetido), isFalse, reason: repetido);
    }
  });

  test('Test Renavam format e strip', () {
    expect(RenavamValidator.format('47556567702'), '4755656770-2');
    expect(RenavamValidator.format('4755656770-2'), '4755656770-2');
    expect(RenavamValidator.strip('4755656770-2'), '47556567702');
    expect(RenavamValidator.strip(null), '');
  });

  test('generate usa o Random injetado', () {
    final random = RecordingRandom(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final gerado = RenavamValidator.generate(random: random);

    expect(gerado, '01234567897');
    expect(RenavamValidator.isValid(gerado), isTrue);
    expect(random.requestedMaxValues, List.filled(10, 10));
  });

  test('generate pula candidato da lista de bloqueio', () {
    final random = RecordingRandom(<int>[
      ...List<int>.filled(10, 0),
      9,
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
    ]);

    expect(RenavamValidator.generate(random: random), '90123456784');
  });

  test('generate com máscara', () {
    final gerado = RenavamValidator.generate(
      useFormat: true,
      random: RecordingRandom(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    );

    expect(gerado, '0123456789-7');
  });

  test('generate desiste depois de esgotar as tentativas', () {
    expect(
      () => RenavamValidator.generate(random: RecordingRandom.constant(0)),
      throwsStateError,
    );
  });
}
