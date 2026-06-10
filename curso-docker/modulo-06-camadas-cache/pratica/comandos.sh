#!/usr/bin/env bash
# Módulo 06 — Camadas e Cache
# Prática: provar na prática que ordem de instruções acelera build em 10x.
#
# Rode linha a linha (ou bash comandos.sh pra rodar tudo).
# Você vai cronometrar 4 builds e comparar.

set -e
cd "$(dirname "$0")"

echo "=== Exercício 1: Build INICIAL do Dockerfile.ruim (cache vazio) ==="
# --no-cache garante que estamos começando do zero pra comparar honesto.
time docker build --no-cache -f Dockerfile.ruim -t demo-ruim:v1 .

echo ""
echo "=== Exercício 2: Build INICIAL do Dockerfile.bom (cache vazio) ==="
time docker build --no-cache -f Dockerfile.bom -t demo-bom:v1 .

echo ""
echo "=== Exercício 3: Simular mudança no código (NÃO no package.json) ==="
# Acrescenta um comentário no app.js — mudança mínima, simula edição real.
echo "// editado em $(date)" >> app.js

echo ""
echo "=== Exercício 4: Rebuild do RUIM após mudar app.js ==="
# Vai rodar 'npm install' de novo (lento) porque COPY . . invalidou.
time docker build -f Dockerfile.ruim -t demo-ruim:v2 .

echo ""
echo "=== Exercício 5: Rebuild do BOM após mudar app.js ==="
# Vai usar cache até a camada de npm install. Só refaz COPY . . (rápido).
time docker build -f Dockerfile.bom -t demo-bom:v2 .

echo ""
echo "=== Exercício 6: Inspecionar camadas com docker history ==="
echo "--- Camadas do RUIM ---"
docker history demo-ruim:v2
echo ""
echo "--- Camadas do BOM ---"
docker history demo-bom:v2

echo ""
echo "=== Exercício 7: Provar que cache do BOM sobrevive a outra edição ==="
echo "// segunda edição em $(date)" >> app.js
echo "Rebuild BOM (deve ser instantâneo no npm install):"
time docker build -f Dockerfile.bom -t demo-bom:v3 .

echo ""
echo "=== Exercício 8: Forçando rebuild sem cache (--no-cache) ==="
# Útil pra debugar problema de cache "envenenado".
time docker build --no-cache -f Dockerfile.bom -t demo-bom:v4 .

echo ""
echo "=== Limpeza opcional ==="
# docker rmi demo-ruim:v1 demo-ruim:v2 demo-bom:v1 demo-bom:v2 demo-bom:v3 demo-bom:v4

echo ""
echo "=== Pronto! ==="
echo "💡 Compare os tempos: o rebuild do BOM (exerc. 5 e 7) deve ser"
echo "   quase instantâneo, enquanto o RUIM (exerc. 4) leva quase tanto"
echo "   tempo quanto o build inicial. Isso é o cache de camadas funcionando."
