import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/placeholder_page.dart';

class ChargePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderPage(
    title: 'Cobrar',
    message: 'Gere um QR code para receber um Pix.',
  );
}
