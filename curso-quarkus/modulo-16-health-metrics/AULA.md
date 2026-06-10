# Módulo 16 — Health Checks e Métricas

## 🎯 Objetivos

- Entender por que toda app em produção precisa de **health checks** e **métricas**.
- Habilitar `quarkus-smallrye-health` e usar os endpoints `/q/health`, `/q/health/ready`, `/q/health/live`, `/q/health/started`.
- Implementar `HealthCheck` customizado com `@Liveness`, `@Readiness` e `@Startup`.
- Habilitar `quarkus-micrometer-registry-prometheus` e expor `/q/metrics` em formato Prometheus.
- Criar **counters**, **gauges**, **timers** e **distribution summaries** customizados.
- Usar `@Counted` e `@Timed` direto em métodos.
- Conectar tudo nas **probes do Kubernetes**.

## Por que isso importa?

Quando sua app sobe num cluster (Kubernetes, OpenShift, Nomad), o orquestrador precisa saber:

1. **A app está viva?** (liveness) — Se não, **reinicia o pod**.
2. **A app está pronta pra receber tráfego?** (readiness) — Se não, **tira do load balancer**.
3. **A app já terminou de subir?** (startup) — Pra apps lentas que não devem ser mortas durante o boot.

E pra monitorar (Grafana, Datadog, NewRelic) você precisa **expor métricas** num formato padrão. O Prometheus virou o de facto.

## Health Checks com SmallRye Health

```bash
./mvnw quarkus:add-extension -Dextensions="quarkus-smallrye-health"
```

Só de adicionar, você já ganha endpoints:

| Endpoint              | Pra quê                                   |
|-----------------------|-------------------------------------------|
| `/q/health`           | Status geral (liveness + readiness + startup) |
| `/q/health/live`      | Só liveness — a JVM está respondendo?     |
| `/q/health/ready`     | Só readiness — dependências OK pra servir?|
| `/q/health/started`   | Só startup — terminou de inicializar?     |

Resposta JSON padrão:

```json
{
  "status": "UP",
  "checks": [
    { "name": "Banco", "status": "UP" },
    { "name": "Disco", "status": "UP", "data": { "livre_gb": 12 } }
  ]
}
```

Se **qualquer** check retornar `DOWN`, o status geral fica `DOWN` e o HTTP volta `503`.

## Anatomia de um HealthCheck

```java
@Readiness                                  // ou @Liveness, ou @Startup
@ApplicationScoped
public class BancoHealthCheck implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        try {
            // ping no banco, fila, API externa...
            return HealthCheckResponse.up("Banco");
        } catch (Exception e) {
            return HealthCheckResponse.down("Banco");
        }
    }
}
```

Forma fluente, com dados extras:

```java
return HealthCheckResponse.named("Disco")
        .status(livre > 1_000_000_000L)
        .withData("livre_gb", livre / 1_073_741_824L)
        .build();
```

### Qual qualifier usar?

| Qualifier     | Quando usar                                              |
|---------------|----------------------------------------------------------|
| `@Liveness`   | Coisa que, se falhar, só **restart do pod resolve** (deadlock, memória corrompida). |
| `@Readiness`  | Dependência externa: banco, fila, API. Cai → tira do LB. |
| `@Startup`    | Inicialização demorada (cache warm-up, migrations).      |

## Métricas com Micrometer + Prometheus

```bash
./mvnw quarkus:add-extension -Dextensions="quarkus-micrometer-registry-prometheus"
```

Endpoint exposto: `GET /q/metrics` no formato texto do Prometheus:

```
# HELP jvm_memory_used_bytes The amount of used memory
jvm_memory_used_bytes{area="heap",id="Eden Space"} 5.242880E7
pedidos_criados_total{origem="api"} 42.0
http_server_requests_seconds_count{method="GET",uri="/pedidos",status="200"} 17.0
```

Por padrão você já ganha métricas de JVM, HTTP server, datasource, threads, GC.

### Os 4 tipos principais

| Tipo                  | Pra quê                                            | Exemplo                       |
|-----------------------|----------------------------------------------------|-------------------------------|
| **Counter**           | Conta só pra cima (eventos)                        | `pedidos_criados_total`       |
| **Gauge**             | Valor que sobe e desce no tempo                    | `fila_pendentes`              |
| **Timer**             | Duração + contagem de chamadas                     | `tempo_processamento_pedido`  |
| **DistributionSummary** | Distribuição de valores (não é tempo)            | `valor_pedido_reais`          |

### Forma programática

```java
@Inject MeterRegistry registry;

void criar(Pedido p) {
    registry.counter("pedidos.criados", "origem", "api").increment();
    registry.summary("pedido.valor", "moeda", "BRL").record(p.valor.doubleValue());
}
```

### Forma declarativa

```java
@POST
@Counted(value = "pedidos.criados", description = "Pedidos criados via REST")
@Timed(value = "pedidos.tempo", description = "Tempo pra criar pedido")
public Response criar(Pedido p) { ... }
```

### Gauge — registrado uma vez

```java
@PostConstruct
void init() {
    registry.gauge("fila.pendentes", fila, FilaPedidos::tamanho);
}
```

O Micrometer chama `tamanho()` toda hora que o `/q/metrics` é raspado.

## Integração com Kubernetes

No `deployment.yaml`:

```yaml
livenessProbe:
  httpGet:
    path: /q/health/live
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /q/health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /q/health/started
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

E pra scraping de métricas, anote o pod:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/q/metrics"
    prometheus.io/port: "8080"
```

## 💡 Detalhes

- **Readiness `DOWN` → Kubernetes tira o pod do Service** (sem matar). O tráfego para de chegar, mas o pod continua rodando.
- **Liveness `DOWN` → Kubernetes mata o container e sobe outro.** Cuidado: se o liveness depender do banco e o banco cair, todos os pods morrem em cascata. **Liveness deve checar só a própria JVM.**
- O nome do check (`HealthCheckResponse.named(...)`) precisa ser único — duplicado sobrescreve.
- `withData()` aceita `String`, `long`, `boolean`. Aparece como objeto JSON na resposta.
- Métricas com **muitas tags de alta cardinalidade** (ex.: ID de usuário) explodem a memória do Prometheus. Use só dimensões finitas (status code, método HTTP).
- `@Timed` cria automaticamente `_seconds_count`, `_seconds_sum`, `_seconds_max`. Pra percentis (p95, p99), adicione `histogram = true`.
- O Quarkus também tem `quarkus-micrometer-registry-otlp` se você usa OpenTelemetry/Tempo.
- Em dev mode, o **Dev UI** (`/q/dev`) mostra health e métricas direto.

## 🚦 Próximos passos

- Módulo 17: **Observabilidade completa** — tracing distribuído com OpenTelemetry.
- Montar um **dashboard Grafana** consumindo `/q/metrics`.
- Configurar **alertas no Prometheus** (`pedidos_criados_total` parou de crescer há 5min → algo travou).

## ✅ Auto-verificação

- [ ] Acessei `/q/health` e vi o JSON com `status: "UP"`.
- [ ] Criei pelo menos um `HealthCheck` com `@Readiness` e outro com `@Liveness`.
- [ ] Forcei o readiness pra `DOWN` e confirmei que `/q/health/ready` volta `503`.
- [ ] Acessei `/q/metrics` e vi métricas em formato Prometheus.
- [ ] Anotei um endpoint com `@Counted` e vi o contador subir após algumas chamadas.
- [ ] Anotei um endpoint com `@Timed` e identifiquei as séries `_count`, `_sum`, `_max`.
- [ ] Registrei um `Gauge` customizado.
- [ ] Escrevi o snippet de `livenessProbe` e `readinessProbe` no YAML.
