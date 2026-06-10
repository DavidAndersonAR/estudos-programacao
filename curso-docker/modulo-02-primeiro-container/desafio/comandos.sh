#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 02 — Redis na linha
#
# Objetivo:
# Subir um Redis em background, conectar com redis-cli via docker exec,
# setar e ler algumas chaves, e no fim parar e remover tudo direitinho.
#
# Por que Redis? É um banco chave-valor super leve. Perfeito pra praticar
# exec + cliente CLI dentro de um container que já está rodando.
#
# Fluxo esperado:
#   1. docker run -d com Redis (porta 6379, nome legal)
#   2. docker ps pra confirmar que subiu
#   3. docker exec ... redis-cli pra setar e ler chaves
#   4. docker logs pra ver o que o Redis escreveu
#   5. docker stop + docker rm pra limpar
#
# 💡 Dicas:
#   - A imagem oficial é `redis:7-alpine` (leve, ~40MB)
#   - O cliente já vem incluso na imagem: `redis-cli`
#   - Pra rodar um comando pontual via exec:
#       docker exec NOME redis-cli SET chave valor
#       docker exec NOME redis-cli GET chave
#   - Pra entrar no modo interativo do redis-cli:
#       docker exec -it NOME redis-cli
#       # dentro: SET nome david, GET nome, KEYS *, EXIT
#   - Porta padrão do Redis: 6379

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: subir redis:7-alpine em background com --name cache e porta 6379"
# docker run ...

echo "TODO 2: confirmar com docker ps que o cache está rodando"
# docker ps ...

echo "TODO 3: usar exec + redis-cli pra SET uma chave (ex.: aluno=david)"
# docker exec ...

echo "TODO 4: usar exec + redis-cli pra GET essa chave e mostrar o valor"
# docker exec ...

echo "TODO 5: setar mais 2 chaves e listar todas com KEYS *"
# docker exec ...

echo "TODO 6: ver as últimas linhas do log do Redis"
# docker logs ...

echo "TODO 7: parar e remover o container"
# docker stop ...
# docker rm ...

# Verificação final — não deve sobrar nada com o nome "cache":
docker ps -a --filter "name=cache"

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco pra rodar)
# ============================

: <<'SOLUTION'
# 1. Subir o Redis em background
docker run -d --name cache -p 6379:6379 redis:7-alpine

# 2. Confirmar que está rodando
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Espera 1s pro Redis terminar de iniciar
sleep 1

# 3. SET uma chave usando exec + redis-cli (comando pontual)
docker exec cache redis-cli SET aluno david
docker exec cache redis-cli SET curso "Docker do Zero"
docker exec cache redis-cli SET modulo 02

# 4. GET a chave de volta
echo "Valor de 'aluno':"
docker exec cache redis-cli GET aluno

# 5. Listar todas as chaves
echo "Todas as chaves:"
docker exec cache redis-cli KEYS '*'

# Bônus: entrar no modo interativo (rode na mão pra brincar)
#   docker exec -it cache redis-cli
#   127.0.0.1:6379> SET pais brasil
#   127.0.0.1:6379> GET pais
#   127.0.0.1:6379> DBSIZE
#   127.0.0.1:6379> EXIT

# 6. Ver logs do Redis (últimas 10 linhas)
echo "Logs do Redis:"
docker logs cache | tail -10

# 7. Limpar — stop com graça e rm
docker stop cache
docker rm cache

# Confirmação final
echo "Sobrou alguma coisa?"
docker ps -a --filter "name=cache"
SOLUTION
