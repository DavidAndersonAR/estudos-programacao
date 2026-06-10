#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 11 — comandos pra testar sua stack
#
# Depois de preencher os TODOs do docker-compose.yml, rode:
#   cd desafio && bash comandos.sh
#
# Os comandos abaixo presumem 3 serviços: postgres, redis, adminer.

set -e

echo "=== 1. Validar YAML ==="
docker compose config --quiet && echo "YAML OK!"

echo ""
echo "=== 2. Subir stack em background ==="
docker compose up -d

echo ""
echo "=== 3. Status ==="
docker compose ps

echo ""
echo "=== 4. Esperar Postgres ficar pronto (rápido e sujo) ==="
sleep 3

echo ""
echo "=== 5. Testar Postgres (criar tabela e inserir) ==="
docker compose exec -T postgres psql -U postgres -d appdb -c "
  CREATE TABLE IF NOT EXISTS logs (id SERIAL PRIMARY KEY, msg TEXT, ts TIMESTAMP DEFAULT NOW());
  INSERT INTO logs (msg) VALUES ('stack do desafio rodando');
  SELECT * FROM logs;
"

echo ""
echo "=== 6. Testar Redis (set/get) ==="
docker compose exec -T redis redis-cli SET curso "docker"
docker compose exec -T redis redis-cli GET curso

echo ""
echo "=== 7. Adminer disponível ==="
echo "👉 http://localhost:8080"
echo "    System:   PostgreSQL"
echo "    Server:   postgres"
echo "    User:     postgres"
echo "    Password: postgres"
echo "    Database: appdb"

echo ""
echo "=== 8. Testar persistência (down + up mantém os dados) ==="
echo "Execute manualmente pra ver:"
echo "  docker compose down"
echo "  docker compose up -d"
echo "  docker compose exec redis redis-cli GET curso     # deve retornar 'docker'"

echo ""
echo "=== Limpeza ==="
echo "  docker compose down                # mantém volumes (dados a salvo)"
echo "  docker compose down --volumes      # APAGA pg_data e redis_data"

# ============================
# 🧠 Perguntas pra fixar
# ============================
#
# 1. Se eu remover `depends_on` do adminer, a stack quebra?
#    R: Não necessariamente — mas em arranque a frio o Adminer pode
#       reclamar de "could not connect" até o Postgres acabar de subir.
#       depends_on só garante a ordem de start, não readiness.
#
# 2. Por que declarar `app-net` se o Compose já criaria uma default?
#    R: Clareza + controle. Em projetos maiores você quer redes nomeadas
#       (ex: frontend/backend) pra isolar quem pode falar com quem.
#
# 3. O que muda se eu trocar `restart: unless-stopped` por `restart: always`?
#    R: `always` reinicia mesmo se você der `docker stop` manual.
#       `unless-stopped` respeita o stop manual (mais amigável em dev).
#
# 4. Como eu rodaria só o Redis (sem postgres + adminer)?
#    R: docker compose up -d redis
