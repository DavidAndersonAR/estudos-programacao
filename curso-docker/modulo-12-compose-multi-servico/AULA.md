# Módulo 12 — Compose Multi-Serviço

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Orquestrar uma **stack inteira** (frontend + backend + DB + cache) num único `docker-compose.yml`
- Usar **healthchecks** pra garantir que um serviço está **realmente pronto** antes de subir o próximo
- Entender a diferença entre `depends_on` simples (só ordem) e `depends_on` com `condition: service_healthy` (espera prontidão)
- Subir só parte da stack com **profiles** (ex: ambiente "dev" com adminer, prod sem)
- Isolar serviços em **networks customizadas** (frontend vs backend vs db)
- Reaproveitar config com **anchors YAML** (`&` / `*`) e **extends**
- Parametrizar tudo com `.env` e `${VAR}`
- Usar `docker-compose.override.yml` pra customização local sem mexer no compose principal

## 🪜 De onde a gente veio
No Módulo 11 você subiu um compose simples (2 ou 3 serviços, um `depends_on` básico). Funcionava — mas tinha bugs sutis:

- O backend subia antes do Postgres aceitar conexão → erro `connection refused` na primeira tentativa
- Pra adicionar um adminer só em desenvolvimento, você tinha 2 arquivos compose separados
- Senha do banco hardcoded no YAML
- Frontend e DB no mesmo network (frontend NÃO precisa enxergar o DB direto)

Esse módulo resolve **todos esses problemas**.

## 🚦 `depends_on` — a armadilha clássica

```yaml
services:
  api:
    image: minha-api
    depends_on:
      - db
  db:
    image: postgres:16
```

Isso diz: "começa o `db` **antes** da `api`". Só isso.

**O que NÃO faz:** esperar o Postgres aceitar conexões. O processo do `postgres` é iniciado, o container fica "running" em segundos — mas o banco demora mais 5-15s pra estar pronto pra aceitar query. A API sobe nesse meio-tempo e quebra.

A "solução" antiga era um script `wait-for-it.sh` ou `dockerize` no entrypoint da API. Hoje em dia: **healthcheck + depends_on com `condition`**.

```yaml
services:
  api:
    depends_on:
      db:
        condition: service_healthy   # ← espera o healthcheck ficar "healthy"
  db:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
```

Agora a API só inicia quando o `pg_isready` der OK. Bug eliminado.

Os 3 valores válidos pra `condition`:
| `condition` | Significado |
|---|---|
| `service_started` | (padrão) só espera o container iniciar |
| `service_healthy` | espera o healthcheck passar |
| `service_completed_successfully` | espera o container terminar com exit 0 (útil pra jobs de migration) |

## 🩺 `healthcheck` — anatomia

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres -d minha_db"]
  interval: 10s      # de quanto em quanto tempo roda
  timeout: 5s        # quanto espera cada execução antes de marcar como falha
  retries: 3         # falhas consecutivas pra marcar como "unhealthy"
  start_period: 30s  # tempo de "graça" no início — falhas aqui não contam
```

Formato de `test`:
- `["CMD", "curl", "-f", "http://localhost/"]` — exec direto, sem shell
- `["CMD-SHELL", "curl -f http://localhost/ || exit 1"]` — passa por `sh -c`, permite pipes/redirect
- `["NONE"]` — desabilita healthcheck herdado da imagem base

Estados possíveis (veja com `docker ps`):
- `starting` — dentro do `start_period`
- `healthy` — passou
- `unhealthy` — falhou `retries` vezes seguidas

💡 **`start_period` é seu amigo.** Postgres pode demorar 15s pra inicializar; sem ele, os primeiros healthchecks falham e contam pro `retries`, marcando como unhealthy cedo demais.

### Exemplos prontos pra colar
```yaml
# Postgres
test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]

# Redis
test: ["CMD", "redis-cli", "ping"]

# HTTP genérico
test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/health"]

# MySQL
test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
```

⚠️ O `$$` escapa a variável — sem ele, o Compose tenta substituir `${POSTGRES_USER}` no seu host (e provavelmente acha vazio).

## 🎚️ `profiles` — sobe só parte da stack

E se você quer um `adminer` (GUI pro Postgres) só quando está desenvolvendo, mas nunca em produção?

```yaml
services:
  api:
    image: minha-api
    # sem profile → sempre sobe
  
  adminer:
    image: adminer
    ports: ["8081:8080"]
    profiles: ["dev"]   # ← só sobe se você ativar esse profile
```

Como ativar:
```bash
# Só serviços sem profile (default):
docker compose up

# Inclui o profile "dev":
docker compose --profile dev up

# Múltiplos profiles:
docker compose --profile dev --profile debug up
```

Ou no `.env`:
```env
COMPOSE_PROFILES=dev,debug
```

Casos clássicos de uso:
- `dev` — adminer, mailhog, ferramentas de inspeção
- `test` — runner de testes (`docker compose --profile test up --abort-on-container-exit`)
- `monitoring` — prometheus + grafana opcionais
- `debug` — container com gdb/strace anexado

## 🌐 Networks customizadas e múltiplas

Por padrão, o Compose cria UMA network e joga todos os serviços lá. Todo serviço vê todo serviço — o que **não é o que você quer** em prod.

Padrão real: **frontend network** (nginx + api), **backend network** (api + db + redis). O nginx **não** consegue falar com o Postgres direto — porque não tem motivo.

```yaml
networks:
  frontend:
  backend:

services:
  nginx:
    networks: [frontend]
  
  api:
    networks: [frontend, backend]   # bridge entre as duas
  
  db:
    networks: [backend]
  
  redis:
    networks: [backend]
```

Resultado:
- `nginx` resolve `api` (mesma network `frontend`) ✅
- `nginx` NÃO resolve `db` ❌ (pelo menos por DNS — e não consegue rotear pra lá)
- `api` resolve `db` e `redis` (network `backend`) ✅

Isso é **defense in depth** — se o nginx for comprometido, o atacante não tem rota direta pro DB.

## 🔁 `anchors` YAML — reuso sem duplicar

YAML tem nativo o conceito de **âncora** (`&nome`) e **alias** (`*nome`). Funciona em qualquer YAML, não é específico do Docker.

```yaml
x-common-env: &common-env
  TZ: America/Sao_Paulo
  LOG_LEVEL: info

services:
  api:
    image: minha-api
    environment:
      <<: *common-env       # merge — herda tudo do anchor
      APP_NAME: api

  workers:
    image: meus-workers
    environment:
      <<: *common-env
      APP_NAME: workers
```

A chave `x-` é convenção: o Compose **ignora** chaves top-level que começam com `x-`. Você usa elas só pra hospedar âncoras.

Também dá pra ancorar healthchecks inteiros, restart policies, logging — qualquer bloco que se repete.

```yaml
x-healthcheck-defaults: &hc-defaults
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 20s

services:
  api:
    healthcheck:
      <<: *hc-defaults
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/health"]
```

## 🧬 `extends` — herança entre arquivos compose

Mais antigo que anchors, ainda útil quando você quer **importar de outro arquivo**:

```yaml
# compose.base.yml
services:
  app-base:
    image: node:lts-alpine
    restart: unless-stopped
    environment:
      NODE_ENV: production
```

```yaml
# docker-compose.yml
services:
  api:
    extends:
      file: compose.base.yml
      service: app-base
    command: ["node", "api.js"]
  
  workers:
    extends:
      file: compose.base.yml
      service: app-base
    command: ["node", "workers.js"]
```

Diferenças anchors × extends:
- **Anchors**: mesma file, sintaxe YAML pura, merge mais flexível
- **Extends**: cross-file, sintaxe Compose, ignora `depends_on`/`volumes_from` (evita confusão)

Na prática 90% dos casos hoje resolvem com anchors. `extends` é útil pra monorepos com compose compartilhado entre N projetos.

## 🔐 Variáveis em compose — `.env` e `${VAR}`

```env
# .env (mesma pasta do docker-compose.yml)
POSTGRES_PASSWORD=s3nh4-supersecreta
POSTGRES_DB=app
API_PORT=8080
TAG=v1.2.3
```

```yaml
services:
  api:
    image: minha-api:${TAG}
    ports:
      - "${API_PORT}:8080"
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
```

Regras importantes:
1. `.env` é carregado **automaticamente** se estiver na mesma pasta do `docker-compose.yml`
2. Pra usar outro nome: `docker compose --env-file .env.prod up`
3. Variável vazia ou ausente → string vazia. Pra dar erro: `${VAR:?mensagem de erro}`
4. Pra default: `${VAR:-valor-default}`
5. **NUNCA commite `.env` com segredos.** Adicione no `.gitignore` e commit um `.env.example`

```yaml
ports:
  - "${API_PORT:-8080}:8080"          # default 8080
  
environment:
  DB_PASS: ${POSTGRES_PASSWORD:?precisa definir POSTGRES_PASSWORD}
```

## 🪟 `docker-compose.override.yml` — customização local

O Compose, por padrão, lê **dois** arquivos quando você roda `docker compose up`:
1. `docker-compose.yml` (base, vai pro git)
2. `docker-compose.override.yml` (overrides locais, **NÃO** vai pro git)

O override mescla em cima do base. Caso de uso clássico:

```yaml
# docker-compose.yml (commitado)
services:
  api:
    image: minha-api:${TAG:-latest}
    restart: unless-stopped
```

```yaml
# docker-compose.override.yml (gitignored)
services:
  api:
    build: ./api          # local: builda em vez de pull
    volumes:
      - ./api:/app        # hot reload
    command: npm run dev  # comando de dev em vez de prod
```

Pra ignorar o override: `docker compose -f docker-compose.yml up`. Pra usar outro arquivo:
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## 🎯 Cheat sheet — comandos Compose multi-serviço

| Comando | O que faz |
|---|---|
| `docker compose up -d` | Sobe stack toda em background |
| `docker compose up --build` | Rebuilda imagens antes de subir |
| `docker compose --profile dev up` | Inclui serviços do profile `dev` |
| `docker compose ps` | Lista serviços (com status de health) |
| `docker compose logs -f api` | Logs do serviço `api` em tempo real |
| `docker compose exec api sh` | Shell num serviço rodando |
| `docker compose restart api` | Reinicia só um serviço |
| `docker compose down` | Para e remove containers/networks (volumes ficam) |
| `docker compose down -v` | Inclui volumes (CUIDADO: apaga dados) |
| `docker compose config` | Mostra o YAML final (resolvido com .env e overrides) |
| `docker compose pull` | Atualiza imagens sem subir |

💡 `docker compose config` é o seu **debugger**: mostra exatamente como o Compose interpretou tudo depois de resolver variáveis, anchors e override.

## 💡 Detalhes que economizam tempo
- **Healthcheck custa CPU/IO.** Não bote `interval: 1s` em 20 serviços — vai pesar.
- **Healthcheck na imagem base já existe** em muitas imagens oficiais (`postgres`, `nginx`). Sobrescreva só se precisar.
- **`condition: service_healthy` faz cascata**: se A depende de B saudável e B depende de C saudável, A espera C → B → A.
- **Anchors NÃO funcionam entre arquivos.** Pra cross-file use `extends` ou `include` (Compose v2.20+).
- **Networks customizadas dão nomes DNS limpos**: dentro da network, o serviço `db` é resolvido como `db` (sem prefixo do projeto).
- **`depends_on` não causa restart em cascata.** Se o DB cair e voltar, a API não é reiniciada automaticamente — só o `restart: unless-stopped` segura.
- **Profile padrão é vazio.** Serviço sem `profiles:` sempre sobe; com `profiles: [dev]` só sobe se você ativar.

## 🚦 Próximos passos
1. Leia o `pratica/docker-compose.yml` linha a linha
2. Rode o `comandos.sh` da prática e veja a saúde dos serviços evoluindo (`docker compose ps` mostra `(healthy)`)
3. Resolva o desafio — stack de 5 serviços com profile `dev`
4. Módulo 13: **multi-stage builds** — imagens 10x menores

## ✅ Auto-verificação
- [ ] Sei a diferença entre `depends_on` simples e com `condition: service_healthy`
- [ ] Sei escrever um `healthcheck` pra Postgres e pra HTTP
- [ ] Sei separar serviços em 2+ networks pra isolamento
- [ ] Uso anchors YAML pra não repetir blocos
- [ ] `.env` está no `.gitignore` e tenho um `.env.example` versionado
- [ ] Sei o que o `docker-compose.override.yml` faz sem precisar configurar nada

Próximo módulo: **Multi-stage Builds** — onde a imagem de 1.2GB vira 80MB.
