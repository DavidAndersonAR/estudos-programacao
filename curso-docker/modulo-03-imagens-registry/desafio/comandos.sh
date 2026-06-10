#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 03 — Comparar Imagens Populares
#
# Objetivo:
# Baixar 5 imagens populares, comparar tamanhos e investigar metadados.
#
# Imagens: alpine, ubuntu, debian, nginx, redis
#
# Você vai responder (com comandos!):
#   1. Qual é a MAIOR das 5?
#   2. Qual é a MENOR?
#   3. Qual porta o nginx EXPÕE (EXPOSE no Dockerfile dele)?
#   4. Quais tags estão disponíveis pro nginx no Docker Hub? (use a API)
#
# 💡 Dicas:
#   - docker pull IMAGEM (sem tag = :latest, ok pra este exercício didático)
#   - docker images --format "{{.Repository}} {{.Size}}"
#   - docker images --filter "reference=..." pra filtrar só as 5
#   - docker inspect --format '{{.Config.ExposedPorts}}' nginx
#   - Tags via API:
#       curl -s "https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=10" \
#         | jq -r '.results[].name'
#     (precisa do jq instalado — se não tiver, abra a URL no browser)

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: dar pull nas 5 imagens (alpine, ubuntu, debian, nginx, redis)"
# docker pull alpine
# ...

echo "TODO 2: listar as 5 ordenadas por tamanho"
# docker images ...

echo "TODO 3: identificar a maior e a menor"
# olho no resultado acima

echo "TODO 4: inspecionar nginx pra achar EXPOSE 80"
# docker inspect ...

echo "TODO 5: listar as 10 últimas tags do nginx no Docker Hub"
# curl ...

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco abaixo pra rodar)
# ============================

: <<'SOLUTION'

# --- Passo 1: pull das 5 imagens ---
for img in alpine ubuntu debian nginx redis; do
  echo ">>> Baixando $img..."
  docker pull "$img"
done

# --- Passo 2: listar as 5 com tamanho ---
echo ""
echo "=== Tamanhos das 5 imagens ==="
# Imprime "Repository:Tag<TAB>Size" só pras 5 que baixamos
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" \
  | grep -E '^(alpine|ubuntu|debian|nginx|redis):' \
  | sort -k2 -h
# -h faz sort respeitar sufixos (KB, MB, GB)

# Resultado típico (pode variar com o tempo):
#   alpine:latest     ~8 MB    ← MENOR
#   redis:latest      ~45 MB
#   nginx:latest      ~190 MB
#   debian:latest     ~120 MB
#   ubuntu:latest     ~78 MB
#
# MAIOR: nginx (carrega Debian + nginx + libs)
# MENOR: alpine (sistema base minimalista, ~5-8 MB)

# --- Passo 3: inspecionar nginx pra ver EXPOSE ---
echo ""
echo "=== Porta exposta pelo nginx ==="
docker inspect --format '{{.Config.ExposedPorts}}' nginx
# Saída esperada: map[80/tcp:{}]
# Significa: no Dockerfile do nginx tem 'EXPOSE 80'.
# EXPOSE é só DOCUMENTAÇÃO — não publica a porta sozinho.
# Pra acessar de fora você ainda precisa de -p 8080:80 no docker run.

# Bônus: ver TODOS os metadados úteis de uma vez
docker inspect --format \
  'Imagem: {{.RepoTags}}{{println}}Portas: {{.Config.ExposedPorts}}{{println}}CMD: {{.Config.Cmd}}{{println}}Entrypoint: {{.Config.Entrypoint}}{{println}}Arch: {{.Architecture}}/{{.Os}}' \
  nginx

# --- Passo 4: tags do nginx via API do Docker Hub ---
echo ""
echo "=== Últimas 10 tags do nginx no Docker Hub ==="
# A API REST do Hub é pública e não exige login pra leitura
curl -s "https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=10" \
  | jq -r '.results[] | "\(.name)\t\(.tag_last_pushed)"'
# Se você não tem jq, troque por:
#   curl -s "https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=10" | python -m json.tool

# Você vai ver tags como:
#   latest, mainline, stable, 1.27.3, 1.27-alpine, alpine-slim, perl, ...
# Use as fixas (1.27.3) em produção, NUNCA latest.

# --- Limpeza opcional ---
# docker rmi alpine ubuntu debian nginx redis
# (ou guarde — vamos usar várias delas nos próximos módulos)

SOLUTION
