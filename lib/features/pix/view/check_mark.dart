import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// Check do comprovante, desenhado: o círculo se fecha e o "✓" é traçado.
///
/// Animação rara (uma vez por Pix): aqui cabe um pouco de encanto. Com
/// movimento reduzido, aparece pronto.
class CheckMark extends StatefulWidget {
  const new({super.key, this.size = 88});

  final double size;

  @override
  State<CheckMark> createState() => _CheckMarkState();
}

class _CheckMarkState extends State<CheckMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pix enviado com sucesso',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _CheckPainter(
              AppCurves.easeOut.transform(_controller.value),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const new(this.progress);

  /// 0 → nada; 0,55 → círculo completo; 1 → check completo.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Fundo menta que cresce junto com o círculo.
    final fill = Paint()
      ..color = AppColors.accentSoft.withValues(
        alpha: (progress / 0.55).clamp(0, 1),
      );
    canvas.drawCircle(center, radius, fill);

    final stroke = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ring = (progress / 0.55).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke.strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * ring,
      false,
      stroke,
    );

    final tick = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
    if (tick == 0) return;
    final path = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.66)
      ..lineTo(size.width * 0.71, size.height * 0.38);
    // Só o trecho já "traçado" do caminho.
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * tick), stroke);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
