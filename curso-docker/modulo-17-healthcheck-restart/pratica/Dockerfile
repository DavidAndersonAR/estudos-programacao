# Módulo 17 — Prática: Healthcheck + Restart
# App Node.js minúsculo com endpoint /health
FROM node:20-alpine

# curl não vem no node:alpine — precisamos instalar
RUN apk add --no-cache curl

WORKDIR /app

# Sem package.json — usa só módulo http nativo
COPY app.js .

EXPOSE 3000

# HEALTHCHECK:
# - interval=10s: check rápido pra você ver mudar de estado na demo
# - timeout=3s:   se demorar mais de 3s, falha
# - retries=3:    3 falhas seguidas pra virar unhealthy
# - start-period=5s: nos primeiros 5s, falhas não contam (app subindo)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
