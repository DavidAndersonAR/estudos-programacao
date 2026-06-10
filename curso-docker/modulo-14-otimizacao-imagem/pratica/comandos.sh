#!/usr/bin/env bash
# Módulo 14 — Otimização de Imagem
# Prática: comparar Dockerfile gordo vs otimizado.
#
# Rode passo a passo (ou bash comandos.sh pra tudo de uma vez).
# Atenção: o build do gordo demora MUITO (baixa quase 1GB de base + apt).

set -e

echo "=== Build da imagem GORDA ==="
docker build -f Dockerfile.grande -t modulo14-grande:latest .

echo ""
echo "=== Build da imagem OTIMIZADA ==="
docker build -f Dockerfile.otimizado -t modulo14-otimizado:latest .

echo ""
echo "=== Comparando tamanhos ==="
docker images | grep -E "REPOSITORY|modulo14-"
# Esperado:
# modulo14-grande     latest   ~1.3GB
# modulo14-otimizado  latest   ~150MB
# Redução típica: 85-90%

echo ""
echo "=== Inspecionando layers da gorda (top 10) ==="
docker history modulo14-grande:latest --no-trunc | head -15

echo ""
echo "=== Inspecionando layers da otimizada ==="
docker history modulo14-otimizado:latest --no-trunc | head -15

echo ""
echo "=== Rodando a otimizada pra confirmar que funciona ==="
docker run -d --name pratica14 -p 3000:3000 modulo14-otimizado:latest
sleep 2
echo "Testando endpoint:"
curl -s http://localhost:3000 && echo ""

echo ""
echo "=== Limpeza ==="
docker stop pratica14
docker rm pratica14
# Descomente pra remover as imagens também:
# docker rmi modulo14-grande:latest modulo14-otimizado:latest

echo ""
echo "=== Bônus: se tiver dive instalado, explore a gorda ==="
echo "  dive modulo14-grande:latest"
echo ""
echo "=== Bônus: scan de vulnerabilidades ==="
echo "  docker scout quickview modulo14-grande:latest"
echo "  docker scout quickview modulo14-otimizado:latest"
