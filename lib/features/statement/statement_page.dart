import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/placeholder_page.dart';

class StatementPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: 'Extrato',
    message: 'Suas movimentações aparecem aqui.',
  );
}
