import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/features/home/presentation/view/home_page.dart';
import 'package:wallet_ledger_mobile/features/profile/presentation/profile_page.dart';

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

    expect(find.text('Chaves Pix'), findsOneWidget);
  });

  // A aba que sai precisa sumir de verdade. Antes, o TickerMode desligava a
  // animação de saída e a aba antiga ficava por cima, ainda opaca, ao voltar
  // para uma aba anterior (de Extrato para Início, por exemplo).
  testWidgets('voltar para o Início esconde a aba que estava aberta', (
    tester,
  ) async {
    await pumpApp(tester, repository: authRepository());
    await finishIntro(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();

    double opacityOf(Type page) => tester
        .widget<FadeTransition>(
          // O fade da aba: o primeiro logo abaixo do AnimatedOpacity dela.
          find
              .descendant(
                of: find.ancestor(
                  of: find.byType(page),
                  matching: find.byType(AnimatedOpacity),
                ),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    expect(opacityOf(ProfilePage), 0);
    expect(opacityOf(HomePage), 1);
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
