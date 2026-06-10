#!/usr/bin/env bash
# Módulo 05 — Prática: buildar, taggear e (opcionalmente) publicar uma imagem
#
# Rode linha a linha. Os comandos de push estão COMENTADOS de propósito —
# descomente só quando estiver pronto pra publicar no seu Docker Hub.
#
# Antes de começar:
#   1. Tenha uma conta no Docker Hub (https://hub.docker.com)
#   2. Edite a variável USER abaixo com seu usuário

set -e  # para no primeiro erro

# ============================
# Variáveis — edite USER!
# ============================
USER="SEU_USUARIO_DOCKERHUB"   # <-- TROCA AQUI
IMAGE="hello-image"
VERSION="1.0.0"

# Vai pra pasta deste script (onde está o Dockerfile)
cd "$(dirname "$0")"

echo "=== Exercício 1: build simples com uma tag ==="
docker build -t "${IMAGE}:${VERSION}" .
docker images | grep "${IMAGE}" || true

echo ""
echo "=== Exercício 2: rodar local pra testar antes de pushar ==="
# -d = detached, --rm = remove ao parar, -p = mapeia porta host:container
docker run -d --rm --name pratica-mod05 -p 8080:80 "${IMAGE}:${VERSION}"
sleep 2
echo "Abre no browser: http://localhost:8080"
curl -s http://localhost:8080 | head -5 || true
docker stop pratica-mod05

echo ""
echo "=== Exercício 3: criar várias tags com 'docker tag' ==="
# Naming convention: usuario/imagem:tag
# Semver escalonado: 1.0.0, 1.0, 1, latest
docker tag "${IMAGE}:${VERSION}" "${USER}/${IMAGE}:1.0.0"
docker tag "${IMAGE}:${VERSION}" "${USER}/${IMAGE}:1.0"
docker tag "${IMAGE}:${VERSION}" "${USER}/${IMAGE}:1"
docker tag "${IMAGE}:${VERSION}" "${USER}/${IMAGE}:latest"

# Confirma que as 4 tags apontam pro mesmo IMAGE ID:
docker images "${USER}/${IMAGE}"

echo ""
echo "=== Exercício 4: alternativa — build com várias -t de uma vez ==="
# Mesmo resultado do exercício 3, mas num único comando:
docker build \
  -t "${USER}/${IMAGE}:1.0.0" \
  -t "${USER}/${IMAGE}:1.0" \
  -t "${USER}/${IMAGE}:1" \
  -t "${USER}/${IMAGE}:latest" \
  .

echo ""
echo "=== Exercício 5: login no Docker Hub ==="
# Modo interativo (vai pedir senha/token):
# docker login
#
# Modo CI-friendly (token via stdin — recomendado):
# echo "$DOCKER_HUB_TOKEN" | docker login -u "${USER}" --password-stdin
#
# Como a gente NÃO quer logar acidentalmente em qualquer execução do script,
# está comentado:
# docker login

echo ""
echo "=== Exercício 6: PUSH (COMENTADO — descomente quando estiver pronto) ==="
# Cada push manda os apelidos; o conteúdo da imagem só viaja UMA vez.
# docker push "${USER}/${IMAGE}:1.0.0"
# docker push "${USER}/${IMAGE}:1.0"
# docker push "${USER}/${IMAGE}:1"
# docker push "${USER}/${IMAGE}:latest"
#
# Atalho — manda todas as tags do repo de uma vez:
# docker push --all-tags "${USER}/${IMAGE}"

echo ""
echo "=== Exercício 7: limpar local (opcional) ==="
# docker rmi "${IMAGE}:${VERSION}" \
#   "${USER}/${IMAGE}:1.0.0" \
#   "${USER}/${IMAGE}:1.0" \
#   "${USER}/${IMAGE}:1" \
#   "${USER}/${IMAGE}:latest"

echo ""
echo "=== Pronto! ==="
echo "Imagem(ns) buildada(s). Pra publicar, descomente login + push acima."
