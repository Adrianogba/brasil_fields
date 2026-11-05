import 'package:flutter/services.dart';

/// Formata o Renavam como `XXXXXXXXXX-X`.
class RenavamInputFormatter extends TextInputFormatter {
  /// Número máximo de dígitos aceitos pelo formatador.
  int get maxLength => 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

    if (newValue.text.length > maxLength) return oldValue;

    if (newValue.text.length < maxLength) {
      return TextEditingValue(
        text: newValue.text,
        selection: newValue.selection,
      );
    }

    var posicaoCursor = newValue.selection.end;
    if (posicaoCursor >= 10) posicaoCursor++;

    return TextEditingValue(
      text: '${newValue.text.substring(0, 10)}-${newValue.text.substring(10)}',
      selection: TextSelection.collapsed(offset: posicaoCursor),
    );
  }
}
