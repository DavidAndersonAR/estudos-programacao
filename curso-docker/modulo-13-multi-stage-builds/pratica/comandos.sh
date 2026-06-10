#!/usr/bin/env bash
# Módulo 13 — Prática: Multi-stage build com Go
#
# Vamos construir DUAS imagens da mesma app e comparar tamanhos:
#   1. servidor:gordo  — Dockerfile single-stage (~800MB)
#   2. servidor:enxuto — Dockerfile multi-stage  (~12MB)
#
# Rode dentro da pasta pratica/.

set -e

echo "=== Exercício 1: Build single-stage (versão GORDA) ==="
docker build -f Dockerfile.singlestage -t servidor:gordo .

echo ""
echo "=== Exercício 2: Build multi-stage (versão ENXUTA) ==="
docker build -f Dockerfile -t servidor:enxuto .

echo ""
echo "=== Exercício 3: Comparar tamanhos ==="
# A coluna SIZE mostra o tamanho da imagem.
docker images servidor

echo ""
echo "=== Exercício 4: Rodar a versão enxuta ==="
# -d  = background
# -p  = mapeia porta 8080 do host pra 8080 do container
# --rm = remove ao parar
docker run -d --rm --name servidor-enxuto -p 8080:8080 servidor:enxuto

# Espera 1s pra subir.
sleep 1

echo ""
echo "=== Exercício 5: Testar com curl ==="
curl -s http://localhost:8080/
echo "---"
curl -s http://localhost:8080/info
echo "---"
curl -s http://localhost:8080/health

echo ""
echo "=== Exercício 6: Inspecionar o conteúdo da imagem enxuta ==="
# A imagem scratch só tem o binário /servidor. Nada de shell, nada de ls.
# docker run --rm servidor:enxuto ls /   # ISSO FALHA — não existe `ls`.
# A forma de inspecionar é via histórico de camadas:
docker history servidor:enxuto

echo ""
echo "=== Exercício 7: Parar só até o stage builder (--target) ==="
# Útil pra debug — imagem fica com toolchain Go dentro.
docker build -f Dockerfile --target builder -t servidor:dev .
docker images servidor:dev
# Pra inspecionar:
# docker run --rm -it servidor:dev sh

echo ""
echo "=== Limpeza ==="
docker stop servidor-enxuto || true

echo ""
echo "=== Resumo ==="
docker images servidor
echo ""
echo "Repare: servidor:gordo tem ~800MB, servidor:enxuto tem ~12MB."
echo "Mesma aplicação. Multi-stage build = ~98% de redução."
