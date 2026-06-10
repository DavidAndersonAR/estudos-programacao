#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 01 — Rodando 3 Imagens Diferentes
#
# Objetivo:
# Rode 3 imagens populares e observe o comportamento de cada uma.
#
# 1. nginx — servidor web. Roda em background mostrando logs no docker logs.
# 2. python:alpine — interpretador Python. Use pra rodar um print.
# 3. postgres:16 — banco. Precisa de senha via env var.
#
# Pra cada uma:
# - Use --rm pra não deixar sujeira (exceto onde precisa investigar)
# - Use -d (detached) quando for servidor de background
# - Use -p PORTA pra mapear porta
# - Use --name pra dar nome ao container
#
# 💡 Dicas:
#   - nginx escuta na 80. Pra acessar do seu PC, mapeie -p 8080:80 e abra http://localhost:8080
#   - python:alpine roda um comando que você passa: docker run --rm python:alpine python -c "print('oi')"
#   - postgres precisa de -e POSTGRES_PASSWORD=algo

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: rode nginx em background na porta 8080"
# nginx ...

echo "TODO: rode python imprimindo 'Olá Docker!'"
# python ...

echo "TODO: rode postgres em background com senha"
# postgres ...

# Verifique:
docker ps

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. nginx — servidor web em background
docker run -d --name meu-nginx -p 8080:80 nginx
# Abra http://localhost:8080 — deve mostrar a página default do nginx
# Veja os logs:
docker logs meu-nginx
# Para e remove:
# docker stop meu-nginx && docker rm meu-nginx

# 2. python:alpine — execução pontual com --rm
docker run --rm python:alpine python -c "print('Olá Docker!')"

# 3. postgres — banco em background
docker run -d --name meu-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=teste \
  -p 5433:5432 \
  postgres:16
# Espera uns 3s e cheque:
sleep 3
docker logs meu-postgres | tail -10
# Limpa depois:
# docker stop meu-postgres && docker rm meu-postgres
SOLUTION
