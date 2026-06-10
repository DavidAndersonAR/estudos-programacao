# 🎯 DESAFIO Módulo 17 — App que "morre" depois de N requests
#
# Cenário: você tem um app com bug que trava depois de 5 requisições.
# Sua missão: configurar healthcheck que detecta + restart policy que reanima.
#
# Arquivos:
#  - app.js     (já existe — não precisa mexer)
#  - Dockerfile (este aqui — COMPLETE os TODOs)
#  - docker-compose.yml (orquestra com healthcheck declarativo)
#
# Especificação:
#  - Imagem base: node:20-alpine
#  - Instalar curl pro healthcheck
#  - Copiar app.js
#  - Expor porta 3000
#  - HEALTHCHECK: interval 5s, timeout 2s, retries 2, start-period 3s
#    -> CMD bate em http://localhost:3000/health (que vai falhar depois de 5 requests)
#  - CMD: node app.js

FROM node:20-alpine

# TODO 1: instalar curl
# RUN ...

WORKDIR /app

# TODO 2: copiar app.js
# COPY ...

EXPOSE 3000

# TODO 3: HEALTHCHECK
# HEALTHCHECK --interval=... --timeout=... --start-period=... --retries=... \
#   CMD curl -f http://localhost:3000/health || exit 1

# TODO 4: CMD
# CMD [...]


# ============================
# SOLUÇÃO DE REFERÊNCIA — descomente pra rodar
# ============================
# RUN apk add --no-cache curl
# COPY app.js .
# HEALTHCHECK --interval=5s --timeout=2s --start-period=3s --retries=2 \
#   CMD curl -f http://localhost:3000/health || exit 1
# CMD ["node", "app.js"]
