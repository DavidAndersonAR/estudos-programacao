# Desafio — Módulo 16

Você foi contratado pra deixar o serviço de **Notificações** pronto pra Kubernetes. Hoje ele sobe sem nenhuma sinalização do que está saudável e ninguém tem ideia de quantas notificações estão saindo.

## Tarefas

### 1. Três Health Checks customizados

Implemente, cada um em sua própria classe:

- `EmailGatewayHealthCheck` (**@Readiness**) — simula um ping num SMTP. Tem um boolean estático `disponivel` que começa `true`. Inclua um endpoint REST `POST /admin/email/{up|down}` pra alternar esse boolean em runtime.
- `MemoriaHealthCheck` (**@Liveness**) — fica `DOWN` se a JVM tiver menos de 50 MB livres. Retorne `livre_mb` e `total_mb` no `withData`.
- `CacheWarmupHealthCheck` (**@Startup**) — fica `DOWN` por 5 segundos depois do start (simula warm-up) e depois fica `UP` pra sempre. Use `Instant.now()` no construtor.

### 2. Duas métricas customizadas

No `NotificacaoResource`:

- `notificacoes.enviadas` (**Counter**) com tag `canal` (`EMAIL`, `SMS`, `PUSH`). Anote o endpoint `POST /notificacoes` com `@Counted` **e** incremente programaticamente o counter com a tag certa dentro do método.
- `notificacoes.tempo_envio` (**Timer**, com `histogram = true`) aplicado via `@Timed` no mesmo endpoint.
- Bônus: registre um **Gauge** chamado `notificacoes.taxa_sucesso` que retorna `enviadasOk / totalEnviadas` (use dois `AtomicLong`).

### 3. Snippet de Kubernetes

Crie um arquivo `deployment.yaml` (não precisa ser válido completão, foco nas probes) com:

- `livenessProbe` apontando pra `/q/health/live`, `initialDelaySeconds: 15`, `periodSeconds: 10`.
- `readinessProbe` apontando pra `/q/health/ready`, `periodSeconds: 5`.
- `startupProbe` apontando pra `/q/health/started`, `failureThreshold: 30`, `periodSeconds: 5`.
- Annotations pro Prometheus raspar `/q/metrics`.

### 4. Validação manual

No `comandos.sh`:

1. `curl /q/health` — todos UP.
2. `curl -X POST /admin/email/down` — derruba o gateway.
3. `curl /q/health/ready` — deve voltar **503**.
4. `curl /q/health/live` — deve continuar **200** (liveness não depende do email!).
5. Envie 5 notificações e mostre os contadores em `/q/metrics`.

## Critérios

- Cada check tem o **qualifier correto** (justifique mentalmente: matar pod resolve? então liveness).
- O nome de cada check é único.
- O counter tem **dimensão por canal**, não 3 counters separados.
- O YAML usa as 3 probes adequadamente.

## Dica

`HealthCheckResponse.named("X").status(condicao).withData(...).build()` é seu amigo. E lembre: **liveness nunca depende de coisa externa**, só da própria JVM.
