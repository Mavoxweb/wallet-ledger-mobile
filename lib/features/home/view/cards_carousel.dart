import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// Carrossel de cartões com encaixe: o `PageView` para sempre num cartão
/// inteiro, e um arremesso rápido com o dedo leva ao próximo (impulso).
/// O cartão seguinte aparece pela metade, convidando a deslizar.
class CardsCarousel extends StatefulWidget {
  const new({required this.cards, super.key});

  final List<Widget> cards;

  @override
  State<CardsCarousel> createState() => _CardsCarouselState();
}

class _CardsCarouselState extends State<CardsCarousel> {
  final _controller = PageController(viewportFraction: 0.84);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.cards.length;
    return Column(
      children: [
        SizedBox(
          height: 224,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            // Sem recorte: senão a sombra dos cartões é cortada nas bordas do
            // PageView e aparece uma faixa retangular atrás deles.
            clipBehavior: Clip.none,
            itemCount: count,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                index == 0 ? AppSpacing.xl : AppSpacing.m / 2,
                4,
                index == count - 1 ? AppSpacing.xl : AppSpacing.m / 2,
                24,
              ),
              // Cartões têm altura fixa e números já grandes: o texto cresce
              // até 140%, o suficiente para quem amplia a fonte do sistema.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.4,
                child: widget.cards[index],
              ),
            ),
          ),
        ),
        if (count > 1)
          Semantics(
            label: 'Cartão ${_page + 1} de $count',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: AppMotion.tab,
                    curve: AppCurves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.ink
                          : const Color(0xFFC9CEC7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
