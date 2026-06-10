#!/usr/bin/env bash
# Módulo 11 — Prática: Postgres + Adminer com Docker Compose
#
# Rode dentro desta pasta (onde está o docker-compose.yml):
#   cd pratica && bash comandos.sh
#
# Ou linha a linha, pra ir observando.

set -e

echo "=== Exercício 1: Validar o YAML antes de subir ==="
docker compose config --quiet && echo "YAML OK!"

echo ""
echo "=== Exercício 2: Subir a stack em background ==="
docker compose up -d

echo ""
echo "=== Exercício 3: Ver status dos serviços ==="
docker compose ps

echo ""
echo "=== Exercício 4: Acompanhar logs (só do db, últimas 20 linhas) ==="
docker compose logs --tail=20 db

echo ""
echo "=== Exercício 5: Executar um comando dentro do Postgres ==="
# Cria uma tabela de teste e insere uma linha pra você ver no Adminer
docker compose exec -T db psql -U postgres -d appdb -c "
  CREATE TABLE IF NOT EXISTS visitas (id SERIAL PRIMARY KEY, nome TEXT, criado_em TIMESTAMP DEFAULT NOW());
  INSERT INTO visitas (nome) VALUES ('David');
  SELECT * FROM visitas;
"

echo ""
echo "=== Exercício 6: Abra o Adminer ==="
echo "👉 http://localhost:8080"
echo "    System:   PostgreSQL"
echo "    Server:   db"
echo "    Username: postgres"
echo "    Password: postgres"
echo "    Database: appdb"
echo ""
echo "Procure a tabela 'visitas' — deve aparecer a linha que acabamos de inserir."

echo ""
echo "=== Exercício 7 (opcional): Reiniciar só o Adminer ==="
# docker compose restart adminer

echo ""
echo "=== Pra derrubar tudo quando terminar ==="
echo "  docker compose down                # mantém o volume (dados a salvo)"
echo "  docker compose down --volumes      # APAGA o volume db_data também"
