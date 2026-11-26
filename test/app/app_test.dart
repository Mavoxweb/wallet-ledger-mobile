import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('sem sessão salva, o app abre no login', (tester) async {
    await pumpApp(tester, repository: authRepository(hasSession: false));
    await finishIntro(tester);

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Wallet Ledger'), findsOneWidget);
  });
}
