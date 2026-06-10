#!/usr/bin/env bash
# Comandos pra testar health e metricas. Suba a app com: ./mvnw quarkus:dev

BASE="http://localhost:8080"

echo "=== Health geral ==="
curl -s $BASE/q/health | jq .

echo
echo "=== Só liveness (deve refletir o DiskoHealthCheck) ==="
curl -s $BASE/q/health/live | jq .

echo
echo "=== Só readiness (deve refletir o BancoHealthCheck) ==="
curl -s $BASE/q/health/ready | jq .

echo
echo "=== Startup ==="
curl -s $BASE/q/health/started | jq .

echo
echo "=== Criando 3 pedidos pra mexer nos contadores ==="
for i in 1 2 3; do
  curl -s -X POST $BASE/pedidos \
       -H "Content-Type: application/json" \
       -d "{\"cliente\":\"Cliente $i\",\"valor\":${i}9.90,\"status\":\"PAGO\"}"
  echo
done

echo
echo "=== Processando 1 da fila ==="
curl -s $BASE/pedidos/processar-proximo

echo
echo "=== Metricas em formato Prometheus (filtradas) ==="
curl -s $BASE/q/metrics | grep -E "^(pedidos_|pedido_|app_memoria_)" | head -40

echo
echo "=== HTTP do proprio Quarkus ==="
curl -s $BASE/q/metrics | grep "http_server_requests_seconds_count" | head -5
