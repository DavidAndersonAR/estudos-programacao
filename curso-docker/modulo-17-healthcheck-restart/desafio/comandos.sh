#!/usr/bin/env bash
# 🎯 DESAFIO Módulo 17 — Roteiro de execução
#
# Pré-requisito: você completou os TODOs em Dockerfile e docker-compose.yml.
#
# O que vamos ver:
#   1. Sobe o stack (app + client)
#   2. App fica healthy
#   3. Client bate 7 vezes em / -> app "quebra" (/health vira 500)
#   4. Docker detecta unhealthy
#   5. Restart policy reinicia o container
#   6. Contador zera (porque é em memória) — app saudável de novo
#
# IMPORTANTE: healthcheck unhealthy SOZINHO não reinicia (Docker simples).
# Mas se você matar o processo (kill 1) com restart policy, aí sim reinicia.
# No desafio, simulamos os DOIS comportamentos.

set -e

echo "=== Etapa 1: Build + sobe stack ==="
docker compose up -d --build

echo ""
echo "=== Etapa 2: Esperar app ficar healthy ==="
for i in 1 2 3 4 5; do
  sleep 3
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' desafio17-app 2>/dev/null || echo "?")
  echo "  [${i}] Status: $STATUS"
  [ "$STATUS" = "healthy" ] && break
done

echo ""
echo "=== Etapa 3: Estado dos serviços ==="
docker compose ps

echo ""
echo "=== Etapa 4: Logs do client (vai bater nas requests) ==="
sleep 10
docker compose logs client | tail -20

echo ""
echo "=== Etapa 5: App está unhealthy agora? ==="
sleep 10
docker inspect --format='Status: {{.State.Health.Status}} | RestartCount: {{.RestartCount}}' desafio17-app

echo ""
echo "Note: Docker simples NÃO reinicia automaticamente por unhealthy."
echo "Pra ver o restart agindo, vamos matar o processo na mão:"

echo ""
echo "=== Etapa 6: Matar PID 1 (simula crash de verdade) ==="
docker exec desafio17-app sh -c "kill 1" || true
sleep 6

echo ""
echo "=== Etapa 7: Container voltou? ==="
docker inspect --format='Status: {{.State.Health.Status}} | RestartCount: {{.RestartCount}}' desafio17-app
docker compose ps

echo ""
echo "=== Limpeza ==="
echo "Quando terminar de explorar:"
echo "  docker compose down"

# ============================
# BÔNUS: o "autoheal" pattern
# ============================
# Se você QUER restart automático em cima de unhealthy no Docker simples,
# rode um container que monitora os outros:
#
#   docker run -d \
#     --name autoheal \
#     --restart=always \
#     -e AUTOHEAL_CONTAINER_LABEL=all \
#     -v /var/run/docker.sock:/var/run/docker.sock \
#     willfarrell/autoheal
#
# Ele detecta qualquer container unhealthy e dá restart.
# Em Kubernetes/Swarm isso é nativo (liveness probe).
