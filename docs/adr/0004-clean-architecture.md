# ADR 0004 — Clean Architecture: domain, data e presentation

- **Status:** aceito
- **Data:** 27/11/2026

## Contexto

Até aqui cada feature tinha `data/` (repositório e modelos), `bloc/` e `view/`. Os Blocs já dependiam de repositórios abstratos, e não do cliente gerado. Na prática era a arquitetura que o Flutter recomenda (MVVM, com o Bloc no papel de ViewModel).

Numa revisão, um desenvolvedor Flutter apontou que projetos grandes, com várias pessoas mexendo ao mesmo tempo, costumam separar `data`, `domain` e `presentation`. Os casos de uso protegem a regra de negócio, porque não conhecem pacotes externos nem sabem de onde o dado vem.

A regra pesada deste sistema (saldo nunca negativo, partidas dobradas, estorno) mora na API, que já é Clean Architecture em .NET. O app tem pouca regra própria. Foram consideradas três opções:

| Opção | Custo | Por que não |
|---|---|---|
| Manter e explicar num ADR | Nenhum | Não é a estrutura que quem avalia apps Flutter espera encontrar |
| Pastas novas, caso de uso só onde há regra | Baixo | Mistura dois estilos: quem chega não sabe se deve criar caso de uso ou não |
| **Clean completa, um caso de uso por ação** | Classes que só repassam a chamada | **Escolhida** |

## Decisão

```
features/<feature>/
  domain/        entidades, contrato do repositório, casos de uso (Dart puro)
  data/          Api…Repository: fala com o cliente gerado e converte para o domínio
  presentation/  Blocs, Cubits, páginas e widgets
```

- **Um caso de uso por ação**, com um único `call()`. São 15: `GetAccount`, `GetStatement`, `CheckSession`, `GetMe`, `Login`, `Register`, `Logout`, `ClearSession`, `ListPixKeys`, `AddPixKey`, `RemovePixKey`, `LookupPixKey`, `SendPix`, `CreateCharge`, `MakeSimulatedDeposit`.
- **Onde há regra, ela mora no caso de uso.** O limite de 5 chaves do Banco Central saiu do `KeysCubit` e foi para o `AddPixKey`, que recusa a sexta chave sem chamar a API.
- **O que depende do fluxo continua no Bloc.** Reaproveitar a `Idempotency-Key` depende da etapa em que a pessoa está (voltou, mudou o valor, tentou de novo). Isso é estado da tela, então quem decide é o `PixTransferBloc`. O `SendPix` recebe a chave pronta.
- **As telas só leem casos de uso.** `UseCaseScope` monta os casos de uso sobre os repositórios. O app passa os repositórios reais, e os testes passam os falsos.
- **As falhas são Dart puro.** `Failure` fica em `core/errors`, e a conversão de `DioException` fica em `core/network/api_guard.dart`. Assim o domínio fala em falhas sem conhecer HTTP.
- **A regra é verificada por teste, não por disciplina.** O `test/architecture_test.dart` falha se:
  - um arquivo de `domain/` importar Flutter, Dio, o cliente gerado, `data/` ou `presentation/`;
  - um arquivo de `presentation/` importar `data/` ou o cliente gerado;
  - uma tela ler um repositório direto.

## Consequências

- Trocar a origem dos dados (outra API, cache local) mexe só em `data/`. O domínio e as telas não mudam, e o teste de arquitetura garante que continue assim.
- Uma ação nova passa a pedir três peças: o método no repositório, o caso de uso e o Bloc. Para um app deste tamanho, é mais cerimônia do que o necessário. O custo foi aceito em troca de uma estrutura previsível para qualquer pessoa que chegue.
- A maioria dos casos de uso só repassa a chamada ao repositório. Eles não ganham teste próprio, porque já são exercitados pelos testes dos Blocs, que usam os casos de uso reais sobre repositórios falsos. Os que têm regra (`AddPixKey`) têm teste próprio.
