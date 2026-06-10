#!/usr/bin/env bash
# Módulo 16 — Private Registry
# Prática: subir um registry local, publicar imagem e inspecionar via API
#
# Rode linha a linha (recomendado). Cada bloco tem o "porquê".

set -e

echo "=== Exercício 1: Subir o registry oficial localmente ==="
# A imagem "registry:2" é o registry de referência da Docker.
# -p 5000:5000 expõe a porta padrão.
docker run -d -p 5000:5000 --name registry-local registry:2
sleep 2
docker ps --filter name=registry-local

echo ""
echo "=== Exercício 2: Puxar uma imagem qualquer pra usar de cobaia ==="
docker pull alpine:3.20

echo ""
echo "=== Exercício 3: Retag apontando pro registry local ==="
# Formato: REGISTRY/IMAGEM:TAG
docker tag alpine:3.20 localhost:5000/minha-app:v1
docker images | grep -E "alpine|minha-app"

echo ""
echo "=== Exercício 4: Push pro registry local ==="
docker push localhost:5000/minha-app:v1

echo ""
echo "=== Exercício 5: Inspecionar via API HTTP do registry ==="
# Lista de repositórios:
curl -s http://localhost:5000/v2/_catalog
echo ""
# Tags da nossa imagem:
curl -s http://localhost:5000/v2/minha-app/tags/list
echo ""

echo ""
echo "=== Exercício 6: Apagar local e puxar do registry pra provar que funciona ==="
docker rmi localhost:5000/minha-app:v1
docker rmi alpine:3.20 || true
docker pull localhost:5000/minha-app:v1
docker images | grep minha-app

echo ""
echo "=== Exercício 7: Subir uma segunda versão (pra ver tags múltiplas) ==="
docker tag localhost:5000/minha-app:v1 localhost:5000/minha-app:v2
docker push localhost:5000/minha-app:v2
curl -s http://localhost:5000/v2/minha-app/tags/list
echo ""

echo ""
echo "=== Exercício 8: Fluxo ghcr.io (NÃO roda — só pra leitura) ==="
# Substitua SEU_USUARIO e gere um PAT no GitHub (Settings > Developer settings >
# Personal access tokens > Tokens classic) com escopo: write:packages, read:packages.
#
# export CR_PAT=ghp_xxxxxxxxxxxxxxxxxxxx
# echo $CR_PAT | docker login ghcr.io -u SEU_USUARIO --password-stdin
# docker tag minha-app:v1 ghcr.io/SEU_USUARIO/minha-app:v1
# docker push ghcr.io/SEU_USUARIO/minha-app:v1
# docker logout ghcr.io
echo "(bloco apenas documental — veja o script)"

echo ""
echo "=== Exercício 9: Limpeza ==="
docker stop registry-local
docker rm registry-local
# Atenção: parar o container NÃO apaga as imagens publicadas se você usou volume.
# Como subimos sem -v, os blobs morrem junto com o container — perfeito pra teste.

echo ""
echo "=== Pronto! ==="
echo "Você acabou de operar um registry inteiro. Bora pro desafio."
