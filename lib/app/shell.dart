import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';

const _destinations = [
  NavDestination(label: 'Início', icon: Icons.home_rounded),
  NavDestination(label: 'Extrato', icon: Icons.format_list_bulleted_rounded),
  NavDestination(label: 'Cobrar', icon: Icons.qr_code_2_rounded),
  NavDestination(label: 'Perfil', icon: Icons.person_outline_rounded),
];

/// Casca das quatro abas, com a barra flutuante por cima do conteúdo.
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 16,
            right: 16,
            bottom: 22 + MediaQuery.paddingOf(context).bottom,
            child: GlassNavBar(
              destinations: _destinations,
              currentIndex: navigationShell.currentIndex,
              // Tocar na aba atual volta ao topo dela,
              // como nos apps do sistema.
              onSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              onPix: () => context.push('/pix'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantém as quatro abas vivas (cada uma guarda rolagem e estado) e troca
/// entre elas com fade + deslize curto. Com movimento reduzido, só fade.
class AnimatedBranchContainer extends StatelessWidget {
  const new({required this.currentIndex, required this.children, super.key});

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Stack(
      children: [
        for (var i = 0; i < children.length; i++)
          IgnorePointer(
            ignoring: i != currentIndex,
            // TickerMode pausa animações das abas escondidas.
            child: TickerMode(
              enabled: i == currentIndex,
              child: AnimatedOpacity(
                opacity: i == currentIndex ? 1 : 0,
                duration: AppMotion.tab,
                curve: AppCurves.easeOut,
                child: AnimatedSlide(
                  offset: reduced || i == currentIndex
                      ? Offset.zero
                      : const Offset(0, 0.01),
                  duration: AppMotion.tab,
                  curve: AppCurves.easeOut,
                  child: children[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
