import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/brand_mark.dart';

/// Um só `AnimationController`; cada parte usa um `Interval` da linha do tempo.
class IntroAnimation extends StatefulWidget {
  const new({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<IntroAnimation> createState() => _IntroAnimationState();
}

class _IntroAnimationState extends State<IntroAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.intro,
  );

  Animation<double> _segment(
    double begin,
    double end, [
    Curve curve = AppCurves.easeOut,
  ]) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: curve),
  );

  late final Animation<double> _icon = _segment(0, 0.36);
  late final Animation<double> _line1 = _segment(0.14, 0.48);
  late final Animation<double> _line2 = _segment(0.24, 0.58);
  late final Animation<double> _line3 = _segment(0.34, 0.68);
  late final Animation<double> _dot = _segment(
    0.58,
    0.80,
    AppCurves.softBounce,
  );
  late final Animation<double> _word = _segment(0.46, 0.86);

  @override
  void initState() {
    super.initState();
    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final iconScale = reduced ? 1.0 : 0.72 + 0.28 * _icon.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _icon.value,
              child: Transform.scale(
                scale: iconScale,
                child: BrandMark(
                  size: 112,
                  lineProgress: reduced
                      ? const [1, 1, 1]
                      : [_line1.value, _line2.value, _line3.value],
                  dotScale: reduced ? 1 : 0.4 + 0.6 * _dot.value,
                ),
              ),
            ),
            const SizedBox(height: 26),
            Opacity(
              opacity: _word.value,
              child: Transform.translate(
                offset: Offset(0, reduced ? 0 : 10 * (1 - _word.value)),
                child: Column(
                  children: [
                    Text(
                      'Wallet Ledger',
                      style: AppText.display.copyWith(
                        fontSize: 26,
                        color: AppColors.ground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cada centavo no lugar',
                      style: AppText.caption.copyWith(
                        color: const Color(0xFF8E9894),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
