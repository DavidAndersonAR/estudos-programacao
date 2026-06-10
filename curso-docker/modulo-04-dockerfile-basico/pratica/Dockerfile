# Módulo 04 — Prática: Imagem Node.js simples
# Servidor HTTP que responde "Olá Docker!" na porta 3000.

# Imagem base: Node LTS rodando em Alpine (Linux minimalista, ~5MB)
FROM node:lts-alpine

# Metadata da imagem (opcional, mas boa prática)
LABEL maintainer="estudo-docker@exemplo.com"
LABEL description="Servidor HTTP simples em Node puro para o Módulo 04"

# Diretório de trabalho dentro do container
WORKDIR /app

# Copia o código pra dentro da imagem
# (sem package.json porque o app não usa nenhuma dep externa)
COPY app.js .

# Documenta que o app escuta na porta 3000 (não publica! use -p no run)
EXPOSE 3000

# Comando default ao rodar o container — forma exec (JSON array)
CMD ["node", "app.js"]
