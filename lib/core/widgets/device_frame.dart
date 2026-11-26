import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// Em telas largas (a demo web aberta num computador), mostra o app numa
/// moldura do tamanho de um celular, centralizada. No celular, não faz nada.
class DeviceFrame extends StatelessWidget {
  const new({required this.child, super.key});

  static const breakpoint = 600.0;
  static const width = 430.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < breakpoint) return child;

    final height = size.height > 932 ? 932.0 : size.height - 32;
    return ColoredBox(
      color: const Color(0xFFE6E8E3),
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: AppShadows.deep,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            // O app dentro da moldura "acha" que a tela
            // tem o tamanho do celular.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(size: Size(width, height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
