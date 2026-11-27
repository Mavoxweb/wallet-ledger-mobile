import 'dart:convert';

const _pixGui = 'br.gov.bcb.pix';

/// Lê o "Pix Copia e Cola" (BR Code, padrão EMV): a chave e o valor, se houver.
///
/// Porta para Dart do `BrCode.Parse` da API. Cada campo é TLV: ID (2 dígitos)
/// + tamanho (2 dígitos) + valor. O último campo (63) é um CRC16 que pega erro
/// de leitura ou adulteração. Lança [FormatException] se algo não bater.
({String pixKey, int? amountCents}) parseBrCode(String raw) {
  final payload = raw.trim();
  if (payload.length < 8 ||
      payload.substring(payload.length - 8, payload.length - 4) != '6304') {
    throw const FormatException('QR code Pix inválido');
  }

  final body = payload.substring(0, payload.length - 4);
  final crc = payload.substring(payload.length - 4).toUpperCase();
  if (crc16(body) != crc) {
    throw const FormatException('QR code Pix inválido: CRC não confere');
  }

  final fields = _readFields(payload.substring(0, payload.length - 8));
  final account = fields['26'];
  if (account == null) throw const FormatException('QR code sem conta Pix');

  final accountFields = _readFields(account);
  final key = accountFields['01'];
  if (accountFields['00']?.toLowerCase() != _pixGui || key == null) {
    throw const FormatException('QR code não é Pix');
  }

  final rawAmount = fields['54'];
  return (
    pixKey: key,
    amountCents: rawAmount == null ? null : _parseAmount(rawAmount),
  );
}

Map<String, String> _readFields(String data) {
  final fields = <String, String>{};
  var i = 0;
  while (i < data.length) {
    final length = i + 4 <= data.length
        ? int.tryParse(data.substring(i + 2, i + 4))
        : null;
    if (length == null || i + 4 + length > data.length) {
      throw const FormatException('QR code Pix mal formado');
    }
    fields[data.substring(i, i + 2)] = data.substring(i + 4, i + 4 + length);
    i += 4 + length;
  }
  return fields;
}

/// "10.50" → 1050, sem passar por `double`.
int _parseAmount(String value) {
  final parts = value.split('.');
  final reais = int.tryParse(parts[0]);
  final fraction = parts.length == 2 ? parts[1].padRight(2, '0') : '00';
  final centavos = int.tryParse(fraction);
  if (parts.length > 2 ||
      reais == null ||
      reais < 0 ||
      fraction.length != 2 ||
      centavos == null) {
    throw const FormatException('Valor do QR code inválido');
  }
  return reais * 100 + centavos;
}

/// CRC16-CCITT-FALSE: polinômio 0x1021, valor inicial 0xFFFF, hexadecimal
/// maiúsculo com 4 dígitos. Idêntico ao da API.
String crc16(String data) {
  var crc = 0xFFFF;
  for (final byte in utf8.encode(data)) {
    // Junta o byte nos 8 bits de cima do registrador.
    crc ^= byte << 8;
    for (var bit = 0; bit < 8; bit++) {
      // Se o bit mais alto é 1, desloca e aplica o polinômio; senão só
      // desloca. `& 0xFFFF` mantém 16 bits (em Dart o `int` tem 64).
      crc = (crc & 0x8000) != 0
          ? ((crc << 1) ^ 0x1021) & 0xFFFF
          : (crc << 1) & 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}
