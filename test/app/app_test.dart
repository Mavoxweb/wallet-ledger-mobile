import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/app/app.dart';

void main() {
  testWidgets('o app sobe com o título da marca', (tester) async {
    await tester.pumpWidget(const WalletLedgerApp());
    await tester.pumpAndSettle();

    expect(find.text('Wallet Ledger'), findsWidgets);
  });
}
