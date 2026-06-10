# Desafio — Mapper de Conflito de Negócio (409)

## Contexto
No seu sistema, algumas operações falham por **regras de negócio** — não por dado inválido nem por recurso ausente, mas porque o estado atual impede a ação. Exemplos:

- Tentar **cancelar** um pedido que já foi enviado
- Tentar **cadastrar** um produto com SKU que já existe
- Tentar **debitar** valor maior que o saldo

O HTTP tem um status pra isso: **`409 Conflict`**.

## O que você vai construir

1. **`ConflitoNegocioException`** — exceção customizada que carrega:
   - uma **mensagem principal** (ex.: "Pedido não pode ser cancelado")
   - uma **lista de motivos** (`List<String>`), porque pode haver mais de um
   - um **`code`** estável (ex.: `"PEDIDO_JA_ENVIADO"`)

2. **`ConflitoNegocioMapper`** — `@Provider` + `ExceptionMapper<ConflitoNegocioException>`:
   - status **409**
   - `Content-Type: application/problem+json`
   - body no padrão `ProblemDetail` reutilizando o do módulo prático
   - inclua os motivos como **lista** dentro do payload (pode reaproveitar `errors` ou criar um campo novo `motivos`)

3. **`PedidoResource`** com pelo menos 2 endpoints que disparam o conflito:
   - `POST /pedidos/{id}/cancelar` — lança quando o pedido já foi enviado
   - `POST /pedidos` — lança quando o número do pedido já existe (simule em memória)

4. **`comandos.sh`** com `curl`s que provocam cada caso de 409 e mostram a resposta esperada.

## Critérios de aceitação
- [ ] Resposta tem `Content-Type: application/problem+json`
- [ ] Status code é **exatamente 409**
- [ ] Payload tem `title`, `status: 409`, `detail`, `code` e a **lista de motivos**
- [ ] **Não** vaza stack trace
- [ ] O mapper **não** captura outras exceções (continua valendo a regra "mais específico primeiro")
- [ ] `404` (recurso inexistente) continua funcionando via mapper do módulo prático

## Dica
Reaproveite `ProblemDetail` da pasta `pratica/`. Não precisa duplicar o DTO. Para a lista de motivos, você pode:
- usar `errors` com `campo = null` e `mensagem = motivo`, OU
- adicionar um campo `public List<String> motivos;` no `ProblemDetail`.

A segunda opção é mais limpa semanticamente.

## Entregáveis
- `ConflitoNegocioException.solucao`
- `ConflitoNegocioMapper.solucao`
- `PedidoResource.solucao`
- `comandos.sh.solucao`

> Os arquivos `.solucao` estão nesta pasta — só consulte depois de tentar!
