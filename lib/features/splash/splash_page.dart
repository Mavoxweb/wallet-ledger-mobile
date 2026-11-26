import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/widgets/brand_mark.dart';

/// Tela enquanto a sessão é verificada. A animação de entrada chega no PR 4.
class SplashPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(child: BrandMark(size: 112)),
    );
  }
}
