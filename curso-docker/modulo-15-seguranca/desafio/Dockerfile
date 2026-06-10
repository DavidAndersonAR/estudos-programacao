# 🎯 DESAFIO DO MÓDULO 15 — Hardening de Imagem
#
# Contexto:
# Você herdou esse Dockerfile padrão de uma API Node.js. Funciona, mas é um desastre
# de segurança. Sua missão: aplicar TODO o checklist do Módulo 15.
#
# Objetivo:
# Refatorar este Dockerfile aplicando:
#  1. Imagem base mínima (slim ou alpine) com tag fixa (nunca latest)
#  2. Multi-stage build (build deps NÃO vão pra imagem final)
#  3. Criar usuário non-root (appuser, UID 1000)
#  4. Copiar arquivos com --chown
#  5. USER appuser antes do CMD
#  6. SEM secrets em ENV/ARG (eles vêm em runtime)
#  7. Sem curl/wget/sudo na imagem final
#  8. HEALTHCHECK
#  9. Documentar (comentário # WHY:) cada decisão de hardening
#
# Pra rodar o desafio do jeito certo (veja comandos.sh) você vai usar:
#  --read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges
#
# ============================
# 👇 DOCKERFILE ATUAL (RUIM) — REESCREVA ABAIXO
# ============================
#
# FROM node:20
# WORKDIR /app
# COPY . .
# RUN apt-get update && apt-get install -y curl sudo
# RUN npm install
# ENV DB_PASSWORD=admin123
# ENV JWT_SECRET=meu-segredo-super-secreto
# EXPOSE 3000
# CMD ["node", "server.js"]
#
# ============================
# ✍️  SUA SOLUÇÃO ABAIXO
# ============================

# TODO 1: estágio de build — use uma imagem com node + tag fixa
# FROM ???  AS build
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci --only=production


# TODO 2: estágio final — use a imagem MAIS MÍNIMA possível
# FROM ???
# WORKDIR /app


# TODO 3: criar usuário non-root


# TODO 4: copiar node_modules do estágio build + código com --chown


# TODO 5: trocar pra USER non-root


# TODO 6: HEALTHCHECK batendo num endpoint real


# TODO 7: EXPOSE + CMD (lembre: node listen em porta >1024 não precisa de CAP_NET_BIND_SERVICE)


# ============================
# 💡 SOLUÇÃO DE REFERÊNCIA (descomente pra comparar)
# ============================
#
# # ----- ESTÁGIO 1: build -----
# # WHY: node:20-alpine é tag fixa (não latest) e MUITO menor que node:20.
# FROM node:20.18-alpine AS build
# WORKDIR /app
# # WHY: copiar só package*.json primeiro maximiza cache de layers.
# COPY package*.json ./
# # WHY: npm ci é determinístico e bem mais rápido em CI; --omit=dev tira devDeps.
# RUN npm ci --omit=dev
#
# # ----- ESTÁGIO 2: runtime -----
# # WHY: alpine continua minúsculo; sem ferramentas de build na imagem final.
# FROM node:20.18-alpine
#
# # WHY: dumb-init resolve PID 1 / sinais corretamente em containers Node.
# RUN apk add --no-cache dumb-init
#
# # WHY: usuário non-root é a defesa nº 1. UID/GID fixos facilitam volumes.
# RUN addgroup -S -g 1000 appgroup && \
#     adduser  -S -u 1000 -G appgroup appuser
#
# WORKDIR /app
#
# # WHY: copia já com ownership correto. Sem chown no RUN depois (gera layer pesada).
# COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
# COPY --chown=appuser:appgroup . .
#
# # WHY: secrets NUNCA em ENV/ARG. Vão entrar via docker secret / env_file no runtime.
# # (NÃO declare DB_PASSWORD aqui!)
#
# # WHY: troca de usuário ANTES do CMD. A partir daqui nada roda como root.
# USER appuser
#
# # WHY: porta 3000 é >1024 → não precisa de CAP_NET_BIND_SERVICE em runtime.
# EXPOSE 3000
#
# # WHY: healthcheck simples. Em prod, troque pelo endpoint real /healthz.
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#   CMD wget -qO- http://localhost:3000/healthz || exit 1
# # ⚠️  Atenção: o healthcheck acima usa wget. Alpine já vem com wget (busybox).
# #     Se for distroless, troque por: CMD node -e "fetch('http://localhost:3000/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
#
# # WHY: dumb-init como PID 1 garante encerramento limpo em SIGTERM.
# ENTRYPOINT ["dumb-init", "--"]
# CMD ["node", "server.js"]
#
# # ============================
# # CHECKLIST APLICADO:
# # [x] Base mínima + tag fixa (node:20.18-alpine)
# # [x] Multi-stage (build deps fora da imagem final)
# # [x] Usuário non-root (appuser UID 1000)
# # [x] COPY --chown (sem chown extra)
# # [x] USER antes do CMD
# # [x] SEM secrets em ENV/ARG
# # [x] Sem curl/sudo (só wget que já vem em alpine)
# # [x] HEALTHCHECK
# # [x] dumb-init pra sinal/PID 1
# # [x] WHY em cada decisão
# # ============================
