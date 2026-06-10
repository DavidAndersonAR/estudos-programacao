# Módulo 14 — Otimização de Imagem

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escolher a **imagem base** certa (alpine, distroless, scratch) pro seu caso
- Escrever um `.dockerignore` que economiza minutos de build
- Combinar `RUN` com `&&` e cleanup pra não inflar layers
- Reduzir uma imagem em **80% ou mais** sem perder nada importante
- Auditar layers com `dive` e vulnerabilidades com `docker scout`

## 🐘 O problema: imagens gordas custam caro

Imagem de 1.2GB vs 80MB — qual a diferença prática?
- **Pull mais lento** em todo deploy (CI, prod, dev novo entrando no time)
- **Mais superfície de ataque** (mais pacotes = mais CVE)
- **Mais $ em storage** no registry (Docker Hub, ECR, GCR cobram)
- **Cold start lento** em serverless / Kubernetes (puxar imagem antes de subir)
- **Cache de layer maior** = builds demoram mais

Regra de ouro: **se você não usa, não instala. Se instalou, limpa.**

## 🪨 Imagens base: do gordo ao quase nada

| Base | Tamanho | Tem shell? | Quando usar |
|---|---|---|---|
| `ubuntu` / `debian` | ~70-120MB | sim, tudo | dev local, quando precisa de muitas libs do SO |
| `node` / `python` (full) | ~900MB+ | sim, tudo | quase NUNCA em prod — usa pra build |
| `node:alpine` / `python:alpine` | ~50-180MB | sim (ash) | prod típica — pequeno e completo o suficiente |
| `gcr.io/distroless/...` | ~20-50MB | **não** | prod hardened — só app + runtime, sem shell |
| `scratch` | **0 bytes** | nada | binários estáticos (Go, Rust) — vazia mesmo |

### Alpine (~5MB)
Linux minimalista baseado em `musl` (não glibc). Tem `apk` em vez de `apt`. Cuidado: algumas libs compiladas pra glibc podem não funcionar direto (resolve com `apk add libc6-compat` ou base diferente).

```dockerfile
FROM node:20-alpine
RUN apk add --no-cache curl  # --no-cache é o equivalente do && rm cache
```

### Distroless (Google)
Só tem o app + runtime (libc, ca-certificates, tzdata). Sem `sh`, sem `apt`, sem `ls`. Não dá pra `docker exec -it bash` — é proposital, **endurece** a imagem.

```dockerfile
# Build stage com Node completo
FROM node:20 AS build
WORKDIR /app
COPY . .
RUN npm ci --omit=dev

# Runtime distroless — sem shell, sem nada além do node
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=build /app .
CMD ["server.js"]
```

### Scratch (vazia)
Pra binários **estaticamente linkados** — Go é o caso clássico:

```dockerfile
FROM golang:1.23 AS build
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /bin/app

FROM scratch
COPY --from=build /bin/app /app
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/app"]
```

Resultado típico: **<15MB** pra um servidor Go HTTPS. Bonito demais.

## 📁 `.dockerignore` — o arquivo mais subestimado

Quando você faz `docker build .`, o Docker manda o **contexto inteiro** (toda a pasta) pro daemon. Se tem `node_modules/`, `.git/`, `dist/`, vídeos, dumps de DB... vai tudo. Build fica lento mesmo antes de começar.

`.dockerignore` funciona igual `.gitignore`:

```gitignore
# Dependências (vão ser instaladas no build)
node_modules
vendor
__pycache__
*.pyc

# Build artifacts
dist
build
target
*.log

# VCS
.git
.gitignore

# Editores
.vscode
.idea
*.swp

# Ambiente local
.env
.env.local
docker-compose.override.yml

# Docker (não precisa do próprio Dockerfile no contexto após build)
Dockerfile*
.dockerignore

# Testes e docs (se não rodar dentro da imagem)
tests
*.md
```

**Impacto real**: projeto Node com `node_modules` de 500MB — sem `.dockerignore`, cada build manda meio gigabyte pro daemon. Com `.dockerignore`, manda 2MB.

## 🧹 Combinando `RUN` e fazendo cleanup

Cada `RUN` cria uma **layer**. Cache de apt em `/var/lib/apt/lists/` fica congelado na layer mesmo que você delete depois — porque deletar em outra layer não apaga da anterior.

❌ **Errado** (3 layers, cache fica):
```dockerfile
RUN apt-get update
RUN apt-get install -y curl git
RUN rm -rf /var/lib/apt/lists/*  # tarde demais!
```

✅ **Certo** (1 layer, cache limpo na mesma):
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git && \
    rm -rf /var/lib/apt/lists/*
```

`--no-install-recommends` evita pacotes "sugeridos" que você não pediu (geralmente metade do que vem é supérfluo).

Equivalente no Alpine:
```dockerfile
RUN apk add --no-cache curl git
```
(`--no-cache` já evita o índice ficar na imagem.)

## 🪜 Ordem do Dockerfile (cache — recap do Módulo 6)

Coloque o que **muda menos** em cima, o que muda mais embaixo:

```dockerfile
FROM node:20-alpine
WORKDIR /app

# 1. package.json muda pouco → cache reaproveita npm install
COPY package*.json ./
RUN npm ci --omit=dev

# 2. código muda toda hora → vem por último
COPY . .

CMD ["node", "server.js"]
```

Sem essa ordem, qualquer mudança no código invalida o cache do `npm install` e você reinstala tudo de novo (1-3 minutos jogados fora).

## 🏗️ Multi-stage (recap do Módulo 8 + foco em tamanho)

Build separa de runtime. O `final` só leva o que precisa:

```dockerfile
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci  # com devDependencies, pra compilar
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev
CMD ["node", "dist/server.js"]
```

A imagem final **não tem** o código TypeScript, nem o `node_modules` de dev, nem caches do npm.

## 🔍 Ferramentas pra auditar

### `dive` — vê o que tem dentro de cada layer
```bash
dive minhaapp:latest
```
Mostra layer por layer: o que adicionou, tamanho, "wasted space" (arquivos que existem mas foram sobrescritos depois). Bom pra caçar gordura escondida.

### `docker scout` — vulnerabilidades
```bash
docker scout cves minhaapp:latest
docker scout quickview minhaapp:latest
```
Lista CVEs por severidade. Geralmente reduzir tamanho **já reduz CVEs** porque tem menos pacote vulnerável instalado.

### `docker history`
Rápido pra ver tamanho de cada layer:
```bash
docker history minhaapp:latest
```

### `docker images`
O básico, mostra o tamanho final:
```bash
docker images | grep minhaapp
```

## 💡 Checklist de otimização

- [ ] Base mínima viável (alpine ou distroless)
- [ ] `.dockerignore` excluindo `node_modules`, `.git`, `dist`, etc
- [ ] Multi-stage (build separado de runtime)
- [ ] `RUN` agrupados com `&&` e cleanup na mesma linha
- [ ] `--no-install-recommends` (apt) ou `--no-cache` (apk)
- [ ] Dependências antes do código pra cache funcionar
- [ ] `npm ci --omit=dev` em produção (não `npm install`)
- [ ] Sem secrets, sem `.env`, sem dumps na imagem
- [ ] Auditou com `dive` e `docker scout`

## 🚦 Próximos passos
1. Faça a **prática**: comparar Dockerfile gordo vs otimizado, ver `docker images`
2. Faça o **desafio**: pegar um Dockerfile inflado e reduzir 80%
3. Vá pro Módulo 15 — onde a gente fala de segurança a sério

## ✅ Auto-verificação
- [ ] Sei diferenciar alpine, distroless e scratch
- [ ] Sei o que vai no `.dockerignore` típico
- [ ] Sei por que `RUN apt update && apt install && rm` numa linha só importa
- [ ] Consegui reduzir uma imagem em ≥80%
- [ ] Conheço `dive` e `docker scout`

Próximo módulo: **Segurança** — não rodar como root, secrets, scan de vulnerabilidades.
