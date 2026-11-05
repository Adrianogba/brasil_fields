import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'formatter_test_harness.dart';

void main() {
  const chave = '35150300822602000124550010009923461099234656';
  const chaveFormatada =
      '3515 0300 8226 0200 0124 5500 1000 9923 4610 9923 4656';

  final formatters = numericFormatterChain(ChaveNFeInputFormatter());
  TextEditingValue evaluate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      applyFormatterChain(formatters, oldValue, newValue);

  group('ChaveNFeInputFormatter', () {
    test('formata os 44 dígitos em grupos de 4', () {
      final actual = evaluate(textEditingValue(''), textEditingValue(chave));

      expect(actual.text, chaveFormatada);
      expectCollapsedSelectionAtEnd(actual);
      expect(actual.composing, TextRange.empty);
    });

    test('a cadeia numérica descarta caracteres não numéricos', () {
      final actual = evaluate(
        textEditingValue(''),
        textEditingValue('3515a0300'),
      );

      expect(actual.text, '3515 0300');
    });

    test('digitação sequencial preserva o cursor no fim', () {
      var state = textEditingValue('');

      for (var length = 1; length <= chave.length; length++) {
        state = evaluate(state, textEditingValue(chave.substring(0, length)));

        final digitos = state.text.replaceAll(' ', '');
        expect(digitos, chave.substring(0, length));
        expectCollapsedSelectionAtEnd(state);
      }

      expect(state.text, chaveFormatada);
    });

    test('não deixa separador sobrando no fim de um grupo', () {
      expect(evaluate(textEditingValue(''), textEditingValue('3515')).text,
          '3515');
      expect(
        evaluate(textEditingValue('3515'), textEditingValue('35150')).text,
        '3515 0',
      );
    });

    test('backspace remove dígitos através dos separadores', () {
      var state = textEditingValue(chaveFormatada);
      const cases = <String, String>{
        '3515030082260200012455001000992346109923465': '3515 0300 8226 0200 '
            '0124 5500 1000 9923 4610 9923 465',
        '35150300822602000124': '3515 0300 8226 0200 0124',
        '351503': '3515 03',
        '3515': '3515',
        '351': '351',
        '': '',
      };

      for (final entry in cases.entries) {
        state = evaluate(state, textEditingValue(entry.key));
        expect(state.text, entry.value);
        expectCollapsedSelectionAtEnd(state);
      }
    });

    test('edição no meio remapeia o cursor após o separador', () {
      final actual = evaluate(
        textEditingValue('3515 0300'),
        textEditingValue(
          '35150301',
          selection: const TextSelection.collapsed(offset: 8),
        ),
      );

      expect(actual.text, '3515 0301');
      expect(actual.selection, const TextSelection.collapsed(offset: 9));
    });

    test('limite de 44 dígitos preserva valor e seleção anteriores', () {
      final oldValue = textEditingValue(
        chaveFormatada,
        selection: const TextSelection(baseOffset: 5, extentOffset: 9),
      );

      expect(evaluate(oldValue, textEditingValue('${chave}0')), oldValue);
    });

    test('composição ativa permanece inalterada', () {
      final value = textEditingValue(
        '35150',
        composing: const TextRange(start: 0, end: 5),
      );

      expectActiveComposingIsUnchanged(
        formatters,
        textEditingValue('3515'),
        value,
      );
    });

    test('o resultado formatado é aceito pelo validator', () {
      final actual = evaluate(textEditingValue(''), textEditingValue(chave));

      expect(ChaveNFeValidator.isValid(actual.text), isTrue);
      expect(actual.text, ChaveNFeValidator.format(chave));
    });
  });
}
