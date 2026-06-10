# Módulo 11 — Docker Compose Básico

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que Compose existe e quando usar
- Ler e escrever um `docker-compose.yml` do zero
- Subir uma stack inteira (app + DB) com **um único comando**
- Diferenciar **nome do projeto** de **nome do serviço**
- Usar os comandos essenciais: `up`, `down`, `logs`, `ps`, `exec`, `config`

## 🤔 Por que Compose?

Imagine sua aplicação real: API + banco + cache + worker + frontend. Subir tudo na mão com `docker run` vira um inferno:

```bash
docker network create minha-rede
docker run -d --name db --network minha-rede -e POSTGRES_PASSWORD=... -v db_data:/var/lib/postgresql/data postgres:16
docker run -d --name redis --network minha-rede redis:7
docker run -d --name api --network minha-rede -p 3000:3000 -e DB_HOST=db -e REDIS_HOST=redis minha-api
# ... e mais 3 comandos
```

Trabalhoso, frágil, não dá pra versionar com clareza, e seu colega precisa decorar tudo.

**Docker Compose** resolve isso. Você descreve **toda a stack num arquivo YAML** e sobe com:

```bash
docker compose up -d
```

É o **"infra como código" do dia a dia do dev**: o `docker-compose.yml` mora no repositório, vai pro Git, e qualquer pessoa que clonar o projeto sobe o ambiente igualzinho ao seu.

## 📄 Anatomia do `docker-compose.yml`

Um arquivo Compose moderno é uma árvore YAML com **services**, **volumes** e **networks** no topo. Exemplo mínimo:

```yaml
services:
  web:
    image: nginx:1.27
    ports:
      - "8080:80"
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

Dois comandos depois (`docker compose up -d`) você tem nginx + postgres rodando, conectados na mesma rede, com volume persistente. Sem decoreba.

> 💡 **Compose v2** (a CLI moderna) usa `docker compose` (com espaço). A versão antiga era `docker-compose` (com hífen, binário separado em Python). Pode esquecer a antiga — desde 2023 a v2 é o padrão. O campo `version:` no topo do YAML também caiu em desuso; Compose moderno ignora.

## 🧱 Os principais campos de um service

### `image` vs `build`

```yaml
services:
  api:
    image: minha-api:1.0      # usa imagem pronta
  api2:
    build: ./api              # constrói da pasta ./api (precisa ter Dockerfile)
  api3:
    build:
      context: ./api
      dockerfile: Dockerfile.dev
    image: minha-api:dev      # tag a ser dada à imagem construída
```

Você pode ter **só `image`**, **só `build`** ou **os dois** (build + tag).

### `ports` — exposição pro host

```yaml
ports:
  - "8080:80"          # host:container
  - "127.0.0.1:5432:5432"  # bind só no localhost (mais seguro)
```

### `environment` — variáveis

Duas sintaxes equivalentes:

```yaml
environment:
  POSTGRES_PASSWORD: secret
  POSTGRES_DB: appdb

# ou lista:
environment:
  - POSTGRES_PASSWORD=secret
  - POSTGRES_DB=appdb
```

Você também pode usar `env_file: .env` pra carregar de um arquivo (Módulo 09 já cobriu).

### `volumes` — persistência

```yaml
services:
  db:
    volumes:
      - db_data:/var/lib/postgresql/data    # named volume (recomendado)
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro  # bind mount read-only

volumes:
  db_data:    # declaração no topo é OBRIGATÓRIA pra named volume
```

### `networks` — quem fala com quem

Por padrão, **Compose cria uma rede pro projeto** e coloca todos os serviços nela. Eles se enxergam pelo **nome do serviço** (DNS interno):

```yaml
services:
  api:
    image: minha-api
    environment:
      DB_HOST: db        # ← "db" resolve pra IP do container do serviço db
  db:
    image: postgres:16
```

Pra cenários mais complexos (isolar serviços), você declara redes nomeadas:

```yaml
networks:
  frontend:
  backend:

services:
  web:
    networks: [frontend]
  api:
    networks: [frontend, backend]
  db:
    networks: [backend]    # web não consegue falar com db direto
```

### `restart` — política de reinício

```yaml
restart: unless-stopped    # reinicia se cair, mas respeita stop manual
```

Opções: `no` (padrão), `always`, `on-failure`, `unless-stopped`.

### `depends_on` — ordem de subida

```yaml
services:
  api:
    depends_on:
      - db
```

⚠️ **Cuidado**: `depends_on` só garante que o container do `db` **subiu**, não que o Postgres **terminou de inicializar** e está aceitando conexões. Pra esperar o serviço ficar "healthy" mesmo, combine com `healthcheck` (Módulo 17).

## 🎮 Comandos essenciais

### `up` — sobe tudo

```bash
docker compose up              # foreground, logs no terminal
docker compose up -d           # detached (background)
docker compose up --build      # força rebuild das imagens
docker compose up -d db redis  # sobe apenas serviços específicos
```

### `down` — derruba tudo

```bash
docker compose down              # para e remove containers + rede
docker compose down --volumes    # ⚠️ TAMBÉM apaga os volumes (perde dados!)
docker compose down --rmi all    # remove até as imagens
```

### `logs` — ver o que tá rolando

```bash
docker compose logs              # logs de todos os serviços
docker compose logs -f api       # follow, só do serviço 'api'
docker compose logs --tail=50 db
```

### `ps` — status dos serviços

```bash
docker compose ps          # serviços do projeto atual
docker compose ps -a       # inclui parados
```

### `exec` — entrar num container rodando

```bash
docker compose exec db psql -U postgres
docker compose exec api sh
```

### `restart` — reiniciar serviços

```bash
docker compose restart api
```

### `config` — validar o YAML

```bash
docker compose config           # imprime o YAML "resolvido" (vars expandidas)
docker compose config --quiet   # só valida, sem imprimir
```

Salvador de vidas: antes de subir, rode `config` pra ver erros de sintaxe e ver como suas variáveis ficaram.

## 🏷️ Nome do projeto vs nome do serviço

- **Nome do serviço** é a chave dentro de `services:` no YAML — vira o **hostname** dentro da rede do Compose.
- **Nome do projeto** é um prefixo que o Compose usa pra nomear containers, redes e volumes. Por padrão é **o nome da pasta** onde está o `docker-compose.yml`.

Se a pasta se chama `pratica/` e o serviço se chama `db`:
- Container: `pratica-db-1`
- Rede: `pratica_default`
- Volume named `db_data`: `pratica_db_data`

Você pode forçar:

```bash
docker compose -p meu-projeto up -d
```

Ou via env var `COMPOSE_PROJECT_NAME`.

## 💡 Detalhes que economizam tempo

- **Rebuild só quando necessário**: `docker compose up -d` não rebuilda por padrão. Se mudou o Dockerfile, use `--build`.
- **YAML é sensível a indentação**: use 2 espaços e nunca tab. Se a stack não sobe e a mensagem é "mapping values are not allowed here", é indentação.
- **Variáveis `${VAR}` no YAML**: Compose lê automaticamente o `.env` da mesma pasta. Útil pra senhas e portas configuráveis (`POSTGRES_PASSWORD: ${DB_PASSWORD}`).
- **`docker compose down` NÃO apaga volumes named** (a não ser com `--volumes`). Seus dados estão a salvo.
- **Cada `up` re-aplica o YAML**: mudou uma env var, rode `docker compose up -d` de novo — Compose recria só os containers que mudaram.
- **Logs misturados**: `docker compose logs` colore por serviço, o que ajuda a separar visualmente.

## 🚦 Próximos passos
1. Faça a prática: stack `postgres + adminer`, suba e acesse o Adminer em http://localhost:8080
2. Faça o desafio: adicione Redis na stack, com volumes pra cada serviço
3. No Módulo 12 a gente sobe multi-serviço de verdade (app custom + DB + cache)

## ✅ Auto-verificação
- [ ] Sei explicar a vantagem do Compose vs `docker run` em uma frase
- [ ] Sei a diferença entre `image:` e `build:`
- [ ] Sei o que `depends_on` garante (e o que NÃO garante)
- [ ] Sei como serviços se enxergam pela rede (DNS pelo nome do serviço)
- [ ] Rodei `up -d`, `ps`, `logs`, `exec` e `down` na stack da prática

Próximo módulo: **Compose Multi-Serviço** — onde a gente sobe app + DB + cache de verdade.
