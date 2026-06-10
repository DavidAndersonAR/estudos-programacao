# Módulo 09 — Prática: variáveis de ambiente
#
# Imagem mínima pra demonstrar como passar e ler envs.
# Base alpine só pra ser leve.

FROM alpine:3.20

# ARG só vive durante o build. Default = 1.0.
# Sobrescreva com: docker build --build-arg APP_VERSION=2.0 ...
ARG APP_VERSION=1.0

# ENV vive em runtime (e tb durante o build).
# Truque útil: copiar ARG -> ENV pra que APP_VERSION continue acessível depois.
ENV APP_VERSION=$APP_VERSION

# Defaults da imagem. Quem rodar pode sobrescrever com -e ou --env-file.
ENV NOME=Mundo
ENV SAUDACAO=Olá

# Copia o script e dá permissão de execução.
COPY app.sh /app.sh
RUN chmod +x /app.sh

# Exec form chamando shell explicitamente — assim $VAR é expandido em runtime.
# Se usássemos CMD ["./app.sh"] direto, a expansão acontece DENTRO do script (que usa sh tb), o que tb funciona.
# Aqui mantemos simples.
CMD ["/app.sh"]
