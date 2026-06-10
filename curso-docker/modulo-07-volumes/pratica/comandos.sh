#!/usr/bin/env bash
# Módulo 07 — Volumes
# Prática: persistindo dados de Postgres + bind mount + tmpfs
#
# Rode linha a linha (recomendado) ou bash comandos.sh pra rodar tudo.
# Alguns comandos demoram (Postgres leva ~3-5s pra subir).

set -e  # para se algum comando falhar

echo "=== Exercício 1: Criar um named volume ==="
# Named volume é gerenciado pelo Docker — não precisa saber onde fica no disco.
docker volume create dados-postgres
docker volume ls | grep dados-postgres

echo ""
echo "=== Exercício 2: Rodar Postgres usando o volume ==="
# O Postgres oficial guarda dados em /var/lib/postgresql/data
# Vamos plugar nosso volume nesse caminho.
docker run -d \
  --name banco-pratica \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=loja \
  -v dados-postgres:/var/lib/postgresql/data \
  -p 5433:5432 \
  postgres:16

echo "Esperando o Postgres subir..."
sleep 5

echo ""
echo "=== Exercício 3: Inserir alguns dados no banco ==="
# Cria uma tabela e insere registros usando o psql DENTRO do container.
docker exec -i banco-pratica psql -U postgres -d loja <<'SQL'
CREATE TABLE produtos (id SERIAL PRIMARY KEY, nome TEXT, preco NUMERIC);
INSERT INTO produtos (nome, preco) VALUES ('Caneta', 2.50), ('Caderno', 15.00), ('Lápis', 1.20);
SELECT * FROM produtos;
SQL

echo ""
echo "=== Exercício 4: Parar e REMOVER o container ==="
# Ponto-chave: o container vai morrer, mas o volume permanece intacto.
docker stop banco-pratica
docker rm banco-pratica
echo "Container removido. Volume ainda existe?"
docker volume ls | grep dados-postgres

echo ""
echo "=== Exercício 5: Subir NOVO container apontando pro MESMO volume ==="
# Mesmo nome de volume — Postgres vai encontrar os dados do container anterior.
docker run -d \
  --name banco-pratica-2 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=loja \
  -v dados-postgres:/var/lib/postgresql/data \
  -p 5433:5432 \
  postgres:16

sleep 5
echo "Os dados sobreviveram?"
docker exec banco-pratica-2 psql -U postgres -d loja -c "SELECT * FROM produtos;"
# Se aparecer Caneta, Caderno, Lápis — SUCESSO! Persistência funcionou.

echo ""
echo "=== Exercício 6: Bind mount — montando uma pasta do PC dentro do container ==="
# Útil pra hot-reload em dev: editar arquivo no editor e o container ver na hora.
# Cria uma pasta local e arquivo de exemplo:
mkdir -p ./site-html
echo "<h1>Oi do bind mount!</h1>" > ./site-html/index.html

docker run -d \
  --name nginx-bind \
  -v "$(pwd)/site-html:/usr/share/nginx/html:ro" \
  -p 8088:80 \
  nginx
# :ro = read-only (container não pode mudar os arquivos)
# Abra http://localhost:8088 — vai mostrar "Oi do bind mount!"

echo ""
echo "=== Exercício 7: tmpfs — armazenamento em memória RAM ==="
# Não persiste. Bom pra dados temporários sensíveis.
docker run --rm --tmpfs /cache:size=32m alpine sh -c "echo 'em memoria' > /cache/teste.txt && cat /cache/teste.txt"
# Quando o container termina (--rm), o /cache some junto.

echo ""
echo "=== Exercício 8: Listar e inspecionar o volume ==="
docker volume ls
docker volume inspect dados-postgres
# Olha o "Mountpoint" — é onde o Docker guarda os dados no host.

echo ""
echo "=== Exercício 9: Limpando tudo ==="
docker stop banco-pratica-2 nginx-bind
docker rm banco-pratica-2 nginx-bind
docker volume rm dados-postgres
rm -rf ./site-html

echo ""
echo "=== Pronto! ==="
echo "Volumes restantes (deve estar limpo do que criamos):"
docker volume ls
