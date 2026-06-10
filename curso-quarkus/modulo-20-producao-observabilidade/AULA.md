# Módulo 20 — Produção e Observabilidade

Último módulo do curso. Aqui a gente costura tudo: como deixar a aplicação **pronta pra produção** e como **enxergar** o que ela faz quando algo der errado (e vai dar).

## 🎯 Objetivos

- Entender os 3 pilares de observabilidade (logs, métricas, traces) e como o Quarkus suporta cada um.
- Configurar **OpenTelemetry** com auto-instrumentação e exportar traces via OTLP.
- Ativar **logs estruturados (JSON)** e enriquecer com `MDC` (requestId, traceId).
- Saber correlacionar log <-> trace usando `trace_id` / `span_id`.
- Entender a **stack Grafana** (Tempo, Loki, Prometheus) só na arquitetura.
- Configurar profile `%prod.*` com segurança razoável (schema validate, swagger off, log level info).
- Saber tratar **secrets**, **graceful shutdown** e **probes**.
- Sair com um **checklist de produção** que dá pra usar de verdade em revisão de deploy.

---

## Os 3 pilares (relembrando)

| Pilar     | Pergunta que responde                          | No Quarkus                                          |
|-----------|------------------------------------------------|-----------------------------------------------------|
| Logs      | "O que aconteceu nesse pedido?"                | JBoss Logging + `quarkus-logging-json`              |
| Métricas  | "Quantas vezes? Quão rápido? Quanto recurso?"  | `quarkus-micrometer-registry-prometheus` (módulo 18)|
| Traces    | "Onde foi o tempo dessa request entre serviços?"| `quarkus-opentelemetry`                            |

Sozinho, cada um é útil. Juntos (com correlation ID amarrando), você consegue: vê uma latência alta numa métrica → abre o trace daquela request → pula pro log com o `trace_id` → acha a exceção. Esse é o objetivo.

---

## OpenTelemetry no Quarkus

OpenTelemetry (OTel) é o padrão aberto para coletar traces (e cada vez mais, métricas e logs). O Quarkus já tem **auto-instrumentação**: você adiciona a extensão e as principais coisas (REST, REST Client, JDBC, Kafka) já saem instrumentadas.

```bash
./mvnw quarkus:add-extension -Dextensions="opentelemetry"
```

Configuração mínima:

```properties
quarkus.application.name=pedidos
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
quarkus.otel.exporter.otlp.protocol=grpc
```

Só isso já gera spans pra cada request HTTP, cada chamada de REST Client e cada query JDBC.

### Span customizado

Quando você quer marcar um trecho de negócio (ex: "calcular frete"), use `@WithSpan`:

```java
@WithSpan("calcular-frete")
public BigDecimal calcular(Pedido p) { ... }
```

Ou injete `Tracer` e crie manualmente. Em 95% dos casos, `@WithSpan` resolve.

---

## Logs estruturados (JSON)

Em dev, log colorido em texto é confortável. Em prod, **logs precisam ser JSON** para o coletor (Loki, Elastic, CloudWatch) parsear sem regex.

Extensão:

```bash
./mvnw quarkus:add-extension -Dextensions="logging-json"
```

Config:

```properties
%prod.quarkus.log.console.json=true
%prod.quarkus.log.level=INFO
```

Resultado por linha:

```json
{"timestamp":"2026-06-10T12:00:00Z","level":"INFO","loggerName":"com.exemplo.PedidoResource","message":"pedido criado","mdc":{"requestId":"abc-123","traceId":"7c8..."},"thread":"executor-thread-1"}
```

---

## MDC (Mapped Diagnostic Context)

MDC é um mapinha por thread que vai junto em **todo log emitido** dali pra frente. Perfeito para `requestId`, `userId`, `tenantId`.

```java
import org.jboss.logging.MDC;

MDC.put("requestId", UUID.randomUUID().toString());
log.info("processando"); // já sai com requestId no JSON
MDC.remove("requestId");
```

Em REST, faça isso num `ContainerRequestFilter` (`@Provider`) pra cobrir toda request — exemplo na pasta `pratica/`.

### Trace ID no log

Com `quarkus-opentelemetry` ativo, o `traceId` e `spanId` já entram no MDC automaticamente. Você abre o Grafana, copia o `traceId` do trace, joga na busca do Loki e acha todos os logs da request. É exatamente esse pulo que justifica todo o esforço.

---

## Profile `%prod.*`

O Quarkus tem 3 profiles padrão: `dev`, `test`, `prod`. Tudo que começa com `%prod.` só vale em produção. Isso evita que você acidentalmente derrube o schema do banco em prod porque esqueceu de mudar uma config.

Configs típicas de prod:

```properties
%prod.quarkus.hibernate-orm.database.generation=validate
%prod.quarkus.log.level=INFO
%prod.quarkus.log.console.json=true
%prod.quarkus.swagger-ui.always-include=false
%prod.quarkus.smallrye-openapi.path=/q/openapi
%prod.quarkus.http.cors=false
```

Em dev você pode ter `drop-and-create`, swagger ligado, log DEBUG. Em prod, nunca.

---

## Secrets

**Regra de ouro: nada de senha, token ou chave privada no `application.properties` versionado.** Use:

- Variáveis de ambiente: `${DB_PASSWORD}` no properties, `DB_PASSWORD=...` no ambiente.
- Em K8s: `Secret` montado como env var ou arquivo.
- Para algo mais sério: HashiCorp Vault (`quarkus-vault`), AWS Secrets Manager, etc.

```properties
quarkus.datasource.password=${DB_PASSWORD}
mp.jwt.verify.publickey.location=${JWT_PUBLIC_KEY_PATH}
```

Se rodar `git log -p application.properties` e aparecer senha, sua reação tem que ser: rotacionar a credencial **agora**, não "apago no próximo commit".

---

## Graceful shutdown

Quando o K8s manda `SIGTERM`, você não quer derrubar requests no meio. O Quarkus tem suporte nativo:

```properties
quarkus.shutdown.timeout=30s
```

Junto, no Deployment, configure `terminationGracePeriodSeconds: 45` (maior que o timeout do Quarkus). Fluxo: K8s manda SIGTERM → liveness segue OK por uns segundos → readiness vira NOT READY → tráfego para de chegar → requests em andamento terminam → app fecha. Sem 502 pro cliente.

---

## Stack Grafana (arquitetura)

Não vamos subir e configurar tudo aqui, mas é bom saber o nome dos componentes:

- **Prometheus** — coleta métricas (`/q/metrics`).
- **Loki** — banco de logs estruturados.
- **Tempo** — banco de traces (OTLP).
- **Grafana** — UI única que junta os três.
- **OpenTelemetry Collector** — gateway opcional; aplicação manda pra ele, ele encaminha. Útil pra desacoplar app de backend.

Na pasta `pratica/` tem um `docker-compose` simplificado pra brincar local.

---

## ✅ Checklist de produção

Use isso como porta de entrada antes de qualquer deploy sério.

**Banco / Persistência**
1. `quarkus.hibernate-orm.database.generation=validate` (nunca `drop`/`update`).
2. Migrações com Flyway ou Liquibase versionadas no repo.
3. Backup do banco automatizado e **restore testado**.

**Secrets / Config**
4. Nenhuma senha, token ou chave privada no properties versionado.
5. JWT public/private key vindo de secret manager ou volume montado.
6. Configs sensíveis vindo de env vars (`${VAR}`).

**Segurança da API**
7. RBAC ativo (`@RolesAllowed`) nos endpoints sensíveis.
8. Swagger / OpenAPI desligado em prod **ou** atrás de auth.
9. CORS configurado restritivamente (origens específicas).
10. Rate limiting / Fault tolerance (módulo 15) nos endpoints expostos.

**Runtime / K8s**
11. Resources `requests` e `limits` definidos (CPU e memória).
12. Liveness, readiness e startup probes apontando para `/q/health/*`.
13. Mais de 1 réplica + `PodDisruptionBudget`.
14. HPA configurado (CPU ou métrica custom).
15. `terminationGracePeriodSeconds` maior que `quarkus.shutdown.timeout`.

**Observabilidade**
16. Logs em JSON com `traceId` e `requestId`.
17. Métricas Prometheus expostas e scrape configurado.
18. Traces OTLP saindo para Tempo/Jaeger.
19. Dashboards e alertas básicos (latência p95, erro %, saturação).

**Entrega / Operação**
20. CI/CD com testes obrigatórios antes do deploy.
21. Native build (opcional) avaliado se cold start importa.
22. **Runbook** mínimo: o que fazer quando alerta X dispara, onde olhar.

Se algum item está vermelho, **não é "depois"**: registre como dívida com prazo.

---

## 💡 Detalhes

- **Profile `%prod` só ativa com `quarkus.profile=prod` ou no JAR built**. Em `mvn quarkus:dev`, ele NÃO está ativo — não confunda "rodando localmente" com "rodando em produção".
- **Log JSON quebra o copy-paste humano**. Tudo bem: em dev fica texto, em prod fica JSON, justamente porque o público muda (humano vs. máquina).
- **Não exporte trace de 100% das requests num sistema grande**. Use sampling (`quarkus.otel.traces.sampler=parentbased_traceidratio`, `quarkus.otel.traces.sampler.arg=0.1` = 10%).
- **Cuidado com PII no log**. CPF, email, número de cartão — nunca logar. Mesmo em JSON estruturado. Auditoria do GDPR/LGPD pega isso.
- **Health check de banco fora de hora**: liveness que bate no banco pode derrubar o pod em uma indisponibilidade momentânea de rede. Use readiness pra dependências, liveness só pra "o processo está vivo".

---

## 🚦 Próximos passos

Acabou o curso, mas estudar Quarkus em produção é uma jornada:

- **Quarkus Native (GraalVM)**: cold start em ms, footprint baixo. Aprenda quando vale e quando complica (reflection, recursos dinâmicos).
- **Mensageria avançada**: dead letter, idempotência, sagas (continuação do módulo 13).
- **Kubernetes em profundidade**: operators, service mesh (Istio/Linkerd), tracing entre pods.
- **OpenTelemetry Collector**: configurar pipelines de processamento de traces e métricas.
- **Chaos engineering**: derrubar coisas de propósito (Litmus, Chaos Mesh) e ver se a observabilidade pegou.
- **SRE / SLO**: definir objetivos de serviço e medir burn rate de error budget.

E o mais importante: coloque algo em produção. Nenhum curso substitui um incidente real às 3 da manhã.

---

## ✅ Auto-verificação

1. Quais são os 3 pilares de observabilidade e que pergunta cada um responde?
2. Como o `traceId` chega no log JSON automaticamente?
3. Por que NUNCA usar `database.generation=update` em prod?
4. Como funciona o graceful shutdown no Quarkus + K8s? Quem espera quem?
5. Cite 5 itens do checklist relacionados a segurança/secrets.
6. Para que serve o profile `%prod.` e o que NÃO deveria estar fora dele?
7. Quando vale usar sampling de traces em vez de 100%?
8. O que é o OpenTelemetry Collector e por que usar?
