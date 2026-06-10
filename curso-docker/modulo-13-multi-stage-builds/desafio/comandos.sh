#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 13 — Multi-stage build Node + nginx
#
# Antes de rodar:
#   1. Abra o Dockerfile, complete os TODOs (ou descomente a solução de referência).
#   2. Volte aqui e execute este script.
#
# Rode dentro da pasta desafio/.

set -e

echo "=== Passo 1: Build da imagem multi-stage ==="
docker build -t spa-fake:enxuto .

echo ""
echo "=== Passo 2: Tamanho da imagem final ==="
docker images spa-fake:enxuto
# Esperado: ~25MB. Se aparecer 200MB+, o stage de runtime provavelmente
# está usando node:alpine em vez de nginx:alpine — revise seu Dockerfile.

echo ""
echo "=== Passo 3: Subir o container ==="
docker run -d --rm --name spa-fake -p 8081:80 spa-fake:enxuto

sleep 1

echo ""
echo "=== Passo 4: Testar ==="
echo "Abra http://localhost:8081 no navegador, ou:"
curl -s http://localhost:8081/ | head -20

echo ""
echo "=== Passo 5: Confirmar que NÃO tem Node dentro ==="
# Se o stage final é nginx:alpine, não tem node nem npm.
# (Roda em shell sh — nginx:alpine tem.)
docker exec spa-fake sh -c "which node || echo 'sem node — perfeito!'"
docker exec spa-fake sh -c "ls /usr/share/nginx/html"

echo ""
echo "=== Passo 6: (Bônus) Construir só o stage de build com --target ==="
docker build --target build -t spa-fake:build .
docker images spa-fake
# Repare: spa-fake:build tem ~150MB (carrega Node);
#         spa-fake:enxuto tem ~25MB (só nginx + estáticos).

echo ""
echo "=== Limpeza ==="
docker stop spa-fake || true

echo ""
echo "=== Critério de sucesso ==="
echo " - Imagem spa-fake:enxuto < 50MB"
echo " - http://localhost:8081 mostra a página gerada no build"
echo " - 'which node' dentro do container falha (não tem Node)"
