import 'package:flutter/services.dart';

/// Formata a chave de acesso em 11 grupos de 4 dígitos, como no DANFE.
class ChaveNFeInputFormatter extends TextInputFormatter {
  /// Número máximo de dígitos aceitos pelo formatador.
  int get maxLength => 44;

  static const int _tamanhoDoGrupo = 4;

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
      if (i > 0 && i % _tamanhoDoGrupo == 0) {
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
