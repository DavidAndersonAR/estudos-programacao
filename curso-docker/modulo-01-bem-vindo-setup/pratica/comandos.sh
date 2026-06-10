#!/usr/bin/env bash
# Módulo 01 — Bem-vindo + Setup
# Prática: comandos básicos pra explorar o Docker
#
# Rode linha a linha (ou bash comandos.sh pra rodar tudo).
# Lembre que cada comando pode demorar alguns segundos.

set -e  # para se algum comando falhar

echo "=== Exercício 1: Versão e informações ==="
docker --version
docker info | head -20

echo ""
echo "=== Exercício 2: Primeiro container (hello-world) ==="
docker run hello-world

echo ""
echo "=== Exercício 3: Listar imagens locais ==="
docker images

echo ""
echo "=== Exercício 4: Listar containers (incluindo parados) ==="
docker ps -a | head -10

echo ""
echo "=== Exercício 5: Procurar imagens no registry ==="
# A CLI tem um comando 'search' (limitado), mas o Docker Hub é melhor pelo browser.
docker search --limit 3 redis

echo ""
echo "=== Exercício 6: Imagem oficial do Alpine (sistema Linux minimalista) ==="
# Alpine tem só 5MB! Vamos rodar e ver versão dele.
docker run --rm alpine cat /etc/os-release
# --rm = remove o container assim que termina (não fica sujeira)

echo ""
echo "=== Exercício 7: Limpar containers parados ==="
docker container prune -f  # remove TODOS os parados (cuidado em prod!)

echo ""
echo "=== Pronto! ==="
echo "Containers rodando agora:"
docker ps
