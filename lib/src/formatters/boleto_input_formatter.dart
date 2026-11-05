import 'package:flutter/services.dart';

/// Formata a linha digitável do boleto bancário como
/// `00000.00000 00000.000000 00000.000000 0 00000000000000`.
class BoletoInputFormatter extends TextInputFormatter {
  /// Número máximo de dígitos aceitos pelo formatador.
  int get maxLength => 47;

  static const Map<int, String> _separadores = {
    5: '.',
    10: ' ',
    15: '.',
    21: ' ',
    26: '.',
    32: ' ',
    33: ' ',
  };

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
      final separador = _separadores[i];
      if (separador != null) {
        valorFinal.write(separador);
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
