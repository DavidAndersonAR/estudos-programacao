# Desafio — Sistema de Eventos com Múltiplos Consumers

## Cenário

Você vai construir um mini-sistema de **eventos de usuário**. Quando um evento chega via REST, ele é publicado num tópico Kafka e **dois consumers independentes** reagem a ele:

- **Auditor**: registra (loga) cada evento pra auditoria.
- **Notificador**: simula envio de notificação (só loga "Notificando usuário X").

Os dois leem do **mesmo tópico** mas em **grupos diferentes** — assim cada um recebe **todas** as mensagens (não há divisão).

## Requisitos

1. Crie o DTO `Evento` (record) com campos: `String tipo`, `String usuario`, `String payload`, `Instant timestamp`.
2. Endpoint **POST `/eventos`** que recebe um `Evento` e publica no channel `eventos-out` (tópico `eventos`).
   - Use `Emitter<Evento>`.
   - Responda `202 Accepted` com o evento publicado.
3. Crie **dois** beans `@ApplicationScoped` consumindo o tópico `eventos`:
   - `AuditorConsumer` no grupo `auditoria` — loga `[AUDITORIA] tipo=X usuario=Y`.
   - `NotificadorConsumer` no grupo `notificacao` — loga `[NOTIFICACAO] enviando para Y`.
4. Configure tudo no `application.properties` com serialização JSON.
5. Bônus: filtre no `NotificadorConsumer` pra **só notificar** eventos do tipo `"LOGIN"` ou `"COMPRA"` — outros tipos só logam "ignorado".
6. Bônus 2: configure **DLT** no channel do auditor com `failure-strategy=dead-letter-queue`.

## Pista importante

Dois consumers no **mesmo grupo** dividem as mensagens (load balance). Em **grupos diferentes**, cada um recebe **todas** — perfeito pra fan-out (1 evento → N reações).

## Como testar

```bash
./mvnw quarkus:dev

curl -X POST http://localhost:8080/eventos \
  -H "Content-Type: application/json" \
  -d '{"tipo":"LOGIN","usuario":"ana","payload":"{}"}'
```

Você deve ver **dois logs** pra cada POST: um do auditor, outro do notificador.

## Estrutura esperada

```
desafio/
  Evento.java.solucao
  EventoResource.java.solucao
  AuditorConsumer.java.solucao
  NotificadorConsumer.java.solucao
  application.properties.solucao
```

Resolva primeiro por conta. Só abra os `.solucao` depois.
