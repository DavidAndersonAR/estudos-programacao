#!/usr/bin/env bash
# Módulo 02 — REST básico (CRUD de Livro)
#
# COMO USAR:
# 1. Tenha um projeto Quarkus rodando (criado no Módulo 01) com extensão rest-jackson.
# 2. Copie Livro.java e LivroResource.java pra src/main/java/com/exemplo/
#    (ajuste o package se seu groupId for diferente).
# 3. Em um terminal, rode:  quarkus dev
# 4. Em outro terminal, rode este script linha a linha — ou só copie os curls que quer testar.
#
# Esperado: você vai criar, listar, buscar, atualizar e remover livros via HTTP.

set -e
BASE="http://localhost:8080/livros"

echo "=== 1) Listar tudo (já vem com 3 livros do construtor) ==="
curl -s "$BASE" | jq

echo ""
echo "=== 2) Filtrar por autor (query param ?autor=Tolkien) ==="
curl -s "$BASE?autor=Tolkien" | jq

echo ""
echo "=== 3) Buscar por id (path param) ==="
curl -s -i "$BASE/1"

echo ""
echo "=== 4) Buscar id que não existe → 404 ==="
curl -s -i "$BASE/999"

echo ""
echo "=== 5) Criar (POST com body JSON) → 201 Created + header Location ==="
curl -s -i -X POST "$BASE" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Duna","autor":"Frank Herbert"}'

echo ""
echo "=== 6) Atualizar (PUT) ==="
curl -s -i -X PUT "$BASE/1" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"O Hobbit (edição revisada)","autor":"J.R.R. Tolkien"}'

echo ""
echo "=== 7) Atualizar id que não existe → 404 ==="
curl -s -i -X PUT "$BASE/999" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"X","autor":"Y"}'

echo ""
echo "=== 8) Remover (DELETE) → 204 No Content ==="
curl -s -i -X DELETE "$BASE/2"

echo ""
echo "=== 9) Remover de novo → 404 ==="
curl -s -i -X DELETE "$BASE/2"

echo ""
echo "=== 10) Lista final ==="
curl -s "$BASE" | jq

echo ""
echo "Dica: abra http://localhost:8080/q/dev → seção Endpoints, dá pra testar pelo browser."
