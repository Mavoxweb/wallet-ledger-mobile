import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/ids/uuid.dart';

void main() {
  test('gera UUID v4 no formato certo e sem repetir', () {
    final format = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final ids = {for (var i = 0; i < 1000; i++) uuidV4()};

    expect(ids.length, 1000);
    expect(ids.every(format.hasMatch), isTrue);
  });
}
