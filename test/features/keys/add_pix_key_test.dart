import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/add_pix_key.dart';

import '../../helpers/fakes.dart';

void main() {
  test('abaixo do limite, cadastra pela API', () async {
    final repository = FakeKeysRepository();

    final key = await AddPixKey(repository)(
      PixKeyKind.email,
      'bruno@walletledger.dev',
      currentCount: 4,
    );

    expect(key.kind, PixKeyKind.email);
    expect(repository.created, [(PixKeyKind.email, 'bruno@walletledger.dev')]);
  });

  test('no limite, recusa como a API recusaria e nem chama a API', () async {
    final repository = FakeKeysRepository();

    await expectLater(
      AddPixKey(repository)(PixKeyKind.evp, null, currentCount: 5),
      throwsA(AddPixKey.limitFailure),
    );
    expect(repository.created, isEmpty);
  });
}
