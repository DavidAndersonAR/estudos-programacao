#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 12 — Comandos pra testar sua stack
#
# Antes de rodar, complete o docker-compose.yml resolvendo os TODOs.
# Se ficar travado, descomente o bloco SOLUÇÃO no final do compose.

set -e
cd "$(dirname "$0")"

echo "=== Passo 1: Validar o compose ==="
# Se faltar TODO essencial (ex: networks vazias), aqui já avisa
docker compose config > /dev/null && echo "compose válido ✔"

echo ""
echo "=== Passo 2: Subir SEM o profile dev (adminer NÃO deve subir) ==="
docker compose up -d

echo "Esperando 20s pros healthchecks ficarem healthy..."
sleep 20
docker compose ps

echo ""
echo "[esperado: 5 serviços rodando — adminer NÃO listado]"
echo ""

echo "=== Passo 3: Testar nginx e api ==="
curl -s -o /dev/null -w "nginx HTTP %{http_code}\n" http://localhost:8090/
curl -s -o /dev/null -w "api   HTTP %{http_code}\n" http://localhost:8091/

echo ""
echo "=== Passo 4: Verificar isolamento (workers só em backend) ==="
# nginx (frontend) NÃO deve resolver 'workers'
docker compose exec -T nginx sh -c "getent hosts workers || echo 'OK: nginx nao enxerga workers'"
# api (frontend+backend) DEVE resolver tudo
docker compose exec -T api sh -c "getent hosts db && getent hosts redis && echo 'OK: api enxerga db e redis'"

echo ""
echo "=== Passo 5: Derrubar e subir COM o profile dev ==="
docker compose down
docker compose --profile dev up -d
sleep 15

echo ""
echo "[esperado: agora aparece 'desafio-adminer' também]"
docker compose ps

echo ""
echo "Abra http://localhost:8092 no browser pra ver o Adminer."
echo "Login: System=PostgreSQL  Server=db  User=app  Senha=(a do .env)  DB=app_db"

echo ""
echo "=== Passo 6: Inspecionar healthchecks ==="
for svc in desafio-db desafio-redis desafio-api desafio-workers; do
  docker inspect --format="$svc: {{.State.Health.Status}}" "$svc" 2>/dev/null || true
done

echo ""
echo "=== Limpeza (quando terminar) ==="
# docker compose --profile dev down       # mantém volume
# docker compose --profile dev down -v    # apaga pg_data também
