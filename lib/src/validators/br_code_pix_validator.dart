import 'dart:convert';

/// Valida e lê o BR Code do Pix, o texto do QR Code também usado no
/// "Pix Copia e Cola".
///
/// Segue o Manual de Padrões para Iniciação do Pix: campos no formato
/// ID-tamanho-valor e CRC16 (polinômio 0x1021, valor inicial 0xFFFF) no fim.
class BrCodePixValidator {
  static const String _gui = 'br.gov.bcb.pix';

  static String _crc16(String dados) {
    var crc = 0xFFFF;

    for (final byte in utf8.encode(dados)) {
      crc ^= byte << 8;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
        crc &= 0xFFFF;
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  // Lê uma sequência ID-tamanho-valor. Retorna null se a estrutura não fechar.
  static Map<String, String>? _campos(String dados) {
    final campos = <String, String>{};
    var i = 0;

    while (i < dados.length) {
      if (i + 4 > dados.length) return null;

      final id = dados.substring(i, i + 2);
      final tamanho = int.tryParse(dados.substring(i + 2, i + 4));
      if (tamanho == null || i + 4 + tamanho > dados.length) return null;

      campos[id] = dados.substring(i + 4, i + 4 + tamanho);
      i += 4 + tamanho;
    }

    return campos;
  }

  // Conta do Pix: o primeiro campo entre 26 e 51 com o GUI do Pix.
  static Map<String, String>? _contaPix(Map<String, String> campos) {
    for (var id = 26; id <= 51; id++) {
      final valor = campos[id.toString()];
      if (valor == null) continue;

      final conta = _campos(valor);
      if (conta != null && conta['00']?.toLowerCase() == _gui) return conta;
    }
    return null;
  }

  static Map<String, String>? _camposValidados(String? brCode) {
    if (brCode == null || brCode.length < 8) return null;

    // O CRC cobre tudo até o "6304" inclusive.
    final semCrc = brCode.substring(0, brCode.length - 4);
    if (!semCrc.endsWith('6304')) return null;
    if (_crc16(semCrc) != brCode.substring(brCode.length - 4).toUpperCase()) {
      return null;
    }

    final campos = _campos(brCode);
    if (campos == null || !brCode.startsWith('000201')) return null;
    if (_contaPix(campos) == null) return null;

    return campos;
  }

  /// Retorna `true` se [brCode] tem estrutura, CRC e identificador do Pix
  /// válidos.
  static bool isValid(String? brCode) => _camposValidados(brCode) != null;
}
