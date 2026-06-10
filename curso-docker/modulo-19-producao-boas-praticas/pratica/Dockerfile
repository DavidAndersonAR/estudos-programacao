# =============================================================================
# Módulo 19 — Prática: Dockerfile production-grade (Node.js de exemplo)
# Cada bloco está comentado mostrando QUAL item do checklist está aplicando.
# =============================================================================

# -----------------------------------------------------------------------------
# STAGE 1 — build
# Checklist: [Build] multi-stage, versão fixa do FROM, base mínima (alpine)
# -----------------------------------------------------------------------------
FROM node:20.11.1-alpine3.19 AS build

# Checklist: [Build] diretório de trabalho explícito (evita rodar em /)
WORKDIR /app

# Checklist: [Build] camadas ordenadas — copia manifest ANTES do código.
# Assim, mudança no código NÃO invalida o cache do npm install.
COPY package.json package-lock.json ./

# Checklist: [Build] install determinístico via lock file + sem cache no disco
# `npm ci` exige lock e é mais rápido/reprodutível que `npm install`.
RUN npm ci --omit=dev --no-audit --no-fund && \
    npm cache clean --force

# Agora sim copia o resto do código (camada que muda toda hora).
COPY . .

# Build do app (transpile, bundle, etc.). Exemplo genérico:
RUN npm run build

# -----------------------------------------------------------------------------
# STAGE 2 — runtime
# Checklist: [Build] base mínima + versão fixa
#             [Segurança] USER non-root
#             [Runtime] tini como PID 1
# -----------------------------------------------------------------------------
FROM node:20.11.1-alpine3.19 AS runtime

# Checklist: [Runtime] PID 1 que reapeia zumbis e propaga SIGTERM corretamente.
# Sem isso, `docker stop` espera 10s e mata na marra (SIGKILL).
RUN apk add --no-cache tini=~0.19 && \
    rm -rf /var/cache/apk/*

# Checklist: [Segurança] usuário não-root com UID alto (evita colisão com hosts).
# -S = system user, -G = grupo, -u = UID fixo (importante pra volumes/permissões).
RUN addgroup -g 10001 -S appgroup && \
    adduser  -u 10001 -S appuser -G appgroup

WORKDIR /app

# Copia só o necessário do stage de build.
# Checklist: [Segurança] dono = appuser (sem precisar de chown -R depois).
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist         ./dist
COPY --from=build --chown=appuser:appgroup /app/package.json ./package.json

# Checklist: [Runtime] variáveis previsíveis em prod
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info \
    TZ=America/Sao_Paulo

EXPOSE 3000

# Checklist: [Runtime] healthcheck — orquestrador usa pra decidir restart.
# OBS: em K8s o healthcheck é definido no manifesto; aqui serve pra docker run/compose.
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# Checklist: [Segurança] roda como non-root
USER appuser

# Checklist: [Runtime] ENTRYPOINT = tini (PID 1 correto)
#            CMD em forma exec (sem shell intermediário sequestrando SIGTERM)
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/server.js"]

# =============================================================================
# O que falta (fora do Dockerfile, mas faz parte do checklist):
#   - .dockerignore na raiz descartando node_modules/, .git/, *.env, dist/ local
#   - Scan de vulnerabilidades no CI:    docker scout cves <imagem>
#   - Tag imutável no push:              ghcr.io/org/app:<commit-sha>
#   - Secrets via Docker Secrets ou env do orquestrador, NUNCA ENV API_KEY=...
# =============================================================================
