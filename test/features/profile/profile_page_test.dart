import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('sair limpa a sessão e volta para o login', (tester) async {
    final repository = authRepository();
    await pumpApp(tester, repository: repository);
    await finishIntro(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Beatriz Lima'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    verify(repository.logout).called(1);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('mostra o aviso de demonstração e a versão', (tester) async {
    await pumpApp(tester, repository: authRepository());
    await finishIntro(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Projeto de demonstração'), findsOneWidget);
    expect(find.textContaining('versão 0.1.0'), findsOneWidget);
  });
}
