import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

class KeysCard extends StatelessWidget {
  const new({required this.keys, super.key});

  static const maxKeys = 5;
  static const _text = Color(0xFF24514A);

  final List<PixKeyItem> keys;

  @override
  Widget build(BuildContext context) {
    final summary = keys.isEmpty
        ? 'Cadastre uma chave para receber Pix.'
        : keys.map((k) => k.label).join(' · ');

    return Container(
      height: 196,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Suas chaves Pix',
            style: AppText.caption.copyWith(color: _text),
          ),
          Text('${keys.length} de $maxKeys', style: AppText.money(30)),
          Text(
            summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption.copyWith(color: _text),
          ),
        ],
      ),
    );
  }
}
