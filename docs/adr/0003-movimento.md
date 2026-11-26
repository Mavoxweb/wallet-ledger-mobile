# ADR 0003 — Movimento com propósito e movimento reduzido

- **Status:** aceito
- **Data:** 26/11/2026

## Contexto

O visual aprovado pede um app "premium", com transições fluidas e animação de entrada. Animação demais, porém, deixa um app de uso diário lento, e uma parte das pessoas pede menos movimento nas configurações de acessibilidade do sistema.

## Decisão

Os tempos e as curvas ficam em um só lugar (`lib/core/motion/motion.dart`):

| Movimento | Tempo | Por quê |
|---|---|---|
| Resposta ao toque | 120 ms | Tem que parecer instantânea |
| Ocultar/mostrar saldo | 180 ms | Ação frequente |
| Troca de aba (fade + deslize de 8 px) | 220 ms | Acontece muitas vezes por dia |
| Folhas que sobem de baixo | 360 ms | Mudança de contexto, entram e saem pelo mesmo caminho |
| Entrada do app | 1100 ms | Uma vez por abertura |

Regras:
- **Curvas de saída fortes** (`Cubic(0.23, 1, 0.32, 1)`): o movimento começa rápido, então a resposta parece imediata. Nada de `easeIn` em interface.
- **Quique só como recompensa:** o ponto do ícone na entrada e o check do Pix concluído. Telas e listas não quicam.
- **Elemento compartilhado** (`Hero`) no cartão de saldo, do Início ao Extrato, para a pessoa entender que é a mesma informação.
- **Movimento reduzido:** quando o sistema pede (`MediaQuery.disableAnimationsOf`), os deslizes viram fades e a entrada mostra o ícone pronto, sem desenhar as linhas.
- **Splash nativo + animação de entrada:** o splash nativo (`flutter_native_splash`) cobre o tempo em que o motor do Flutter ainda está carregando e não consegue desenhar nada. Ele usa a mesma cor (`#0F1413`) e o mesmo símbolo que a `IntroAnimation`, então a troca não pisca.

## Consequências

- Mudar o "ritmo" do app é editar um arquivo.
- Os testes de widget rodam com animações completas (`pumpAndSettle`), e há testes com movimento reduzido e texto em 2x.
- O ícone (`tool/render_icon.py`) e o `BrandMark` seguem as mesmas proporções. Se um mudar, o outro precisa mudar junto.
