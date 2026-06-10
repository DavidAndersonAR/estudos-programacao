# Módulo 19 — Produção: Boas Práticas

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Aplicar um **checklist consolidado** de produção em qualquer imagem/container
- Identificar e corrigir **anti-patterns** comuns
- Entender em alto nível quando usar **orquestradores** (Swarm, K8s, Nomad)
- Pegar um Dockerfile/compose de DEV e transformar em PROD com critério

## 🧭 A diferença DEV vs PROD em uma frase

Em DEV você quer **velocidade e conforto** (hot reload, root, volumes do código, latest). Em PROD você quer **previsibilidade, segurança e observabilidade** (imutável, non-root, sem volume de código, tag fixa).

Quase todo o resto deste módulo decorre disso.

---

## ✅ Checklist consolidado (a peça central)

Use isso como **lista de revisão antes de cada deploy**. Cada item é detalhado depois.

### 🔨 Build
- [ ] **Multi-stage** (Módulo 13): build em um stage, runtime em outro
- [ ] **`.dockerignore`** descartando `.git`, `node_modules` local, `*.env`, logs, testes
- [ ] **Base mínima** (`alpine`, `distroless`, `scratch` quando possível)
- [ ] **Versão fixa do `FROM`** (`node:20.11-alpine`, NUNCA `node:latest`)
- [ ] **Lock files commitados** (`package-lock.json`, `go.sum`, `requirements.txt` com hash)
- [ ] **`--no-cache` no `apk add` / `apt-get`** + limpeza de cache no mesmo `RUN`
- [ ] **Camadas ordenadas** do menos volátil pro mais volátil (Módulo 06)
- [ ] **Builds determinísticos**: mesmo input → mesma imagem (sem `date`, sem `RUN apt-get update` solto)

### 🔒 Segurança
- [ ] **`USER` non-root** (criar `appuser` com UID alto, ex: `10001`)
- [ ] **Scan de vulnerabilidades** no CI (`docker scout`, `trivy`, `snyk`)
- [ ] **Secrets externos** — NUNCA no Dockerfile/imagem (use Docker Secrets, Vault, AWS Secrets Manager, env do orquestrador)
- [ ] **Sem `sudo`, sem `setuid`, sem chaves SSH** dentro da imagem
- [ ] **Capabilities mínimas** (`--cap-drop=ALL` + só o necessário com `--cap-add`)
- [ ] **`--read-only`** no filesystem + `tmpfs` pra `/tmp` quando o app precisa escrever
- [ ] **Imagem assinada** (cosign / Docker Content Trust) — opcional mas recomendado

### 🏃 Runtime
- [ ] **`HEALTHCHECK`** definido (Módulo 17) — orquestrador precisa pra saber se reiniciar
- [ ] **`restart: unless-stopped`** ou `on-failure` (nunca `always` em compose de prod sem critério)
- [ ] **Limites de recurso**: `--memory`, `--cpus` (OOMKiller chega rápido sem isso)
- [ ] **Logs estruturados em JSON** indo pra `stdout`/`stderr` (NUNCA arquivo dentro do container)
- [ ] **`--init`** ou `tini` como PID 1 — pra `SIGTERM` propagar e zumbis serem reapeados
- [ ] **Graceful shutdown**: app escuta `SIGTERM` e fecha conexões antes de morrer
- [ ] **Timezone e locale** explícitos quando relevante (`TZ=America/Sao_Paulo`)

### 🔁 CI/CD
- [ ] **Build determinístico** (mesma imagem do CI = do dev = do prod)
- [ ] **Tags imutáveis** (commit SHA, semver) — NUNCA sobrescrever `1.2.3`
- [ ] **`latest` opcional** apontando pro último estável (mas deploy referencia SHA)
- [ ] **Cache de build** entre runs (`--cache-from`, BuildKit cache, registry cache)
- [ ] **Testes rodando ANTES do push** (unit + integração + scan)
- [ ] **Registry privado** com retention policy (Módulo 16)
- [ ] **Promoção entre ambientes** (dev → staging → prod) com a MESMA imagem

### 📊 Observabilidade
- [ ] **Logs em `stdout`/`stderr`** capturados pelo driver (`json-file`, `journald`, `fluentd`, `awslogs`)
- [ ] **Métricas Prometheus** expostas em `/metrics` (ou sidecar `cAdvisor`/`node-exporter`)
- [ ] **Distributed tracing** (OpenTelemetry → Jaeger/Tempo/Datadog)
- [ ] **Correlation ID** propagado entre serviços
- [ ] **Log level configurável por env** (`LOG_LEVEL=info` em prod, `debug` quando precisa)

### 🚀 Deploy
- [ ] **Rolling update** (sobe novo, derruba velho, sem downtime) — padrão Swarm/K8s
- [ ] **Blue/green** quando precisa rollback instantâneo (custa 2x recursos)
- [ ] **Canary** quando quer testar com 5% do tráfego antes do 100%
- [ ] **Rollback testado** — não adianta deploy bonito se não sabe voltar
- [ ] **Migrações de banco** versionadas e idempotentes, fora do start do app
- [ ] **Readiness vs liveness** separados (K8s) — readiness diz "pronto pra tráfego"

---

## 🚫 Anti-patterns (o que NÃO fazer)

| Anti-pattern | Por que dói | Como corrigir |
|---|---|---|
| `FROM ubuntu:latest` | Imagem gigante + tag móvel | `FROM ubuntu:22.04` ou alpine/distroless |
| Rodar como `root` | RCE = host comprometido | `USER appuser` |
| Secret hardcoded (`ENV API_KEY=...`) | Vaza no `docker history` | Docker Secrets / Vault / env do runtime |
| `COPY . .` sem `.dockerignore` | `node_modules`, `.git`, `.env` vão pra imagem | `.dockerignore` rígido |
| Log em arquivo dentro do container | Some quando o container morre | `stdout`/`stderr` sempre |
| `restart: always` sem healthcheck | Reinicia loop infinito quando quebra | Healthcheck + restart com backoff |
| Sem limite de memória | 1 container come a máquina toda | `--memory`, `--cpus` |
| `apt-get install` sem `--no-install-recommends` + sem limpar | Imagem 500MB maior | `--no-install-recommends && rm -rf /var/lib/apt/lists/*` |
| Tag `latest` em produção | Deploy não reproduzível, rollback impossível | Tag por SHA / semver |
| Banco no mesmo compose do app, sem volume | Perde dados na primeira reinicialização | Volume nomeado + backup |
| `CMD ["sh", "-c", "node app.js"]` | Shell vira PID 1, `SIGTERM` não chega no node | Forma exec: `CMD ["node", "app.js"]` |
| Build cache compartilhado entre branches sem isolar | Vaza segredo de um build pra outro | Cache scoped por branch/projeto |

---

## 🎼 Orquestradores — visão geral

Com 1 container, `docker run` basta. Com **dezenas em várias máquinas**, você precisa de orquestrador.

### Docker Swarm
- **Built-in no Docker** (`docker swarm init`)
- Mesmo formato de compose (`docker stack deploy`)
- Curva de aprendizado curta
- Comunidade menor, menos features avançadas
- **Bom pra**: times pequenos, clusters de 3-10 nós, quem já usa compose

### Kubernetes (K8s)
- **Padrão de mercado** (CNCF, todas as clouds têm: EKS, GKE, AKS)
- Ecossistema gigante (Helm, Istio, ArgoCD, Prometheus operator...)
- Curva íngreme (YAML pra tudo, conceitos: Pod, Deployment, Service, Ingress, ConfigMap, Secret, CRD...)
- **Bom pra**: produção séria, multi-time, multi-região, quando precisa escala/features avançadas

### HashiCorp Nomad
- Mais simples que K8s, mais flexível que Swarm
- Orquestra container + binário + VM + Java JAR (não só Docker)
- Integra bem com Vault e Consul (mesma família)
- **Bom pra**: times que já usam HashiCorp, cargas mistas

**Recomendação prática**: se você está começando e precisa de cluster, **Swarm** é o caminho mais curto. Se a empresa exige ou você quer carreira em DevOps moderno, **K8s** é o investimento.

---

## 🧠 Mentalidade de produção

Três princípios que valem mais que qualquer item do checklist:

1. **Imutabilidade**: a imagem que rodou em staging é EXATAMENTE a que vai pra prod. Sem rebuild "rapidinho na prod".
2. **Tudo pode morrer**: container, nó, região. Projete pra falhar — replicas, healthchecks, retries, circuit breakers.
3. **Observabilidade > debugging em produção**: quando algo quebra às 3am, logs/métricas/traces te salvam. Investir nisso ANTES de precisar.

---

## 🚦 Próximos passos
1. Faça a **prática**: Dockerfile + compose production-grade comentados
2. Faça o **desafio**: transformar um Dockerfile/compose de DEV em PROD, item por item do checklist
3. Vá pro Módulo 20 — **BuildKit & Buildx** (otimização avançada de build)

## ✅ Auto-verificação
- [ ] Consigo listar 5 itens do checklist de cada seção sem olhar
- [ ] Sei identificar 3 anti-patterns num Dockerfile aleatório
- [ ] Sei a diferença entre Swarm, K8s e Nomad em uma frase cada
- [ ] Sei o que é deploy rolling, blue/green e canary

Próximo módulo: **BuildKit & Buildx** — turbinando build, multi-plataforma, cache distribuído.
