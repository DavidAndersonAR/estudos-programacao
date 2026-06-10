# Desafio do Módulo 20 — Auditoria de produção

## Cenário

Você vai colocar uma aplicação Quarkus real no ar. Pode ser a sua, um projeto pessoal antigo ou um clone de algum exemplo do curso. **Não precisa estar pronta**: o objetivo é justamente descobrir o que falta.

A missão é simples: passar por **todos os 22 itens do checklist de produção** (`checklist-producao.md`), marcar o status de cada um e gerar um plano de correção.

## O que entregar

1. **Checklist preenchido** (`checklist-producao.md` copiado e marcado):
   - `[x]` para itens OK.
   - `[ ]` para itens faltando, com **uma linha** explicando o gap.
   - `[~]` para itens parcialmente atendidos.

2. **Plano de ação** com os itens pendentes priorizados:
   - **P0** — bloqueante para subir (ex: senha no git, schema sendo dropado).
   - **P1** — pode subir, mas precisa resolver na próxima sprint.
   - **P2** — bom ter; melhora operação.

3. **Implementar pelo menos 3 melhorias reais** no código/config. Sugestões:
   - Ativar log JSON em prod.
   - Configurar OpenTelemetry com OTLP.
   - Adicionar `LogContextFilter` com `requestId`.
   - Configurar `%prod.quarkus.hibernate-orm.database.generation=validate`.
   - Mover secrets para env vars.
   - Adicionar probes de health no manifesto K8s.
   - Configurar graceful shutdown.

## Critérios de aceitação

- Checklist com os 22 itens avaliados (nenhum em branco).
- Plano de ação separado em P0/P1/P2.
- 3+ melhorias implementadas e commitadas (com mensagem clara).
- Se possível, **um screenshot** do log em JSON com `traceId` aparecendo.

## Dicas

- Não tente arrumar tudo de uma vez. Isso vira projeto de 1 mês. O objetivo é **enxergar** o estado real.
- Se você não tem K8s, simule no docker-compose: o raciocínio de probe, secret e resource limit continua válido.
- Itens "P0 fáceis" costumam ser: schema generation, secret no properties, swagger ligado em prod. Olha esses primeiro.
- Se algum item parecer não se aplicar (ex: HPA num app interno de baixíssimo tráfego), justifique em uma linha. "Não se aplica" sem justificativa não vale.

## Para reflexão (não precisa entregar)

- Quantos itens **P0** você encontrou? Honestamente, sua app está pronta pra produção hoje?
- Dos itens P1, qual seria o primeiro a doer num incidente?
- Você sabe **onde olhar** se um pedido travar agora? Se a resposta é "no log do servidor", o módulo de observabilidade ainda não está completo.
