# ADR 0002 — Cliente HTTP gerado do contrato da API

- **Status:** aceito
- **Data:** 26/11/2026

## Contexto

A API (.NET) publica seu contrato OpenAPI em cada release (`openapi.json`, gerado a partir dos controllers). Escrever os modelos e as chamadas à mão no app duplicaria esse contrato, e qualquer mudança na API só seria percebida em produção.

## Decisão

- O pacote `packages/wallet_ledger_api` é **gerado** pelo `openapi-generator` (gerador `dart-dio`), a partir do contrato da release fixada em `contract.version`. O script é `tool/generate_api.sh`.
- O código gerado é **commitado**. Assim o app compila sem Java nem rede, e a revisão do PR mostra exatamente o que mudou no contrato.
- **O CI regenera o cliente** e falha se o resultado for diferente do commitado (alguém editou à mão ou trocou a versão sem regenerar).
- O app nunca usa os tipos gerados nas telas. Cada repositório (`ApiPixRepository`, `ApiKeysRepository`…) traduz o modelo gerado para um modelo do app e converte erros em `Failure` (`ApiFailure`, `ValidationFailure`, `NetworkFailure`) com `guard()`.

## Consequências

- Atualizar a API é uma decisão explícita: trocar `contract.version`, rodar o script e corrigir o que o compilador apontar.
- O código gerado não segue o lint do app. Ele fica fora da análise, num pacote separado.
- A camada de repositórios isola o resto do app: se o gerador mudar o formato, só os repositórios mudam.
