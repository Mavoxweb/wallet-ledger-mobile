import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('a barra tem 5 destinos com nomes para leitor de tela', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, repository: authRepository());
    await finishIntro(tester);

    for (final label in [
      'Início',
      'Extrato',
      'Pix, enviar dinheiro',
      'Cobrar',
      'Perfil',
    ]) {
      expect(
        find.bySemanticsLabel(RegExp('^$label')),
        findsOneWidget,
        reason: label,
      );
    }
    semantics.dispose();
  });

  testWidgets('o botão central abre o Pix', (tester) async {
    await pumpApp(tester, repository: authRepository());
    await finishIntro(tester);

    await tester.tap(find.byKey(GlassNavBar.pixButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Para quem você quer enviar?'), findsOneWidget);
  });

  testWidgets('trocar de aba mostra a tela certa', (tester) async {
    await pumpApp(tester, repository: authRepository());
    await finishIntro(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Seus dados e preferências.'), findsOneWidget);
  });

  testWidgets('com movimento reduzido, a troca de aba não desliza', (
    tester,
  ) async {
    await pumpApp(tester, repository: authRepository(), reduceMotion: true);
    await finishIntro(tester);

    await tester.tap(find.text('Extrato'));
    await tester.pump();

    final slides = tester.widgetList<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slides, isNotEmpty);
    expect(slides.every((s) => s.offset == Offset.zero), isTrue);
  });

  testWidgets('a barra cabe com texto em 200%', (tester) async {
    await pumpApp(tester, repository: authRepository(), textScale: 2);
    await finishIntro(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(GlassNavBar), findsOneWidget);
  });
}
