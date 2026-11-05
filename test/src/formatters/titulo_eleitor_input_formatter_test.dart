import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'formatter_test_harness.dart';

void main() {
  final formatters = numericFormatterChain(TituloEleitorInputFormatter());
  TextEditingValue evaluate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      applyFormatterChain(formatters, oldValue, newValue);

  group('TituloEleitorInputFormatter', () {
    test('formata os 12 dígitos', () {
      final actual = evaluate(
        textEditingValue(''),
        textEditingValue('472054680167'),
      );

      expect(actual.text, '4720 5468 0167');
      expectCollapsedSelectionAtEnd(actual);
      expect(actual.composing, TextRange.empty);
    });

    test('digitação sequencial preserva o cursor no fim', () {
      var state = textEditingValue('');
      const raw = '472054680167';
      const expected = <String>[
        '4',
        '47',
        '472',
        '4720',
        '4720 5',
        '4720 54',
        '4720 546',
        '4720 5468',
        '4720 5468 0',
        '4720 5468 01',
        '4720 5468 016',
        '4720 5468 0167',
      ];

      for (var length = 1; length <= raw.length; length++) {
        state = evaluate(state, textEditingValue(raw.substring(0, length)));
        expect(state.text, expected[length - 1]);
        expectCollapsedSelectionAtEnd(state);
      }
    });

    test('backspace remove dígitos através dos separadores', () {
      var state = textEditingValue('4720 5468 0167');
      const cases = <String, String>{
        '47205468016': '4720 5468 016',
        '472054680': '4720 5468 0',
        '47205468': '4720 5468',
        '47205': '4720 5',
        '4720': '4720',
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
        textEditingValue('4720 5468 0167'),
        textEditingValue(
          '472094680167',
          selection: const TextSelection.collapsed(offset: 5),
        ),
      );

      expect(actual.text, '4720 9468 0167');
      expect(actual.selection, const TextSelection.collapsed(offset: 6));
    });

    test('limite de 12 dígitos preserva valor e seleção anteriores', () {
      final oldValue = textEditingValue(
        '4720 5468 0167',
        selection: const TextSelection(baseOffset: 5, extentOffset: 9),
      );

      expect(evaluate(oldValue, textEditingValue('4720546801670')), oldValue);
    });

    test('composição ativa permanece inalterada', () {
      final value = textEditingValue(
        '47205',
        composing: const TextRange(start: 0, end: 5),
      );

      expectActiveComposingIsUnchanged(
        formatters,
        textEditingValue('4720'),
        value,
      );
    });
  });
}
