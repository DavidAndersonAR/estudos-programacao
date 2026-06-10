#!/usr/bin/env bash
# Módulo 04 — Prática: build + run da imagem Node
#
# Rode linha a linha pra entender o que cada comando faz.
# Pré-requisito: estar dentro da pasta pratica/ ao rodar o build (por causa do contexto .)

set -e

echo "=== Exercício 1: Build da imagem ==="
# -t meu-app   → tag (nome) da imagem
# .            → contexto de build (pasta atual, com Dockerfile dentro)
docker build -t meu-app .

echo ""
echo "=== Exercício 2: Conferir que a imagem foi criada ==="
docker images | grep meu-app

echo ""
echo "=== Exercício 3: Inspecionar metadata (LABELs) ==="
docker inspect meu-app --format '{{json .Config.Labels}}'

echo ""
echo "=== Exercício 4: Rodar o container ==="
# -p 3000:3000  → mapeia porta 3000 do host pra 3000 do container
# --rm          → remove o container quando parar (sem sujeira)
# --name        → nome amigável pro container rodando
# -d            → detached (background) pra script continuar
docker run -d --rm --name meu-app-rodando -p 3000:3000 meu-app

echo ""
echo "Container rodando! Espera 1s pro Node subir..."
sleep 1

echo ""
echo "=== Exercício 5: Testar o endpoint ==="
# No Windows pode usar Invoke-WebRequest; no bash (Git Bash/WSL) curl funciona.
curl -s http://localhost:3000

echo ""
echo "=== Exercício 6: Ver logs do container ==="
docker logs meu-app-rodando

echo ""
echo "=== Exercício 7: Parar (e --rm remove automático) ==="
docker stop meu-app-rodando

echo ""
echo "=== Pronto! ==="
echo "Imagens locais:"
docker images | head -5
echo ""
echo "Containers rodando:"
docker ps

# 💡 Experimentos extras (rode manualmente):
# - Sobrescrever o CMD:
#     docker run --rm meu-app node -e "console.log('outro comando')"
# - Acessar shell dentro do container:
#     docker run --rm -it meu-app sh
# - Ver tamanho da imagem (Alpine é bem pequeno):
#     docker images meu-app
