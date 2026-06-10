#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 04 — Build + run da imagem Flask
#
# Antes de rodar este script, preencha os TODOs do Dockerfile da pasta desafio/.
#
# Depois:
#   docker build -t meu-flask .
#   docker run -p 5000:5000 --rm meu-flask
# Acesse http://localhost:5000 — tem que aparecer "Olá Flask!".

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: build da imagem com tag meu-flask"
# docker build ...

echo "TODO: roda o container mapeando a porta 5000"
# docker run ...

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# --- Dockerfile pronto pra referência ---
#
# FROM python:3.12-alpine
# LABEL description="Servidor Flask minimalista — desafio Módulo 04"
# WORKDIR /app
# COPY app.py .
# RUN pip install --no-cache-dir flask
# EXPOSE 5000
# CMD ["python", "app.py"]
#
# Notas:
# - --no-cache-dir no pip evita guardar cache que só engorda a imagem
# - python:3.12-alpine é ~50MB; python:3.12 (debian) é ~1GB. Alpine vence aqui.
# - Flask 3+ funciona normal; não precisa fixar versão pra esse exercício

# --- Comandos ---

# 1. Build (a partir da pasta desafio/)
docker build -t meu-flask .

# 2. Inspeciona tamanho final da imagem
docker images meu-flask

# 3. Roda mapeando porta 5000
docker run -d --rm --name meu-flask-rodando -p 5000:5000 meu-flask

# 4. Testa o endpoint (espera 1s pro Flask subir)
sleep 1
curl -s http://localhost:5000

# 5. Logs
docker logs meu-flask-rodando

# 6. Para
docker stop meu-flask-rodando

# 💡 Experimentos:
# - Trocar python:3.12-alpine por python:3.12-slim e ver a diferença de tamanho
# - Sobrescrever o CMD: docker run --rm meu-flask python -c "print('outro')"
# - Acessar shell: docker run --rm -it meu-flask sh
SOLUTION
