import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/empty_state.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/keys/cubit/keys_cubit.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/view/add_key_sheet.dart';

class KeysPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = KeysCubit(keys: context.read<KeysRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const _KeysView(),
    );
  }
}

class _KeysView extends StatelessWidget {
  const new();

  /// Remover é a única ação aqui que não dá para desfazer sozinho (a chave
  /// pode até ser cadastrada por outra pessoa depois): por isso confirma.
  Future<void> _confirmDelete(BuildContext context, PixKeyItem key) async {
    final cubit = context.read<KeysCubit>();
    final events = context.read<AccountEvents?>();
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover esta chave?'),
        content: Text(
          '${_display(key)}\n\nQuem usar essa chave não vai mais conseguir '
          'te enviar Pix por ela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter chave'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover chave'),
          ),
        ],
      ),
    );
    if (remove ?? false) {
      await cubit.delete(key.id);
      events?.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KeysCubit>();

    return BlocListener<KeysCubit, KeysState>(
      // Falhas de cadastro aparecem dentro da folha; aqui, só as de remover
      // (campos separados no estado, para a mensagem não sair duas vezes).
      listenWhen: (previous, current) =>
          current.deleteFailure != null &&
          previous.deleteFailure != current.deleteFailure,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(messageFor(state.deleteFailure!))),
        ),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<KeysCubit, KeysState>(
            builder: (context, state) => ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.xl,
                GlassNavBar.reservedHeight,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: const Text('Chaves Pix', style: AppText.display),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        state.status == KeysStatus.ready
                            ? '${state.keys.length} de ${KeysCubit.maxKeys} '
                                  'chaves cadastradas'
                            : 'Até ${KeysCubit.maxKeys} chaves por conta',
                        style: AppText.caption,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ..._body(context, state, cubit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, KeysState state, KeysCubit cubit) {
    switch (state.status) {
      case KeysStatus.loading:
        return const [Center(child: CircularProgressIndicator())];
      case KeysStatus.failure:
        return [
          EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Não deu para carregar suas chaves',
            message: messageFor(state.failure!),
            action: OutlinedButton(
              onPressed: cubit.load,
              child: const Text('Tentar de novo'),
            ),
          ),
        ];
      case KeysStatus.ready:
        return [
          if (state.keys.isEmpty)
            const EmptyState(
              icon: Icons.key_rounded,
              title: 'Nenhuma chave ainda',
              message: 'Cadastre uma chave para receber Pix e gerar QR codes.',
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.tile),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  for (final key in state.keys)
                    _KeyTile(
                      item: key,
                      onDelete: state.busy
                          ? null
                          : () => _confirmDelete(context, key),
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          if (state.atLimit)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.m),
              child: Text(
                'Você chegou ao limite de 5 chaves. Remova uma para '
                'cadastrar outra.',
                style: AppText.caption,
              ),
            ),
          PrimaryButton(
            label: 'Cadastrar chave',
            icon: Icons.add_rounded,
            onPressed: state.atLimit || state.busy
                ? null
                : () => showAddKeySheet(context, cubit),
          ),
        ];
    }
  }
}

String _display(PixKeyItem key) =>
    key.kind == PixKeyKind.evp ? key.value : key.label;

class _KeyTile extends StatelessWidget {
  const new({required this.item, required this.onDelete});

  final PixKeyItem item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String kind) = switch (item.kind) {
      PixKeyKind.email => (Icons.alternate_email_rounded, 'E-mail'),
      PixKeyKind.phone => (Icons.phone_iphone_rounded, 'Celular'),
      PixKeyKind.evp => (Icons.shuffle_rounded, 'Chave aleatória'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind, style: AppText.caption),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover chave',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
