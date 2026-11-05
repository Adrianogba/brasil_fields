import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'formatter_test_harness.dart';

void main() {
  final formatters = numericFormatterChain(RenavamInputFormatter());
  TextEditingValue evaluate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      applyFormatterChain(formatters, oldValue, newValue);

  group('RenavamInputFormatter', () {
    test('formata os 11 dígitos', () {
      final actual = evaluate(
        textEditingValue(''),
        textEditingValue('47556567702'),
      );

      expect(actual.text, '4755656770-2');
      expectCollapsedSelectionAtEnd(actual);
      expect(actual.composing, TextRange.empty);
    });

    test('só coloca o hífen no último dígito', () {
      var state = textEditingValue('');
      const raw = '47556567702';

      for (var length = 1; length < raw.length; length++) {
        state = evaluate(state, textEditingValue(raw.substring(0, length)));
        expect(state.text, raw.substring(0, length));
        expectCollapsedSelectionAtEnd(state);
      }

      state = evaluate(state, textEditingValue(raw));
      expect(state.text, '4755656770-2');
      expectCollapsedSelectionAtEnd(state);
    });

    test('backspace tira o hífen junto com o último dígito', () {
      final actual = evaluate(
        textEditingValue('4755656770-2'),
        textEditingValue('4755656770'),
      );

      expect(actual.text, '4755656770');
      expectCollapsedSelectionAtEnd(actual);
    });

    test('edição no meio mantém o cursor', () {
      final actual = evaluate(
        textEditingValue('4755656770-2'),
        textEditingValue(
          '47956567702',
          selection: const TextSelection.collapsed(offset: 3),
        ),
      );

      expect(actual.text, '4795656770-2');
      expect(actual.selection, const TextSelection.collapsed(offset: 3));
    });

    test('limite de 11 dígitos preserva valor e seleção anteriores', () {
      final oldValue = textEditingValue(
        '4755656770-2',
        selection: const TextSelection(baseOffset: 2, extentOffset: 6),
      );

      expect(evaluate(oldValue, textEditingValue('475565677022')), oldValue);
    });

    test('composição ativa permanece inalterada', () {
      final value = textEditingValue(
        '4755',
        composing: const TextRange(start: 0, end: 4),
      );

      expectActiveComposingIsUnchanged(
        formatters,
        textEditingValue('475'),
        value,
      );
    });
  });
}
