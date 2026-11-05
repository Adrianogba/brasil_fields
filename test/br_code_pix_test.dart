import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Exemplos do Manual de Padrões para Iniciação do Pix (BCB).
  const estatico = '00020126580014br.gov.bcb.pix'
      '0136123e4567-e12b-12d1-a456-426655440000'
      '5204000053039865802BR5913Fulano de Tal6008BRASILIA'
      '62070503***63041D3D';
  const dinamico = '00020101021226700014br.gov.bcb.pix'
      '2548pix.example.com/8b3da2f39a4140d1a91abd93113bd441'
      '5204000053039865802BR5913Fulano de Tal6008BRASILIA'
      '62070503***630464E4';

  test('valida os exemplos do manual do Pix', () {
    expect(BrCodePixValidator.isValid(estatico), isTrue);
    expect(BrCodePixValidator.isValid(dinamico), isTrue);
  });

  test('aceita o CRC em minúsculas', () {
    expect(
      BrCodePixValidator.isValid(
        '${estatico.substring(0, estatico.length - 4)}1d3d',
      ),
      isTrue,
    );
  });

  test('recusa CRC errado', () {
    expect(
      BrCodePixValidator.isValid(
        '${estatico.substring(0, estatico.length - 4)}1D3E',
      ),
      isFalse,
    );
  });

  test('qualquer alteração no conteúdo quebra o CRC', () {
    final alterado = estatico.replaceFirst('Fulano de Tal', 'Fulano de Tai');

    expect(BrCodePixValidator.isValid(alterado), isFalse);
  });

  test('recusa payload sem o GUI do Pix', () {
    // Mesma estrutura, outro arranjo de pagamento, com CRC recalculado.
    const outroArranjo = '00020126580014br.gov.bcb.xyz'
        '0136123e4567-e12b-12d1-a456-426655440000'
        '5204000053039865802BR5913Fulano de Tal6008BRASILIA'
        '62070503***6304';

    expect(BrCodePixValidator.isValid('${outroArranjo}1573'), isFalse);
  });

  test('recusa estrutura quebrada, vazios e nulos', () {
    expect(BrCodePixValidator.isValid(null), isFalse);
    expect(BrCodePixValidator.isValid(''), isFalse);
    expect(BrCodePixValidator.isValid('6304ABCD'), isFalse);
    expect(BrCodePixValidator.isValid(estatico.substring(10)), isFalse);
    expect(BrCodePixValidator.isValid('qualquer texto'), isFalse);
  });
}
