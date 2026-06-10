#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 14 — Reduzir imagem em 80%
#
# Antes de rodar:
# 1. Leia o Dockerfile e implemente os TODOs (ou descomente a solução).
# 2. Crie os arquivos da app (main.py e requirements.txt) com o conteúdo
#    descrito no Dockerfile — sem eles o build não funciona.

set -e

# Setup mínimo da app (pra você não precisar criar manualmente)
if [ ! -f main.py ]; then
  cat > main.py <<'EOF'
from fastapi import FastAPI
app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
EOF
fi

if [ ! -f requirements.txt ]; then
  cat > requirements.txt <<'EOF'
fastapi==0.115.0
uvicorn==0.32.0
EOF
fi

echo "=== Build da sua solução ==="
docker build -t desafio14:otimizada .

echo ""
echo "=== Tamanho da imagem ==="
docker images | grep -E "REPOSITORY|desafio14"

echo ""
echo "=== Meta: < 200MB. Conseguiu? ==="
SIZE=$(docker image inspect desafio14:otimizada --format='{{.Size}}')
SIZE_MB=$((SIZE / 1024 / 1024))
echo "Sua imagem: ${SIZE_MB}MB"
if [ "$SIZE_MB" -lt 200 ]; then
  echo "✅ Passou no desafio!"
else
  echo "❌ Ainda gorda demais — revise a base e dependências."
fi

echo ""
echo "=== Subir e testar ==="
docker run -d --name desafio14 -p 8000:8000 desafio14:otimizada
sleep 3
echo "GET /health:"
curl -s http://localhost:8000/health && echo ""

echo ""
echo "=== Layers (auditoria) ==="
docker history desafio14:otimizada

echo ""
echo "=== Limpeza ==="
docker stop desafio14
docker rm desafio14

echo ""
echo "=== Bônus: comparar com docker scout ==="
echo "  docker scout quickview desafio14:otimizada"
