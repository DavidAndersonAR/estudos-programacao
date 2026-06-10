#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 05 — Publicando sua própria imagem
#
# Cenário:
# Você acabou de fazer a v2.3.0 da sua super-app. Precisa publicar no Docker
# Hub com 3 tags escalonadas + login.
#
# TODOs:
#   1. Edite a variável USER pro seu usuário do Docker Hub.
#   2. Build a imagem com versão completa (2.3.0).
#   3. Tagueie com major+minor (2.3) e latest.
#   4. Rode local na porta 9090 e cheque que aparece "Minha primeira imagem".
#   5. Faça login no Docker Hub.
#   6. Pushe as 3 tags.
#   7. Verifique no painel https://hub.docker.com/r/SEU_USER/desafio-mod05
#
# 💡 Dicas:
#   - Sem namespace você NÃO consegue pushar — é obrigatório usuario/imagem.
#   - `docker push --all-tags` empurra todas as tags com um comando.
#   - Token > senha. Gere em hub.docker.com → Account Settings → Security.
#   - Se der "denied: requested access to the resource is denied",
#     ou você não logou, ou o namespace tá errado, ou o repo é privado.

set -e
cd "$(dirname "$0")"

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

USER="SEU_USUARIO_DOCKERHUB"   # TODO: troca aqui
IMAGE="desafio-mod05"
VERSION="2.3.0"

echo "TODO 1: buildar a imagem com a tag completa ${USER}/${IMAGE}:${VERSION}"
# docker build ...

echo "TODO 2: criar aliases pra ${USER}/${IMAGE}:2.3 e ${USER}/${IMAGE}:latest"
# docker tag ...
# docker tag ...

echo "TODO 3: rodar local na porta 9090 e checar"
# docker run ...
# curl ...

echo "TODO 4: login + push das 3 tags"
# docker login
# docker push ...

# Verifique:
docker images "${USER}/${IMAGE}" || true

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
USER="SEU_USUARIO_DOCKERHUB"   # troca aqui de verdade!
IMAGE="desafio-mod05"
VERSION="2.3.0"

# 1) Build já marcando as 3 tags de uma vez (mais limpo que build + tag depois).
docker build \
  -t "${USER}/${IMAGE}:${VERSION}" \
  -t "${USER}/${IMAGE}:2.3" \
  -t "${USER}/${IMAGE}:latest" \
  .

# Confirma que as 3 tags apontam pro mesmo IMAGE ID:
docker images "${USER}/${IMAGE}"

# 2) Teste local antes de publicar — é vergonhoso pushar e descobrir que tá quebrado.
docker run -d --rm --name desafio-mod05 -p 9090:80 "${USER}/${IMAGE}:${VERSION}"
sleep 2
curl -s http://localhost:9090 | head -3
curl -s http://localhost:9090/VERSION.txt    # deve responder "2.3.0"
docker stop desafio-mod05

# 3) Login (interativo). Em CI use --password-stdin com um token.
docker login

# 4) Push das 3 tags. O conteúdo viaja só uma vez; o resto é só apelido.
docker push --all-tags "${USER}/${IMAGE}"

# 5) Verifica no Docker Hub:
echo "Abre: https://hub.docker.com/r/${USER}/${IMAGE}/tags"

# Bônus — pull e roda como se fosse outro dev em outra máquina:
docker rmi "${USER}/${IMAGE}:${VERSION}" \
           "${USER}/${IMAGE}:2.3" \
           "${USER}/${IMAGE}:latest"
docker run -d --rm --name teste-pull -p 9091:80 "${USER}/${IMAGE}:latest"
sleep 2
curl -s http://localhost:9091/VERSION.txt
docker stop teste-pull
SOLUTION
