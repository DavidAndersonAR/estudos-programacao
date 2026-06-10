# Curso de Quarkus — do Básico ao Avançado

> Mesmo padrão dos outros cursos. 20 módulos progressivos, do primeiro endpoint REST até produção com native image e observabilidade. Quarkus é o framework Java "supersônico, subatômico" otimizado pra cloud — startup em milissegundos, footprint de RAM minúsculo, ideal pra Kubernetes/serverless.

## Estrutura

Cada módulo tem 3 arquivos:
1. **AULA.md** — teoria condensada com exemplos
2. **pratica/** — código Java/config pronto pra testar
3. **desafio/** — miniprojeto com TODOs e solução comentada

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo + Setup** — o que é Quarkus, instalar CLI, criar projeto, live reload. 🎯 *Primeiro endpoint funcionando*
- **02 — REST básico (RESTEasy Reactive)** — `@Path`, `@GET/POST/PUT/DELETE`, path/query params, JSON. 🎯 *CRUD em memória*
- **03 — Injeção de Dependência (CDI)** — `@ApplicationScoped`, `@Inject`, `@Singleton`, ciclos de vida. 🎯 *Camadas Service/Repository*
- **04 — Configuração (MicroProfile Config)** — `application.properties`, `@ConfigProperty`, profiles (dev/test/prod). 🎯 *App configurável*
- **05 — Persistência com Panache (JPA simplificado)** — `PanacheEntity`, repository pattern, queries fluentes. 🎯 *CRUD com PostgreSQL*

### Fase 2 — Integração
- **06 — REST Client (chamar APIs externas)** — `@RegisterRestClient`, interfaces declarativas. 🎯 *Consumir API pública*
- **07 — Validação (Hibernate Validator)** — `@NotNull`, `@Email`, `@Size`, grupos, mensagens. 🎯 *DTOs validados*
- **08 — Tratamento de erros** — `ExceptionMapper`, RFC 7807 problem details. 🎯 *Erros padronizados*
- **09 — Testes (JUnit 5 + RestAssured)** — `@QuarkusTest`, mocks com `@InjectMock`, `@QuarkusIntegrationTest`. 🎯 *Suite de testes completa*
- **10 — Segurança (JWT + RBAC)** — `quarkus-smallrye-jwt`, `@RolesAllowed`. 🎯 *API protegida por roles*

### Fase 3 — Avançado
- **11 — OpenAPI + Swagger UI** — `quarkus-smallrye-openapi`, anotações de documentação. 🎯 *Doc auto-gerada*
- **12 — Reativo com Mutiny (Uni/Multi)** — programação assíncrona, operadores, backpressure. 🎯 *Endpoint reativo*
- **13 — Mensageria com Kafka (SmallRye Reactive Messaging)** — `@Incoming`, `@Outgoing`, channels. 🎯 *Produtor + consumidor*
- **14 — gRPC** — protobuf, servidor e cliente Quarkus. 🎯 *Serviço gRPC*
- **15 — Fault Tolerance (MicroProfile)** — `@Retry`, `@Timeout`, `@CircuitBreaker`, `@Fallback`. 🎯 *App resiliente*

### Fase 4 — Produção
- **16 — Health Checks + Métricas** — `/q/health`, `/q/metrics`, Micrometer + Prometheus. 🎯 *App observável*
- **17 — Cache** — `@CacheResult`, `@CacheInvalidate`, Caffeine/Redis. 🎯 *API mais rápida*
- **18 — Native Image (GraalVM)** — compilação AOT, reflection config, tamanho/startup. 🎯 *Binário nativo*
- **19 — Deploy no Kubernetes** — Quarkus Kubernetes extension, geração de manifests, container image. 🎯 *App no kind*
- **20 — Produção: Observabilidade + Tracing** — OpenTelemetry, Grafana stack, logs estruturados, checklist. 🎯 *Pronto pra prod*

## Pré-requisitos
- **JDK 21+** (LTS, recomendado pelo Quarkus 3.x)
- **Maven 3.9+** ou Gradle (vamos usar Maven via Quarkus CLI)
- **Docker** (pra Postgres/Kafka/Redis e Dev Services)
- **kubectl + kind** (Módulo 19) — você já tem do curso K8s
- Editor: IntelliJ IDEA (Community) ou VS Code com extensão Quarkus

## Quarkus CLI
A CLI facilita criar projetos, adicionar extensões e rodar dev mode. Instalamos no Módulo 01.

```bash
# JBang (forma mais simples no Windows):
# https://www.jbang.dev/download
jbang app install --fresh --force quarkus@quarkusio
quarkus --version
```

## Dev Services
Diferencial enorme do Quarkus: em modo dev, ele **sobe automaticamente containers** Docker pra Postgres, Kafka, Redis, etc. Você não precisa de docker-compose pra desenvolver — só adicionar a extensão.

## Material de apoio
- Docs oficiais: https://quarkus.io/guides/
- Quarkus CLI: https://quarkus.io/guides/cli-tooling
- Code generator (web): https://code.quarkus.io
- Mutiny: https://smallrye.io/smallrye-mutiny
- Quarkus Insights (YouTube): https://www.youtube.com/c/Quarkusio

Bom estudo!
