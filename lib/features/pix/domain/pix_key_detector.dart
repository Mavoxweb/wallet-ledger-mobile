import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _evp = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final _phoneChars = RegExp(r'^\+?[\d\s().-]+$');

/// Só detecta o tipo pelo formato; quem normaliza é a API, para existir uma
/// regra só.
({PixKeyKind type, String value})? detectPixKey(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  if (_email.hasMatch(value)) return (type: PixKeyKind.email, value: value);
  if (_evp.hasMatch(value)) return (type: PixKeyKind.evp, value: value);

  if (_phoneChars.hasMatch(value)) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    // Mesma regra da API: DDD + 9 dígitos, ou 55 + DDD + 9 dígitos.
    final brazilian =
        (digits.length == 11 && !value.startsWith('+')) ||
        (digits.length == 13 && digits.startsWith('55'));
    if (brazilian) return (type: PixKeyKind.phone, value: value);
  }
  return null;
}
