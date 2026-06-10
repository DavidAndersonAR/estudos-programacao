#!/usr/bin/env bash
# Módulo 12 — Prática: Stack web completa
#
# Rode linha a linha (ou bash comandos.sh).
# Pré-requisitos: docker-compose.yml e .env nesta mesma pasta.

set -e

cd "$(dirname "$0")"

echo "=== Exercício 1: Validar o compose (mostra YAML resolvido) ==="
# Útil pra ver como as variáveis do .env foram substituídas
docker compose config | head -40

echo ""
echo "=== Exercício 2: Subir a stack em background ==="
docker compose up -d

echo ""
echo "=== Exercício 3: Acompanhar a saúde até tudo ficar 'healthy' ==="
# Olhe a coluna STATUS — deve ir de "starting" pra "healthy"
for i in 1 2 3 4 5 6; do
  echo "--- tentativa $i ---"
  docker compose ps
  sleep 3
done

echo ""
echo "=== Exercício 4: Testar o frontend (nginx) ==="
curl -s -o /dev/null -w "nginx HTTP %{http_code}\n" http://localhost:8080/

echo ""
echo "=== Exercício 5: Testar a API mock ==="
curl -s http://localhost:8081/ && echo ""

echo ""
echo "=== Exercício 6: Provar isolamento de network ==="
# nginx (só na network 'frontend') NÃO deve resolver 'db' (só na 'backend')
echo "[esperado: FALHA — nginx não enxerga db]"
docker compose exec -T nginx sh -c "getent hosts db || echo 'OK: nginx nao resolve db'"

# api (em ambas) DEVE resolver 'db'
echo "[esperado: SUCESSO — api enxerga db]"
docker compose exec -T api sh -c "getent hosts db && echo 'OK: api resolve db'"

echo ""
echo "=== Exercício 7: Healthchecks — inspecionar diretamente ==="
docker inspect --format='db: {{.State.Health.Status}}'    pratica-db
docker inspect --format='redis: {{.State.Health.Status}}' pratica-redis

echo ""
echo "=== Exercício 8: Conectar no Postgres pelo serviço api ==="
docker compose exec -T db psql -U app -d app_db -c "SELECT version();" | head -3

echo ""
echo "=== Limpeza (descomente quando quiser derrubar) ==="
# docker compose down          # mantém o volume pg_data
# docker compose down -v       # APAGA o volume também
