# 🎯 DESAFIO DO MÓDULO 13 — Multi-stage build Node + nginx
#
# Contexto:
# Você tem uma SPA (Single Page Application) "fake" feita em Node.
# O script `npm run build` gera uma pasta dist/ com index.html.
#
# Objetivo:
# Crie um Dockerfile com DOIS stages:
#   1. build  — usa node:alpine, instala deps com `npm ci`, roda `npm run build`.
#   2. runtime — usa nginx:alpine, copia a pasta dist/ pro diretório que o nginx serve.
#
# A imagem final NÃO pode ter Node, npm nem node_modules. Só nginx + estáticos.
# Tamanho esperado: ~25MB.
#
# 💡 Dicas:
#   - nginx serve por padrão o conteúdo de /usr/share/nginx/html
#   - npm ci é igual ao npm install mas mais rápido e estrito (usa o package-lock.json)
#   - copie package.json ANTES do código pra aproveitar cache (Módulo 06)
#   - use COPY --from=NOMEDOSTAGE pra trazer a pasta dist/
#
# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

# TODO Stage 1: comece um stage chamado "build" usando node:20-alpine
# FROM ...

# TODO: defina WORKDIR /app

# TODO: copie package.json (e package-lock.json se existir)
# COPY ...

# TODO: instale dependências
# RUN ...

# TODO: copie o resto do código
# COPY ...

# TODO: rode o build (npm run build) — gera /app/dist
# RUN ...


# TODO Stage 2: comece outro stage usando nginx:alpine
# FROM ...

# TODO: copie a pasta dist/ do stage "build" pra /usr/share/nginx/html
# COPY --from=...

# TODO: documente a porta 80
# EXPOSE ...

# (nginx já tem CMD default, não precisa redefinir)


# ============================
# SOLUÇÃO DE REFERÊNCIA
# ============================
# Descomente o bloco abaixo se quiser ver/usar a solução pronta.
# (E comente os TODOs acima se for usar.)

# # --- Stage 1: build ---
# FROM node:20-alpine AS build
# WORKDIR /app
#
# # Copia manifest primeiro pra cache de deps funcionar (Módulo 06).
# COPY package*.json ./
#
# # npm ci é a versão "limpa" do install — ideal pra CI/Docker.
# # Nossa app não tem deps externas, mas o comando ainda valida o package.json.
# RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev
#
# # Agora o resto do código.
# COPY . .
#
# # Gera a pasta /app/dist
# RUN npm run build
#
# # --- Stage 2: runtime ---
# FROM nginx:alpine
#
# # Traz só os arquivos estáticos. Nada de Node, nada de node_modules.
# COPY --from=build /app/dist /usr/share/nginx/html
#
# EXPOSE 80
# # CMD já vem do nginx:alpine: ["nginx", "-g", "daemon off;"]
