import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';

/// Uma linha de movimentação (usada no Início e no Extrato).
class MovementTile extends StatelessWidget {
  const new({required this.movement, super.key, this.trailingCaption});

  final Movement movement;

  /// Texto pequeno embaixo do valor (a hora, no Extrato).
  final String? trailingCaption;

  /// Título: quem enviou/recebeu, ou o tipo da operação.
  static String titleOf(Movement m) => switch (m.kind) {
    MovementKind.deposit => 'Depósito',
    MovementKind.reversal => 'Estorno',
    MovementKind.transfer => m.counterparty ?? 'Pix',
  };

  /// Subtítulo: o tipo e, quando houver, a descrição.
  static String subtitleOf(Movement m) {
    final kind = switch (m.kind) {
      MovementKind.deposit => 'Depósito simulado',
      MovementKind.reversal => 'Estorno',
      MovementKind.transfer => m.isIncoming ? 'Pix recebido' : 'Pix enviado',
    };
    final description = m.description;
    final extra =
        description == null ||
            description == 'PIX' ||
            description == 'Depósito simulado'
        ? null
        : description;
    return extra == null ? kind : '$kind · $extra';
  }

  @override
  Widget build(BuildContext context) {
    final incoming = movement.isIncoming;
    final amountColor = incoming ? AppColors.accent : AppColors.ink;
    final icon = switch (movement.kind) {
      MovementKind.deposit => Icons.add_rounded,
      MovementKind.reversal => Icons.undo_rounded,
      MovementKind.transfer =>
        incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: incoming ? AppColors.accentSoft : const Color(0xFFF1F2EE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: amountColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleOf(movement),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleOf(movement),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCents(movement.signedCents, signed: true),
                style: AppText.money(15, color: amountColor),
              ),
              if (trailingCaption != null) ...[
                const SizedBox(height: 2),
                Text(
                  trailingCaption!,
                  style: AppText.caption.copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
