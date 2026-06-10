# Módulo 06 — Camadas e Cache

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é uma **camada** (layer) de imagem e por que isso importa
- Entender como o Docker **reusa cache** entre builds
- Ordenar instruções do Dockerfile da forma certa pra build ficar **rápido**
- Usar `docker history` pra inspecionar camadas
- Forçar build sem cache quando precisar (`--no-cache`)
- Acelerar build em **10x** só mexendo na ordem das instruções

## 🧅 Imagem é uma cebola: camadas empilhadas

Toda imagem Docker é feita de **camadas (layers) read-only empilhadas**. Cada instrução do Dockerfile que **modifica o filesystem** (`FROM`, `RUN`, `COPY`, `ADD`) cria uma nova camada por cima da anterior.

```
┌─────────────────────────┐
│  CMD ["node","app.js"]  │ ← camada (metadado, 0 B)
├─────────────────────────┤
│  COPY . .               │ ← camada (seu código)
├─────────────────────────┤
│  RUN npm install        │ ← camada (node_modules)
├─────────────────────────┤
│  COPY package*.json .   │ ← camada (manifestos)
├─────────────────────────┤
│  FROM node:20-alpine    │ ← camada base (Linux + Node)
└─────────────────────────┘
```

Quando o container roda, o Docker monta uma camada **read-write** no topo de tudo (Módulo 07 — Volumes).

## 💾 Cache de build: o coração da velocidade

Quando você roda `docker build`, pra cada instrução o Docker faz a pergunta:

> "Já existe uma camada cacheada para essa instrução, com **exatamente os mesmos inputs**?"

- **Sim** → reaproveita a camada antiga (instantâneo, segundos viram milissegundos).
- **Não** → executa a instrução, gera nova camada, e **invalida todas as camadas seguintes** (cascata).

Os "inputs" considerados:
- A instrução em si (texto do `RUN`, `COPY`, etc.)
- A camada anterior (parent)
- Pra `COPY`/`ADD`: o **conteúdo** dos arquivos copiados (hash do conteúdo, não data de modificação)

## 📐 A regra de ouro: ordene do menos volátil pro mais volátil

Coloque no Dockerfile, **de cima pra baixo**:

1. `FROM` — imagem base (muda quase nunca)
2. Configs do sistema (`RUN apt-get install ...`) — mudam raramente
3. Dependências da aplicação (`COPY package.json` + `RUN npm install`) — mudam às vezes
4. **Código-fonte** (`COPY . .`) — muda toda hora
5. `CMD` / `ENTRYPOINT` — metadados, no fim

Por quê? Porque qualquer mudança em uma camada **invalida todas as camadas seguintes**. Se você puser `COPY . .` antes de `RUN npm install`, qualquer `console.log` que você adicionar no código vai forçar o `npm install` rodar **de novo**. Em projeto Node grande isso é a diferença entre **2 segundos** e **2 minutos** por build.

## 🎯 O truque mais importante: separar deps do código

### ❌ Jeito errado (Dockerfile.ruim)

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .                  # copia TUDO (código + package.json juntos)
RUN npm install           # toda vez que código muda, reinstala deps 😱
CMD ["node", "app.js"]
```

Problema: mudei uma vírgula no `app.js` → o `COPY . .` muda → cache invalida → `npm install` roda de novo.

### ✅ Jeito certo (Dockerfile.bom)

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./     # copia SÓ os manifestos primeiro
RUN npm install           # cacheado enquanto package.json não mudar 🎉
COPY . .                  # depois copia o resto
CMD ["node", "app.js"]
```

Agora, mudar `app.js` só invalida o `COPY . .` (instantâneo). O `npm install` continua cacheado até você mexer em `package.json` ou `package-lock.json`.

Isso vale pra **qualquer** linguagem:
- Python: `COPY requirements.txt` antes de `COPY .`
- Go: `COPY go.mod go.sum` antes de `COPY .`
- Rust: `COPY Cargo.toml Cargo.lock` antes de `COPY .`
- PHP: `COPY composer.json` antes de `COPY .`

## 🌊 Invalidação em cascata: o efeito dominó

Se a camada N invalida, **N+1, N+2, ... até o fim** também invalidam. Por isso:

- Toda instrução `RUN` pesada (compila, instala) deve vir o **mais cedo possível** no Dockerfile.
- Toda instrução que muda toda hora (seu código) deve vir o **mais tarde possível**.

Pense assim: o topo do Dockerfile é o "**fundamento da casa**" (concreto, não mexe), o final é "**a decoração**" (muda direto).

## 🔍 Inspecionando camadas: `docker history`

```bash
docker history minha-imagem
```

Mostra cada camada, tamanho e a instrução que a criou. Ótimo pra detectar:
- Camadas gigantes (esquecer de limpar cache de pacotes)
- Camadas duplicadas (refazendo o que já estava feito)
- Onde tá o peso da imagem

Quer mais detalhe? `docker history --no-trunc minha-imagem`.

## 🧨 Forçando rebuild sem cache

Às vezes você QUER ignorar o cache (suspeita de bug, mudança em base remota, etc.):

```bash
docker build --no-cache -t minha-imagem .
```

Roda tudo do zero. Útil em CI ocasional, **não** no dia a dia (lento).

Pra invalidar **uma camada específica** sem usar `--no-cache`, basta mudar qualquer coisa antes dela (até um comentário no Dockerfile).

## 🚦 Ordem prática recomendada (template mental)

```dockerfile
# 1. Base
FROM node:20-alpine

# 2. Configs/deps de sistema (se precisar)
RUN apk add --no-cache git

# 3. Workdir
WORKDIR /app

# 4. Deps da app: copia manifestos e instala
COPY package*.json ./
RUN npm ci --only=production

# 5. Código (por último!)
COPY . .

# 6. Metadados
EXPOSE 3000
CMD ["node", "app.js"]
```

## 💡 Detalhes que economizam tempo

- **Use `.dockerignore`** — evita copiar `node_modules`, `.git`, logs etc. (invalidam cache à toa).
- **Junte `RUN`s relacionados com `&&`**: cada `RUN` cria uma camada. `RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*` é uma camada só, e fica menor.
- **Pin de versões nas deps de sistema**: `apt-get install -y curl=7.88.*` deixa o cache estável e reprodutível.
- **`COPY` específico é melhor que `COPY .`**: copie só o que precisa naquela etapa (separe camadas por "domínio").
- **`npm ci` > `npm install` em build**: mais rápido e respeita o lockfile (cache mais previsível).
- **BuildKit** (Docker moderno já usa) tem cache ainda melhor — `RUN --mount=type=cache` salva caches entre builds. Avançado, fica pra depois.

## 🚦 Próximos passos
1. Faça a prática: build do `Dockerfile.ruim`, mude `app.js`, rebuild, cronometre
2. Compare com o `Dockerfile.bom` (mesma mudança, mesma cronometragem)
3. Rode `docker history` nas duas imagens e veja a diferença
4. Faça o desafio: refatorar um Dockerfile mal ordenado
5. Vá pro Módulo 07 — **Volumes e Persistência**

## ✅ Auto-verificação
- [ ] Sei o que é uma camada e por que cada instrução vira uma
- [ ] Sei a regra "menos volátil em cima, mais volátil embaixo"
- [ ] Sei o truque `COPY package.json` → `RUN npm install` → `COPY . .`
- [ ] Sei usar `docker history` pra inspecionar
- [ ] Sei quando usar `--no-cache`

Resumo: imagens são bolos de camadas, e o Docker é preguiçoso (do bom) — ele só refaz o que mudou. **Você** controla o quanto ele consegue ser preguiçoso, escolhendo a ordem das instruções. Ordem certa = build 10x mais rápido. Próximo módulo: **Volumes e Persistência** — onde os dados sobrevivem.
