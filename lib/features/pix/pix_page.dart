import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/placeholder_page.dart';

/// Fluxo Pix: abre como uma folha que sobe de baixo.
/// O fluxo completo chega no PR 7.
class PixPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => PlaceholderPage(
    title: 'Enviar Pix',
    message: 'Digite a chave Pix de quem vai receber.',
    action: TextButton(
      onPressed: () => context.pop(),
      child: const Text('Fechar'),
    ),
  );
}
