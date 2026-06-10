# syntax=docker/dockerfile:1
# ^^^ Essa linha NÃO é comentário comum.
# Ela diz pro BuildKit "use a versão estável mais recente do frontend Dockerfile".
# Sem ela, --mount=type=cache e --mount=type=secret não funcionam.

# =====================================================
# Prática Módulo 20 — App Node simples mostrando:
#   1) RUN --mount=type=cache pra cachear o npm cache
#   2) RUN --mount=type=secret pra ler um token de build sem vazar
# =====================================================

FROM node:20-alpine AS builder

WORKDIR /app

# Copia só o manifest primeiro (pra aproveitar cache de camada do COPY)
COPY package*.json ./

# 🔥 CACHE MOUNT: /root/.npm é onde o npm guarda os pacotes baixados.
# Esse mount persiste ENTRE builds — então se você alterar package.json
# e refizer o build, npm ci não baixa tudo de novo da internet.
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline --no-audit || npm install --no-audit

# 🔐 SECRET MOUNT: o token só existe durante esse RUN, em /run/secrets/build_token.
# Não vai pra nenhuma camada, não aparece em docker history.
# Aqui só simulamos o uso — em produção seria um `npm config set //registry/:_authToken=$TOKEN`
# ou `git clone https://$TOKEN@...`.
RUN --mount=type=secret,id=build_token \
    if [ -f /run/secrets/build_token ]; then \
      echo "Token de build lido com sucesso (primeiros 4 chars):"; \
      head -c 4 /run/secrets/build_token; echo "..."; \
    else \
      echo "Sem token (tudo bem, é só demo)"; \
    fi

# Copia o resto do código
COPY . .

# =====================================================
# Stage final: imagem magra
# =====================================================
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app /app

# App simples só pra ter algo que rode
CMD ["node", "-e", "console.log('Hello from BuildKit! arch=' + process.arch + ' platform=' + process.platform)"]
