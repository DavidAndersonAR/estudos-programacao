# =============================================================================
# 🎯 DESAFIO — Dockerfile de DEV pra transformar em PROD
#
# Cada TODO aponta um item do CHECKLIST.md (C1..C9, S1..S4, R1..R3).
# Sua missão: reescrever este Dockerfile cumprindo TODOS os itens.
# A solução de referência está no FIM do arquivo, entre /* ... */.
# =============================================================================

# TODO C1 — versão fixa do FROM (não latest)
# TODO C2 — base mínima (alpine?)
# TODO C3 — multi-stage (build em um stage, runtime em outro)
FROM node:latest

# TODO C4 — definir WORKDIR
# (atualmente roda no / — sujeira misturada com /bin, /etc, etc)

# TODO C9 — garantir .dockerignore na raiz cobrindo .git, node_modules, .env, dist
# TODO C5 — copiar manifest ANTES do código fonte
COPY . /app
WORKDIR /app

# TODO C6 — usar npm ci (determinístico) em vez de npm install
# TODO C8 — só dependências de produção (--omit=dev)
# TODO C7 — limpar cache do npm na mesma camada
RUN npm install

# TODO S2 — secret hardcoded (NUNCA fazer isso — vaza no docker history)
ENV DB_PASSWORD=supersecret123
ENV API_KEY=sk-prod-9f8a7b6c5d4e3f2a

# TODO R1 — adicionar HEALTHCHECK
# TODO R3 — adicionar tini como PID 1 (ENTRYPOINT)

# TODO S1 — criar usuário non-root e USER appuser
# (atualmente roda como root — qualquer RCE = host comprometido)

EXPOSE 3000

# TODO R2 — usar forma exec (JSON array), não shell
CMD npm start

# =============================================================================
# 💡 Dica: o Dockerfile da pasta ../pratica/ é seu gabarito vivo.
# Tente fazer sem olhar primeiro.
# =============================================================================


# =============================================================================
# ✅ SOLUÇÃO DE REFERÊNCIA (delete o FROM acima ao testar)
# =============================================================================
# /*
# # ---------- STAGE 1: build ----------
# FROM node:20.11.1-alpine3.19 AS build
# WORKDIR /app
#
# # C5: manifest primeiro pra cache funcionar
# COPY package.json package-lock.json ./
#
# # C6 + C7 + C8
# RUN npm ci --omit=dev --no-audit --no-fund && \
#     npm cache clean --force
#
# COPY . .
# RUN npm run build
#
# # ---------- STAGE 2: runtime ----------
# FROM node:20.11.1-alpine3.19 AS runtime
#
# # R3: tini como PID 1 (propaga SIGTERM, reapeia zumbis)
# RUN apk add --no-cache tini=~0.19 && rm -rf /var/cache/apk/*
#
# # S1: usuário non-root, UID alto
# RUN addgroup -g 10001 -S appgroup && \
#     adduser  -u 10001 -S appuser -G appgroup
#
# WORKDIR /app
#
# # S4: já copia com dono certo
# COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
# COPY --from=build --chown=appuser:appgroup /app/dist         ./dist
# COPY --from=build --chown=appuser:appgroup /app/package.json ./package.json
#
# # S2: SEM secret. Secret vem em runtime via docker secret / env do orquestrador.
# ENV NODE_ENV=production \
#     PORT=3000 \
#     LOG_LEVEL=info \
#     TZ=America/Sao_Paulo
#
# EXPOSE 3000
#
# # R1: healthcheck
# HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
#     CMD wget -qO- http://127.0.0.1:3000/health || exit 1
#
# # S1: rodar como non-root
# USER appuser
#
# # R3 + R2: tini no ENTRYPOINT, CMD em forma exec
# ENTRYPOINT ["/sbin/tini", "--"]
# CMD ["node", "dist/server.js"]
# */
