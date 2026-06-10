#!/usr/bin/env bash
# Módulo 17 — Prática: Healthcheck + Restart policy
#
# Roteiro:
#  1. Build da imagem
#  2. Sobe com --restart unless-stopped
#  3. Acompanha o estado de saúde mudando de starting -> healthy
#  4. Mata o processo de propósito e vê o Docker reiniciar sozinho
#  5. Inspeciona o histórico de healthchecks
#
# Rode linha a linha pra acompanhar com calma.

set -e

IMG=modulo17-pratica
NAME=app17

echo "=== Exercício 1: Build da imagem ==="
docker build -t $IMG .

echo ""
echo "=== Exercício 2: Sobe com restart policy ==="
# Mata container antigo se existir (idempotente)
docker rm -f $NAME 2>/dev/null || true

docker run -d \
  --name $NAME \
  --restart unless-stopped \
  -p 3000:3000 \
  --init \
  $IMG

echo "Container subiu. Veja o STATUS — vai começar como (health: starting)"
docker ps --filter name=$NAME

echo ""
echo "=== Exercício 3: Esperar healthy (uns 15s) ==="
echo "Acompanhe — vai sair de 'starting' pra 'healthy':"
for i in 1 2 3 4 5; do
  sleep 4
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' $NAME)
  echo "  [$((i*4))s] Status: $STATUS"
done

echo ""
echo "=== Exercício 4: Bater no endpoint ==="
curl -s http://localhost:3000/ && echo ""
curl -s http://localhost:3000/health && echo ""

echo ""
echo "=== Exercício 5: Histórico dos últimos healthchecks ==="
docker inspect --format='{{json .State.Health}}' $NAME | head -c 600
echo ""
echo "..."

echo ""
echo "=== Exercício 6: Simular crash — matar o processo ==="
# Mata o Node de dentro do container. O container morre, mas o restart policy reanima.
RESTARTS_ANTES=$(docker inspect --format='{{.RestartCount}}' $NAME)
echo "Restarts antes do crash: $RESTARTS_ANTES"

docker exec $NAME sh -c "kill 1" || true
echo "Mandei kill no PID 1. Esperando o Docker reiniciar..."
sleep 5

RESTARTS_DEPOIS=$(docker inspect --format='{{.RestartCount}}' $NAME)
echo "Restarts depois do crash: $RESTARTS_DEPOIS"
docker ps --filter name=$NAME

echo ""
echo "=== Exercício 7: App voltou sozinho? ==="
sleep 3
curl -s http://localhost:3000/ && echo ""

echo ""
echo "=== Limpeza (descomente se quiser) ==="
# docker rm -f $NAME
# docker rmi $IMG

echo "Pronto! Container está rodando com restart automático."
echo "Mate quando quiser: docker rm -f $NAME"
