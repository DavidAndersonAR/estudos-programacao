#!/usr/bin/env bash
# Módulo 19 — Prática: comandos pra validar o Dockerfile/compose production-grade.
#
# Roteiro: build, inspeção (checklist na prática), subir compose, validar.
# Rode linha a linha pra entender o que cada um mostra.

set -e

IMAGE="minha-api:prod-demo"

echo "=== Exercício 1: Build da imagem production-grade ==="
# --pull garante que a base mais recente da MESMA tag fixa é usada
# (não muda a tag, apenas evita base local desatualizada).
docker build --pull -t "$IMAGE" .

echo ""
echo "=== Exercício 2: Inspecionar tamanho (base mínima funciona?) ==="
docker images "$IMAGE" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "=== Exercício 3: Conferir que NÃO roda como root ==="
# Esperado: appuser (UID 10001)
docker run --rm --entrypoint /bin/sh "$IMAGE" -c 'id && whoami'

echo ""
echo "=== Exercício 4: Conferir variáveis de produção ==="
docker run --rm --entrypoint /bin/sh "$IMAGE" -c 'env | grep -E "NODE_ENV|LOG_LEVEL|TZ"'

echo ""
echo "=== Exercício 5: Histórico das camadas (sem secrets vazando) ==="
# Procure por linhas suspeitas: API_KEY=, PASSWORD=, etc.
docker history --no-trunc "$IMAGE" | head -30

echo ""
echo "=== Exercício 6: Scan de vulnerabilidades (Docker Scout) ==="
# Se não tiver scout: instale Docker Desktop atual OU use trivy.
docker scout cves "$IMAGE" || echo "(scout não instalado — pule, ou use: trivy image $IMAGE)"

echo ""
echo "=== Exercício 7: Subir o stack de produção ==="
# Precisa exportar APP_VERSION + ter os arquivos em ./secrets/
export APP_VERSION="prod-demo"
mkdir -p ./secrets
[ -f ./secrets/db_password.txt ]      || echo "trocar-em-prod" > ./secrets/db_password.txt
[ -f ./secrets/jwt_signing_key.txt ]  || openssl rand -hex 32  > ./secrets/jwt_signing_key.txt

docker compose -f docker-compose.prod.yml up -d

echo ""
echo "=== Exercício 8: Validar healthcheck ==="
sleep 20
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=== Exercício 9: Validar limite de memória ==="
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}"

echo ""
echo "=== Exercício 10: Validar logs JSON ==="
docker compose -f docker-compose.prod.yml logs --tail=20 api

echo ""
echo "=== Limpeza (descomente se quiser derrubar) ==="
# docker compose -f docker-compose.prod.yml down
# docker compose -f docker-compose.prod.yml down -v   # remove TAMBÉM o volume do banco (CUIDADO)

echo ""
echo "=== Checklist mental enquanto observa a saída ==="
cat <<'CHECK'
  [ ] Imagem < 200MB?
  [ ] Usuário appuser (UID 10001)?
  [ ] NODE_ENV=production?
  [ ] Sem secret no docker history?
  [ ] Container fica 'healthy' em < 30s?
  [ ] docker stats mostra limite de memória respeitado?
  [ ] Logs em JSON estruturado?
CHECK
