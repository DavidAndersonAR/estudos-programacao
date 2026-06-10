# Módulo 20 — BuildKit + buildx

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é **BuildKit** e por que ele substituiu o builder legacy
- Usar **cache mount** (`RUN --mount=type=cache`) pra acelerar builds de jeito absurdo
- Usar **secret mount** (`RUN --mount=type=secret`) pra passar token de build SEM vazar pra imagem
- Criar um builder **buildx** e fazer **build multi-platform** (amd64 + arm64)
- Mandar cache pra um **registry externo** (`--cache-to=type=registry`)

## 🧠 Onde a gente tá no curso
Já vimos `docker build` "normal" lá atrás (Módulo 06). Aquele build é o **builder legacy** — funcional, mas burro. Hoje todo build moderno passa por **BuildKit**, que muda a forma como cache, paralelismo e secrets funcionam. E quando você precisa **publicar uma imagem que rode tanto em Mac M1 (arm64) quanto em servidor x86 (amd64)**, entra o **buildx**.

---

## 1. O que é o BuildKit (e o que ele resolve)

**BuildKit** é a engine de build moderna do Docker. É o motor por baixo do `docker build` no Docker 23+ (default ligado). Antes era o **legacy builder**, que tinha alguns problemas:

| Legacy builder | BuildKit |
|---|---|
| Executa stages em sequência, mesmo se forem independentes | **Paraleliza** stages que não dependem entre si |
| Cache só por camada inteira | Cache **granular** (pode cachear pasta específica entre builds) |
| Secrets vazam pra imagem (era preciso fazer truques feios) | **`--mount=type=secret`** — secret existe SÓ durante o RUN, nunca vai pra imagem |
| Sem cache externo decente | Pode mandar cache pra **registry, S3, GHA cache**, etc |
| `COPY` lê o filesystem todo | Lê só o necessário pelo `.dockerignore` mais inteligente |

### Como ligar o BuildKit
No Docker 23+ já vem ligado. Em versões antigas:

```bash
# Linux/Mac:
export DOCKER_BUILDKIT=1
docker build .

# ou força por build:
DOCKER_BUILDKIT=1 docker build .
```

**Importante**: pra usar as features novas (`--mount`, etc) o Dockerfile precisa começar com a **diretiva de sintaxe**:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine
...
```

Essa linha **não é comentário comum**: ela diz pro BuildKit "usa a versão mais recente do frontend do Dockerfile". Sem ela, features novas dão erro.

---

## 2. Feature killer #1: `RUN --mount=type=cache`

Esse é o motivo pelo qual builds Go/Node/Python de projetos grandes ficam 10x mais rápidos.

### Problema sem cache mount
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install     # baixa 300MB do npm registry
COPY . .
RUN npm run build
```

Se `package.json` muda **uma vírgula**, o `RUN npm install` invalida o cache da camada e baixa tudo de novo. Doloroso.

### Com cache mount
```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci
COPY . .
RUN npm run build
```

Agora `/root/.npm` (cache do npm) **persiste entre builds**. Mudou `package.json`? OK, refaz `npm ci`, mas os pacotes vêm do cache local — não baixa da internet. Pode ir de **3 min pra 15s**.

### Onde isso brilha
- **Go**: `--mount=type=cache,target=/go/pkg/mod` (cache de módulos) e `--mount=type=cache,target=/root/.cache/go-build` (cache de compilação)
- **Python**: `--mount=type=cache,target=/root/.cache/pip`
- **apt**: `--mount=type=cache,target=/var/cache/apt`
- **Maven**: `--mount=type=cache,target=/root/.m2`

⚠️ **Cuidado**: cache mount **não vai pra imagem final** (não é uma camada). É só pra acelerar build. Não use pra guardar coisa que precisa estar em runtime.

---

## 3. Feature killer #2: `RUN --mount=type=secret`

Você precisa de um **token privado** durante o build (ex: clonar repo privado, baixar pacote de registry interno). O jeito errado:

```dockerfile
# 🚨 NÃO FAÇA ISSO
ARG GITHUB_TOKEN
RUN git clone https://$GITHUB_TOKEN@github.com/empresa/repo.git
```

O `ARG` fica na imagem final (visível com `docker history`). Ou seja, **seu token vaza pra qualquer um que baixar a imagem**.

### Jeito certo com BuildKit
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine
RUN --mount=type=secret,id=github_token \
    GH_TOKEN=$(cat /run/secrets/github_token) && \
    git clone https://$GH_TOKEN@github.com/empresa/repo.git
```

Build:
```bash
docker build \
  --secret id=github_token,src=$HOME/.github-token \
  -t minha-app .
```

O segredo:
- **Existe só durante aquele RUN**, montado em `/run/secrets/github_token`
- **Não vai pra nenhuma camada** da imagem
- **Não aparece** em `docker history` nem em `docker inspect`

Outras fontes: `env=NOME_DA_VAR` (lê do env do host).

---

## 4. Feature bônus: `RUN --mount=type=ssh`

Pra build que precisa fazer `git clone` por SSH de repo privado. Encaminha o `ssh-agent` do host pro container só durante aquele RUN.

```dockerfile
# syntax=docker/dockerfile:1
FROM alpine
RUN apk add --no-cache openssh-client git
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh git clone git@github.com:empresa/repo.git
```

Build:
```bash
docker build --ssh default -t app .
```

---

## 5. `docker buildx` — a CLI estendida

`buildx` é uma **CLI por cima do BuildKit** que adiciona superpoderes que o `docker build` puro não tem. Hoje no Docker Desktop ela já vem instalada.

### O que dá pra fazer
- **Build pra várias plataformas de uma vez só** (amd64 + arm64 + arm/v7 + ...)
- **Múltiplos builders** (cada um isolado, com seu cache próprio)
- **Cache externo** (registry, S3, GitHub Actions, local)
- **`--push` direto** (constrói e empurra pro registry em um comando)

### Conceito: builder
No legacy, "builder" era um detalhe interno. No buildx você cria builders explicitamente:

```bash
# Lista os builders
docker buildx ls

# Cria um builder novo, baseado em container (suporta multi-platform)
docker buildx create --name meu-builder --driver docker-container --use

# Inspeciona (mostra plataformas suportadas)
docker buildx inspect --bootstrap
```

O builder **default** (`docker`) **NÃO suporta multi-platform**. Precisa criar um `docker-container` ou usar emulação via QEMU.

---

## 6. Multi-platform: o motivo de o buildx existir

Cenário real: você tem um Mac M1 (arm64) mas seu servidor de produção é Linux x86 (amd64). Se você fizer `docker build` no Mac, vai gerar uma imagem **arm64 only** — que não roda no servidor.

### Build multi-platform
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t davidanderson/minha-app:1.0 \
  --push \
  .
```

O que acontece:
1. BuildKit constrói **duas imagens** em paralelo (uma pra cada arch)
2. Cria um **manifest list** apontando pras duas
3. Empurra tudo pro registry de uma vez

Quem baixar a imagem em arm64 pega a arm64. Quem baixar em amd64 pega a amd64. **Tudo com a mesma tag**.

⚠️ **Detalhe**: multi-platform build **só funciona com `--push` ou `--output`**. Não dá pra carregar duas arquiteturas no `docker images` local de uma vez (o daemon local só guarda uma). Se quiser só uma arch local, passa `--load`.

### Inspecionar manifest
```bash
docker buildx imagetools inspect davidanderson/minha-app:1.0
# mostra:
#   Manifests:
#     Platform: linux/amd64
#     Platform: linux/arm64
```

---

## 7. Cache externo (`--cache-to` / `--cache-from`)

Em CI/CD você quer **reusar cache entre builds** (cada job começa "limpo"). BuildKit pode mandar o cache pra um destino externo:

```bash
# Build mandando cache pra registry
docker buildx build \
  --cache-to type=registry,ref=davidanderson/minha-app:buildcache,mode=max \
  --cache-from type=registry,ref=davidanderson/minha-app:buildcache \
  -t davidanderson/minha-app:1.0 \
  --push .
```

Modos:
- `mode=min` (default): só cacheia a imagem final
- `mode=max`: cacheia TODAS as camadas intermediárias (recomendado em CI)

Outros tipos de cache: `type=local` (pasta no disco), `type=gha` (GitHub Actions cache), `type=s3`, `type=inline` (embute na própria imagem — mais simples mas menos eficiente).

---

## 8. Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `docker buildx ls` | Lista builders disponíveis |
| `docker buildx create --name X --driver docker-container --use` | Cria e usa um builder novo |
| `docker buildx use X` | Seleciona um builder |
| `docker buildx inspect --bootstrap` | Mostra plataformas suportadas |
| `docker buildx build --platform linux/amd64,linux/arm64 -t T --push .` | Build multi-platform e push |
| `docker buildx build --load -t T .` | Build e carrega na engine local (uma plataforma só) |
| `docker buildx imagetools inspect IMG` | Mostra manifest da imagem multi-arch |
| `docker buildx prune` | Limpa cache do builder |

---

## 9. Detalhes que economizam tempo
- **Sempre comece o Dockerfile com `# syntax=docker/dockerfile:1`** quando for usar features BuildKit. É a primeira linha, antes do `FROM`.
- **Cache mount NÃO substitui multi-stage build** — eles se combinam. Você ainda quer um stage builder pesado e um final magro.
- **Multi-platform via QEMU é lento** (emulação). Em CI sério, usa runners nativos pra cada arch e junta com `docker buildx imagetools create`.
- **`--push` faz duas coisas**: build + push em um comando. Sem ele, a imagem fica no builder e não na sua engine local — você precisa de `--load` (e aí perde multi-platform).
- **`docker history` mostra ARG mas não mostra `--mount=type=secret`** — é por isso que secret mount é seguro.
- **Cache de registry custa storage** no Docker Hub/ECR/etc. Não esqueça de limpar de vez em quando.

---

## 🚦 Próximos passos
1. Faça a prática — vai ver na carne o cache mount acelerando um `npm install`
2. Faça o desafio — build Go multi-platform com secret + cache, push pra registry local
3. No próximo módulo a gente fecha o curso com **Boas práticas + segurança em produção**

## ✅ Auto-verificação
- [ ] Sei dizer 3 vantagens do BuildKit sobre o legacy builder
- [ ] Sei o que faz `RUN --mount=type=cache` e quando usar
- [ ] Sei por que `--mount=type=secret` é mais seguro que `ARG TOKEN`
- [ ] Sei criar um builder buildx multi-platform
- [ ] Sei o que é um manifest list

Próximo módulo: **Boas práticas + segurança** — fechando o curso com chave de ouro.
