import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/deterministic_random.dart';

void main() {
  // Chaves reais de documentação pública: NF-e de SP e NFC-e do PR.
  const chaveNFe = '35150300822602000124550010009923461099234656';
  const chaveNFCe = '41170410422724000187650010000005101000010235';

  test('Test chave de acesso validator', () {
    expect(ChaveNFeValidator.isValid(chaveNFe), true);
    expect(ChaveNFeValidator.isValid(chaveNFCe), true);
    expect(
      ChaveNFeValidator.isValid(ChaveNFeValidator.format(chaveNFe)),
      true,
    );

    // Dígito verificador incorreto.
    expect(ChaveNFeValidator.isValid('${chaveNFe.substring(0, 43)}5'), false);

    // Tamanho inválido.
    expect(ChaveNFeValidator.isValid(chaveNFe.substring(0, 43)), false);
    expect(ChaveNFeValidator.isValid('${chaveNFe}0'), false);

    // Valores vazios ou nulos.
    expect(ChaveNFeValidator.isValid(null), false);
    expect(ChaveNFeValidator.isValid(''), false);

    // Validação sem remover os separadores.
    expect(
      ChaveNFeValidator.isValid(
        ChaveNFeValidator.format(chaveNFe),
        stripBeforeValidation: false,
      ),
      false,
    );
    expect(
      ChaveNFeValidator.isValid(chaveNFe, stripBeforeValidation: false),
      true,
    );
  });

  test('chave de acesso validator rejects repeated-digit sequences', () {
    for (var digit = 0; digit <= 9; digit++) {
      final repeated = digit.toString() * ChaveNFeValidator.length;

      expect(
        ChaveNFeValidator.isValid(repeated),
        isFalse,
        reason: repeated,
      );
    }

    // Zeros passam no módulo 11; só a regra de repetidos recusa.
    expect(
      chaveNFeWithIndependentCheckDigit('0' * 43),
      '0' * ChaveNFeValidator.length,
    );
  });

  test('chave de acesso validator rejects malformed values of exact length',
      () {
    final malformed = <String>[
      '${chaveNFe.substring(0, 43)}A',
      'A${chaveNFe.substring(1)}',
      '${chaveNFe.substring(0, 40)} 234',
    ];

    for (final chave in malformed) {
      expect(
        ChaveNFeValidator.isValid(chave, stripBeforeValidation: false),
        isFalse,
        reason: chave,
      );
    }
  });

  test('Test chave de acesso format', () {
    expect(
      ChaveNFeValidator.format(chaveNFe),
      '3515 0300 8226 0200 0124 5500 1000 9923 4610 9923 4656',
    );
    expect(
      ChaveNFeValidator.format(ChaveNFeValidator.format(chaveNFe)),
      ChaveNFeValidator.format(chaveNFe),
    );

    // Tamanho diferente volta só sem os separadores.
    expect(ChaveNFeValidator.format('3515 0300'), '35150300');
  });

  test('Test chave de acesso strip', () {
    expect(
        ChaveNFeValidator.strip(ChaveNFeValidator.format(chaveNFe)), chaveNFe);
    expect(ChaveNFeValidator.strip(null), '');
  });

  test('chave de acesso check digit matches an independent calculation', () {
    for (final chave in <String>[chaveNFe, chaveNFCe]) {
      expect(
        chaveNFeWithIndependentCheckDigit(chave.substring(0, 43)),
        chave,
      );
    }
  });

  test('every check digit of a base is accepted only once', () {
    final base = chaveNFe.substring(0, 43);
    final aceitos = <String>[];

    for (var digit = 0; digit <= 9; digit++) {
      final candidato = '$base$digit';
      if (ChaveNFeValidator.isValid(candidato)) {
        aceitos.add(candidato);
      }
    }

    expect(aceitos, <String>[chaveNFe]);
  });
}
