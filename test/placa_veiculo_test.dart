import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aceita os padrões antigo e Mercosul', () {
    expect(PlacaVeiculoValidator.isValid('ABC1234'), isTrue);
    expect(PlacaVeiculoValidator.isValid('ABC-1234'), isTrue);
    expect(PlacaVeiculoValidator.isValid('ABC1D23'), isTrue);
    expect(PlacaVeiculoValidator.isValid('abc1d23'), isTrue);
    expect(PlacaVeiculoValidator.isValid('ABC 1D23'), isTrue);
  });

  test('recusa formatos inválidos', () {
    expect(PlacaVeiculoValidator.isValid('AB12345'), isFalse);
    expect(PlacaVeiculoValidator.isValid('ABCD123'), isFalse);
    expect(PlacaVeiculoValidator.isValid('ABC12D3'), isFalse);
    expect(PlacaVeiculoValidator.isValid('ABC123'), isFalse);
    expect(PlacaVeiculoValidator.isValid('ABC12345'), isFalse);
    expect(PlacaVeiculoValidator.isValid('1BC1234'), isFalse);
    expect(PlacaVeiculoValidator.isValid(null), isFalse);
    expect(PlacaVeiculoValidator.isValid(''), isFalse);
  });

  test('sem normalizar, exige maiúsculas e nada de hífen', () {
    expect(
      PlacaVeiculoValidator.isValid('ABC1234', stripBeforeValidation: false),
      isTrue,
    );
    expect(
      PlacaVeiculoValidator.isValid('ABC-1234', stripBeforeValidation: false),
      isFalse,
    );
    expect(
      PlacaVeiculoValidator.isValid('abc1d23', stripBeforeValidation: false),
      isFalse,
    );
  });

  test('isMercosul distingue os padrões', () {
    expect(PlacaVeiculoValidator.isMercosul('ABC1D23'), isTrue);
    expect(PlacaVeiculoValidator.isMercosul('abc-1d23'), isTrue);
    expect(PlacaVeiculoValidator.isMercosul('ABC1234'), isFalse);
    expect(PlacaVeiculoValidator.isMercosul(null), isFalse);
  });

  test('strip', () {
    expect(PlacaVeiculoValidator.strip('abc-1234'), 'ABC1234');
    expect(PlacaVeiculoValidator.strip(' abc 1d23 '), 'ABC1D23');
    expect(PlacaVeiculoValidator.strip(null), '');
  });
}
