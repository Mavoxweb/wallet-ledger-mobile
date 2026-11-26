import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// O símbolo do Wallet Ledger: três linhas de um livro-razão, a última
/// terminando num ponto (o saldo conferido). As proporções seguem o ícone.
///
/// `lineProgress` (0 a 1 por linha) permite à animação de entrada "desenhar" as
/// linhas em sequência; parado, tudo aparece completo.
class BrandMark extends StatelessWidget {
  const new({
    super.key,
    this.size = 40,
    this.lineProgress = const [1, 1, 1],
    this.dotScale = 1,
  });

  final double size;
  final List<double> lineProgress;
  final double dotScale;

  @override
  Widget build(BuildContext context) {
    final line = size * 0.08;
    final gap = size * 0.10;
    final padding = size * 0.227;

    Widget bar(double widthFactor, double progress) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0, 1),
          child: Container(
            height: line,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(line / 2),
            ),
          ),
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(size * 0.225),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bar(1, lineProgress[0]),
          SizedBox(height: gap),
          bar(1, lineProgress[1]),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(flex: 307, child: bar(1, lineProgress[2])),
              SizedBox(width: size * 0.065),
              Transform.scale(
                scale: dotScale,
                child: Container(
                  width: line,
                  height: line,
                  decoration: const BoxDecoration(
                    color: AppColors.ground,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Spacer(flex: 245),
            ],
          ),
        ],
      ),
    );
  }
}
