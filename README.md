# Wallet Ledger Mobile

App do correntista do **Wallet Ledger**, em Flutter: saldo, Pix por chave, extrato e QR code de cobrança.

> Faz parte do **Wallet Ledger**:
> - [wallet-ledger-api](https://github.com/Mavoxweb/wallet-ledger-api): API (.NET)
> - **wallet-ledger-mobile**: este app (Flutter)
> - **wallet-ledger-backoffice**: painel da operação em Angular *(em construção)*

## Como rodar

Pré-requisito: Flutter 3.50.

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Como testar

```bash
flutter test
```
