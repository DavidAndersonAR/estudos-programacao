#!/usr/bin/env bash
# Módulo 20 — Prática: BuildKit + buildx
#
# Rode linha a linha pra ver cada efeito. Algumas etapas dependem de
# Docker Desktop com buildx habilitado (default desde 2022).

set -e

# Cria package.json mínimo só pra ter o que o npm ci/install consumir
mkdir -p app-demo && cd app-demo

cat > package.json <<'EOF'
{
  "name": "demo-buildkit",
  "version": "1.0.0",
  "dependencies": {
    "lodash": "^4.17.21",
    "chalk": "^5.3.0"
  }
}
EOF

# Copia o Dockerfile da pasta pai
cp ../Dockerfile .

echo ""
echo "=== Exercício 1: Confirmar que BuildKit está ativo ==="
# No Docker 23+ é default. Pra forçar (legados):
export DOCKER_BUILDKIT=1
docker version | grep -i buildkit || echo "(BuildKit é parte do daemon — sem linha dedicada, mas tá ligado)"

echo ""
echo "=== Exercício 2: Criar um arquivo de "secret" fake ==="
echo "abc123-token-super-secreto" > /tmp/build-token.txt

echo ""
echo "=== Exercício 3: Build COM secret (primeira vez — vai baixar tudo) ==="
# --secret monta o arquivo em /run/secrets/build_token DENTRO do build
time docker build \
  --secret id=build_token,src=/tmp/build-token.txt \
  -t demo-bk:v1 .

echo ""
echo "=== Exercício 4: Build de novo (cache mount em ação) ==="
# Mude um arquivo trivial pra invalidar a camada do npm ci:
touch package.json
time docker build \
  --secret id=build_token,src=/tmp/build-token.txt \
  -t demo-bk:v2 .
# 👀 Repare nas linhas "CACHED" e no fato de não baixar de novo da internet.

echo ""
echo "=== Exercício 5: Confirmar que o token NÃO vazou ==="
# docker history NÃO mostra o conteúdo do secret
docker history demo-bk:v1 | head -20
echo "(Se aparecesse 'abc123-token-super-secreto' acima, seria vazamento — mas não aparece.)"

echo ""
echo "=== Exercício 6: Rodar o container ==="
docker run --rm demo-bk:v2

echo ""
echo "=== Exercício 7: Listar builders buildx existentes ==="
docker buildx ls

echo ""
echo "=== Exercício 8: Criar um builder multi-platform ==="
# O builder default ('docker') NÃO suporta multi-platform.
# Precisamos de um 'docker-container'.
docker buildx create --name multi-builder --driver docker-container --use || \
  docker buildx use multi-builder

docker buildx inspect --bootstrap | head -30
# Repare nas linhas "Platforms:" — deve mostrar linux/amd64, linux/arm64, etc.

echo ""
echo "=== Exercício 9: Build multi-platform (SEM push, só pra ver funcionar) ==="
# ⚠️ Multi-platform build não consegue carregar em 'docker images' local
# (daemon só guarda uma arch por imagem). Por isso usamos --output=type=cacheonly
# só pra ver o build acontecer. Em produção você usaria --push.
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --secret id=build_token,src=/tmp/build-token.txt \
  -t demo-bk:multi \
  --output=type=cacheonly \
  .

echo ""
echo "=== Exercício 10: Voltar pro builder default ==="
docker buildx use default
docker buildx ls

echo ""
echo "=== Limpeza ==="
rm -f /tmp/build-token.txt
docker rmi demo-bk:v1 demo-bk:v2 2>/dev/null || true
# Não removemos o multi-builder — útil pro desafio.

echo ""
echo "=== Pronto! Pontos pra observar ==="
echo " - Tempo do build 2 vs build 1 (cache mount economizou download)"
echo " - docker history não mostra o token (secret mount funcionou)"
echo " - O builder 'docker-container' lista várias plataformas suportadas"
