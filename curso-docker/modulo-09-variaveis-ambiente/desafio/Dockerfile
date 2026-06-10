# 🎯 DESAFIO — Config 12-factor para uma app
#
# A app aceita 4 variáveis de ambiente. Cada uma tem um default sensato definido aqui.
# Seu trabalho (em comandos.sh): rodar com --env-file mudando o ambiente sem rebuildar.

FROM alpine:3.20

# === Config 12-factor: defaults vão no ENV, ajustes via env no run ===
ENV LOG_LEVEL=info
ENV PORT=8080
ENV DB_HOST=localhost
ENV FEATURE_FLAG=false

COPY app.sh /app.sh
RUN chmod +x /app.sh

# Exec form — recebe sinais corretamente.
CMD ["/app.sh"]
