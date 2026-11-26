import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/features/charge/scan_page.dart';

import '../../helpers/fakes.dart';

void main() {
  test('QR Pix válido vira o preenchimento do Pix', () {
    final prefill = readPixQr(FakeChargeRepository.payload);

    expect(prefill?.pixKey, '123e4567-e12b-12d1-a456-426655440000');
    expect(prefill?.amountCents, isNull);
  });

  test('QR que não é Pix vira nulo (a câmera continua lendo)', () {
    expect(readPixQr('https://exemplo.com'), isNull);
  });
}
