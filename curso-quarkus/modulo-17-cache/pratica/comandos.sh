#!/usr/bin/env bash
# Demonstra o ganho de performance com cache.
# Pré-requisito: app rodando em http://localhost:8080 (./mvnw quarkus:dev)

BASE="http://localhost:8080/cotacao"

echo "=== 1ª chamada (MISS, ~1.5s) ==="
time curl -s "$BASE/USD"
echo

echo "=== 2ª chamada (HIT, < 50ms) ==="
time curl -s "$BASE/USD"
echo

echo "=== 3ª chamada com moeda diferente (MISS, ~1.5s) ==="
time curl -s "$BASE/EUR"
echo

echo "=== Invalidando USD ==="
curl -s -X DELETE "$BASE/USD"

echo "=== Chamada após invalidação (MISS de novo) ==="
time curl -s "$BASE/USD"
echo

echo "=== Cache histórico com múltiplos params (1ª = MISS, 2ª = HIT) ==="
time curl -s "$BASE/USD/historica"
time curl -s "$BASE/USD/historica"
echo

echo "=== Limpando tudo ==="
curl -s -X DELETE "$BASE"
