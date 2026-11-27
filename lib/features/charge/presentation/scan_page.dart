import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/brcode.dart';
import 'package:wallet_ledger_mobile/features/pix/presentation/pix_page.dart';

/// Converte o texto lido (câmera ou colado) no preenchimento do Pix.
/// Nulo se não for um BR Code Pix válido.
PixPrefill? readPixQr(String raw) {
  try {
    final code = parseBrCode(raw);
    return PixPrefill(pixKey: code.pixKey, amountCents: code.amountCents);
  } on FormatException {
    return null;
  }
}

class ScanPage extends StatefulWidget {
  const new({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// Último código inválido: a câmera lê o mesmo QR várias vezes por
  /// segundo, e o aviso não deve piscar a cada leitura.
  String? _lastInvalid;
  String? _message;
  bool _done = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _handle(String raw) {
    if (_done) return;
    final prefill = readPixQr(raw);
    if (prefill == null) {
      if (raw == _lastInvalid) return;
      _lastInvalid = raw;
      // Leitura inválida não trava a câmera: avisa e continua lendo.
      setState(() => _message = 'Esse QR code não é um Pix válido.');
      return;
    }
    _done = true;
    unawaited(HapticFeedback.lightImpact());
    unawaited(_controller.stop());
    // Troca o leitor pelo Pix: o "voltar" do Pix não reabre a câmera.
    context.pushReplacement('/pix', extra: prefill);
  }

  /// Campo de texto em vez de ler a área de transferência: no navegador,
  /// ler por código pede permissão.
  Future<void> _paste() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.ground,
      builder: (_) => const _PasteSheet(),
    );
    if (text == null || !mounted) return;
    _lastInvalid = null;
    _handle(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final code in capture.barcodes) {
                final raw = code.rawValue;
                if (raw != null) _handle(raw);
              }
            },
            errorBuilder: (context, error) => const _CameraUnavailable(),
          ),
          const _Viewfinder(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    child: IconButton(
                      tooltip: 'Fechar',
                      color: AppColors.surface,
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _message ?? 'Aponte a câmera para o QR code Pix.',
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            color: _message == null
                                ? AppColors.surface
                                : const Color(0xFFFFB4A6),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      FilledButton.tonalIcon(
                        onPressed: _paste,
                        icon: const Icon(Icons.content_paste_rounded),
                        label: const Text('Colar código Pix'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.mint, width: 3),
          ),
        ),
      ),
    );
  }
}

/// Sem câmera (permissão negada, computador sem webcam): explica e deixa o
/// "colar código" como saída.
class _CameraUnavailable extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: AppColors.onInkMuted,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Não deu para usar a câmera.',
                textAlign: TextAlign.center,
                style: AppText.title.copyWith(color: AppColors.surface),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Libere a câmera nas configurações ou cole o código Pix.',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(color: AppColors.onInkMuted),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasteSheet extends StatefulWidget {
  const new();

  @override
  State<_PasteSheet> createState() => _PasteSheetState();
}

class _PasteSheetState extends State<_PasteSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (readPixQr(text) == null) {
      setState(
        () => _error =
            'Esse código não é um Pix válido. Confira se '
            'copiou o código inteiro.',
      );
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Colar código Pix', style: AppText.title),
              const SizedBox(height: AppSpacing.l),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  labelText: 'Pix Copia e Cola',
                  hintText: '00020126...',
                  errorText: _error,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: 'Continuar',
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
