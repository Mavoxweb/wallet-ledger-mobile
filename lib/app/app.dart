import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';

class WalletLedgerApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Ledger',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Tela provisória: as rotas de verdade chegam com a sessão (PR 3).
      home: const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Wallet Ledger', style: AppText.display),
            SizedBox(height: AppSpacing.s),
            Text('Cada centavo no lugar', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
