import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';

/// Qualquer coisa tocável que "afunda" levemente no toque.
///
/// A escala reage no *toque para baixo* (`onTapDown`), não quando o dedo sai:
/// esperar o fim do toque faz a interface parecer surda.
class Pressable extends StatefulWidget {
  const new({
    required this.child,
    required this.onTap,
    super.key,
    this.pressedScale = 0.98,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1,
          duration: AppMotion.press,
          curve: AppCurves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
