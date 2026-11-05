import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_test/flutter_test.dart';

import 'formatter_test_harness.dart';

void main() {
  const linha = '00190500954014481606906809350314337370000000100';
  const formatada = '00190.50095 40144.816069 06809.350314 3 37370000000100';

  final formatters = numericFormatterChain(BoletoInputFormatter());
  TextEditingValue evaluate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      applyFormatterChain(formatters, oldValue, newValue);

  group('BoletoInputFormatter', () {
    test('formata os 47 dígitos', () {
      final actual = evaluate(textEditingValue(''), textEditingValue(linha));

      expect(actual.text, formatada);
      expectCollapsedSelectionAtEnd(actual);
      expect(actual.composing, TextRange.empty);
      expect(actual.text, BoletoValidator.format(linha));
    });

    test('digitação sequencial preserva o cursor no fim', () {
      var state = textEditingValue('');

      for (var length = 1; length <= linha.length; length++) {
        state = evaluate(state, textEditingValue(linha.substring(0, length)));

        expect(
          state.text.replaceAll(RegExp(r'[^\d]'), ''),
          linha.substring(0, length),
        );
        expect(formatada.startsWith(state.text), isTrue, reason: state.text);
        expectCollapsedSelectionAtEnd(state);
      }
    });

    test('não deixa separador sobrando no fim', () {
      expect(evaluate(textEditingValue(''), textEditingValue('00190')).text,
          '00190');
      expect(
        evaluate(textEditingValue(''), textEditingValue('001905')).text,
        '00190.5',
      );
    });

    test('edição no meio remapeia o cursor após o separador', () {
      final actual = evaluate(
        textEditingValue('00190.5009'),
        textEditingValue(
          '001907009',
          selection: const TextSelection.collapsed(offset: 6),
        ),
      );

      expect(actual.text, '00190.7009');
      expect(actual.selection, const TextSelection.collapsed(offset: 7));
    });

    test('limite de 47 dígitos preserva valor e seleção anteriores', () {
      final oldValue = textEditingValue(
        formatada,
        selection: const TextSelection(baseOffset: 6, extentOffset: 11),
      );

      expect(evaluate(oldValue, textEditingValue('${linha}0')), oldValue);
    });

    test('composição ativa permanece inalterada', () {
      final value = textEditingValue(
        '001905',
        composing: const TextRange(start: 0, end: 6),
      );

      expectActiveComposingIsUnchanged(
        formatters,
        textEditingValue('00190'),
        value,
      );
    });
  });
}
