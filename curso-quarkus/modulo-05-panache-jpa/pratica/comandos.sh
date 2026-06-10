#!/usr/bin/env bash
# Pre-requisitos:
#   - Docker rodando (Dev Services sobe o Postgres)
#   - quarkus dev rodando neste projeto
# Dica: rode os comandos um a um e olhe o log SQL no console do Quarkus.

BASE=http://localhost:8080/livros

echo "== Listar (paginado, ordenado por titulo) =="
curl -s "$BASE?pagina=0&tamanho=10" | jq .

echo "== Buscar 1 =="
curl -s "$BASE/1" | jq .

echo "== Filtrar livros de um autor (id 2 — Clarice) =="
curl -s "$BASE?autor=2" | jq .

echo "== Contagem total =="
curl -s "$BASE/contagem"
echo

echo "== Contagem por prefixo do titulo =="
curl -s "$BASE/contagem?titulo=Dom"
echo

echo "== Criar livro (autor existente) =="
curl -s -X POST "$BASE" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Quincas Borba","ano":1891,"preco":29.90,"autor":{"id":1}}' | jq .

echo "== Atualizar livro 3 =="
curl -s -X PUT "$BASE/3" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"A Hora da Estrela (ed. especial)","ano":1977,"preco":59.90}' | jq .

echo "== Reajuste em massa: +10% para livros do autor 1 =="
curl -s -X POST "$BASE/reajuste?autor=1&fator=1.10"
echo

echo "== Remover livro 5 =="
curl -i -X DELETE "$BASE/5"

echo "== Tentar buscar livro inexistente =="
curl -i "$BASE/9999"
