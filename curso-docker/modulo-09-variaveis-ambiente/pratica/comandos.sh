#!/usr/bin/env bash
# Módulo 09 — Prática: variáveis de ambiente
# Demonstra as 3 formas (ENV default, -e e --env-file) + ARG no build.
#
# Rode linha a linha (ou bash comandos.sh).

set -e

cd "$(dirname "$0")"  # garante que estamos no diretório do Dockerfile

echo "=== Passo 0: copia o .env.example pra .env (se não existir) ==="
[ -f .env ] || cp .env.example .env
cat .env

echo ""
echo "=== Passo 1: build da imagem (sem build-arg, APP_VERSION fica 1.0) ==="
docker build -t mod09-pratica .

echo ""
echo "=== Passo 2: run SEM env — usa os defaults do ENV (Olá, Mundo!) ==="
docker run --rm mod09-pratica

echo ""
echo "=== Passo 3: run com -e SAUDACAO=Oi — sobrescreve só SAUDACAO ==="
# NOME continua = Mundo (default), SAUDACAO vira "Oi"
docker run --rm -e SAUDACAO=Oi mod09-pratica

echo ""
echo "=== Passo 4: run com --env-file .env (NOME e SAUDACAO vêm do arquivo) ==="
docker run --rm --env-file .env mod09-pratica

echo ""
echo "=== Passo 5: -e SOBRESCREVE --env-file (precedência) ==="
# .env diz NOME=David, mas -e NOME=Ana ganha
docker run --rm --env-file .env -e NOME=Ana mod09-pratica

echo ""
echo "=== Passo 6: build com --build-arg APP_VERSION=2.5 ==="
docker build --build-arg APP_VERSION=2.5 -t mod09-pratica:v2 .
docker run --rm mod09-pratica:v2
# Note: APP_VERSION aparece em runtime porque o Dockerfile faz ENV APP_VERSION=$APP_VERSION

echo ""
echo "=== Passo 7: inspecionar envs (Spoiler: aparecem clarinhas — não bote segredo!) ==="
docker run -d --name mod09-insp mod09-pratica
docker inspect mod09-insp --format '{{range .Config.Env}}{{println .}}{{end}}'
docker rm -f mod09-insp

echo ""
echo "=== Pronto! Limpa: ==="
echo "docker rmi mod09-pratica mod09-pratica:v2"
