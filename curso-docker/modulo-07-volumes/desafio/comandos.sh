#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 07 — Persistência de Postgres com Schema via Bind Mount
#
# Objetivo:
# Provar que dados de um banco SOBREVIVEM ao remover/recriar o container.
#
# Cenário: você é dev numa loja online. Precisa subir um Postgres,
# inicializar com um schema (tabelas + dados iniciais), confirmar que
# tudo está lá, DESTRUIR o container, subir outro idêntico e ver que
# os dados continuam preservados.
#
# 💡 Conceito-chave:
#   A imagem oficial do Postgres executa AUTOMATICAMENTE qualquer .sql
#   que estiver em /docker-entrypoint-initdb.d/ na PRIMEIRA inicialização.
#   Vamos usar um bind mount pra colocar nosso schema.sql lá dentro.
#
# Passos:
#   1. Criar um arquivo schema.sql na pasta ./init/ (cria tabela + insere dados)
#   2. Criar um named volume chamado "loja-dados"
#   3. Rodar postgres montando:
#      - named volume em /var/lib/postgresql/data (persistência)
#      - bind mount ./init em /docker-entrypoint-initdb.d (schema inicial)
#   4. Conferir os dados (SELECT)
#   5. Parar e remover o container
#   6. Subir NOVO container com o MESMO volume (sem o bind mount agora)
#   7. Conferir que os dados continuam lá
#
# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: criar pasta ./init e o arquivo schema.sql dentro"
# mkdir -p ./init
# cat > ./init/schema.sql <<'SQL'
# ...crie a tabela clientes e insira 3 registros...
# SQL

echo "TODO: criar named volume loja-dados"
# docker volume create ...

echo "TODO: rodar postgres com OS DOIS mounts (volume + bind)"
# docker run -d --name loja-db ...

echo "TODO: esperar uns 5 segundos pro Postgres inicializar"
# sleep 5

echo "TODO: rodar SELECT pra confirmar que o schema rodou"
# docker exec loja-db psql ...

echo "TODO: parar e remover o container"
# docker stop ... && docker rm ...

echo "TODO: rodar NOVO container com o mesmo volume"
# docker run -d --name loja-db-v2 ...

echo "TODO: confirmar que os dados sobreviveram"
# docker exec loja-db-v2 psql ...

echo "TODO: limpar tudo no final"
# docker stop ... && docker rm ... && docker volume rm ... && rm -rf ./init

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco abaixo pra rodar)
# ============================

: <<'SOLUTION'
set -e

# 1. Cria pasta e schema.sql
mkdir -p ./init
cat > ./init/schema.sql <<'SQL'
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    criado_em TIMESTAMP DEFAULT NOW()
);

INSERT INTO clientes (nome, email) VALUES
    ('Ana Silva', 'ana@email.com'),
    ('Bruno Costa', 'bruno@email.com'),
    ('Carla Souza', 'carla@email.com');
SQL

# 2. Cria o named volume
docker volume create loja-dados

# 3. Sobe Postgres com os dois mounts
#    - named volume pros dados (persiste)
#    - bind mount pro schema (roda só na 1ª vez)
docker run -d \
  --name loja-db \
  -e POSTGRES_PASSWORD=segredo123 \
  -e POSTGRES_DB=loja \
  -v loja-dados:/var/lib/postgresql/data \
  -v "$(pwd)/init:/docker-entrypoint-initdb.d:ro" \
  -p 5434:5432 \
  postgres:16

echo "Esperando o Postgres inicializar e rodar o schema..."
sleep 6

# 4. Confirma que o schema foi aplicado
echo ">>> Dados iniciais:"
docker exec loja-db psql -U postgres -d loja -c "SELECT id, nome, email FROM clientes;"

# 5. Destrói o container (mas mantém o volume!)
docker stop loja-db
docker rm loja-db
echo ">>> Container removido. Volume ainda existe:"
docker volume ls | grep loja-dados

# 6. Sobe NOVO container — note que NÃO precisa mais do bind mount,
#    porque o schema só roda em initdb (primeira vez). O volume já tem tudo.
docker run -d \
  --name loja-db-v2 \
  -e POSTGRES_PASSWORD=segredo123 \
  -e POSTGRES_DB=loja \
  -v loja-dados:/var/lib/postgresql/data \
  -p 5434:5432 \
  postgres:16

sleep 5

# 7. PROVA que os dados sobreviveram
echo ">>> Dados após recriar o container (PERSISTÊNCIA!):"
docker exec loja-db-v2 psql -U postgres -d loja -c "SELECT id, nome, email FROM clientes;"
# Se você ver Ana, Bruno e Carla aqui de novo — PARABÉNS, persistência funciona!

# 8. Limpeza
docker stop loja-db-v2
docker rm loja-db-v2
docker volume rm loja-dados
rm -rf ./init
echo ">>> Tudo limpo."
SOLUTION

# ============================
# 🧠 PERGUNTAS PRA REFLETIR
# ============================
# 1. Por que o schema.sql só roda na PRIMEIRA inicialização? (pista: olha o
#    log do Postgres na 2ª vez — ele detecta que o data dir já existe.)
# 2. O que aconteceria se você usasse bind mount em vez de named volume
#    pros dados no Windows? (pista: performance e permissões.)
# 3. Se você fizesse `docker volume rm loja-dados` ANTES de subir o v2,
#    o que aconteceria?
