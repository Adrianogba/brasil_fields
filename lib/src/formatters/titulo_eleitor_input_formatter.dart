import 'package:flutter/services.dart';

/// Formata o título de eleitor como `XXXX XXXX XXXX`.
class TituloEleitorInputFormatter extends TextInputFormatter {
  /// Número máximo de dígitos aceitos pelo formatador.
  int get maxLength => 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

    if (newValue.text.length > maxLength) return oldValue;

    var posicaoCursor = newValue.selection.end;
    final valorFinal = StringBuffer();

    for (var i = 0; i < newValue.text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        valorFinal.write(' ');
        if (newValue.selection.end >= i) posicaoCursor++;
      }
      valorFinal.write(newValue.text[i]);
    }

    return TextEditingValue(
      text: valorFinal.toString(),
      selection: TextSelection.collapsed(offset: posicaoCursor),
    );
  }
}
