import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/pressable.dart';

/// Um destino da barra.
class NavDestination {
  const new({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Barra inferior flutuante em vidro fosco, com o botão Pix saltado no centro.
///
/// As quatro abas ficam duas de cada lado; o Pix, função principal, ganha o
/// lugar de destaque. O conteúdo da tela passa por baixo da barra, desfocado.
class GlassNavBar extends StatelessWidget {
  const new({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    required this.onPix,
    super.key,
  }) : assert(destinations.length == 4, 'Duas abas de cada lado do Pix.');

  static const pixButtonKey = Key('nav-pix-button');

  /// Altura total ocupada (barra + margem), para as telas reservarem espaço.
  static const reservedHeight = 112.0;

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onPix;

  @override
  Widget build(BuildContext context) {
    // Em barras de navegação o texto cresce até 130%: acima disso os rótulos
    // não cabem. Os rótulos são curtos e os ícones continuam identificando.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: _GlassSurface()),
            Row(
              children: [
                for (var i = 0; i < 2; i++) _tab(i),
                const Expanded(child: SizedBox()),
                for (var i = 2; i < 4; i++) _tab(i),
              ],
            ),
            Positioned(
              top: -26,
              left: 0,
              right: 0,
              child: Center(child: _PixButton(onTap: onPix)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final destination = destinations[index];
    final selected = index == currentIndex;
    final color = selected ? AppColors.accent : AppColors.inkMuted;

    return Expanded(
      child: Semantics(
        selected: selected,
        child: Pressable(
          pressedScale: 0.94,
          semanticLabel: destination.label,
          onTap: () => onSelected(index),
          child: ExcludeSemantics(
            child: SizedBox(
              height: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(destination.icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(
                      fontSize: 11,
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Com alto contraste ligado, a translucidez atrapalha a leitura:
    // fundo sólido.
    final solid = MediaQuery.highContrastOf(context);
    const radius = BorderRadius.all(Radius.circular(26));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: solid ? 0 : 20,
            sigmaY: solid ? 0 : 20,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: solid ? 1 : 0.78),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PixButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      key: GlassNavBar.pixButtonKey,
      pressedScale: 0.94,
      semanticLabel: 'Pix, enviar dinheiro',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Brilho sutil no alto, como luz batendo num botão de verdade.
                gradient: const RadialGradient(
                  center: Alignment(-0.4, -0.6),
                  radius: 1,
                  colors: [Color(0xFF2E8A7C), AppColors.accent],
                ),
                border: Border.all(color: AppColors.ground, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.40),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.pix_rounded,
                color: AppColors.surface,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pix',
              style: AppText.caption.copyWith(
                fontSize: 11,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
