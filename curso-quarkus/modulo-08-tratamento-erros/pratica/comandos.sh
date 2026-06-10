#!/usr/bin/env bash
# Comandos pra testar o tratamento de erros do Módulo 08.
# Pré-requisito: `quarkus dev` rodando em http://localhost:8080.

BASE=http://localhost:8080/produtos

echo "==> 200 OK: produto existente"
curl -i $BASE/1
echo

echo "==> 404 problem+json: produto inexistente"
curl -i $BASE/999
echo

echo "==> 201/200: criar produto válido"
curl -i -X POST $BASE \
  -H "Content-Type: application/json" \
  -d '{"nome":"Lapis","preco":3.5}'
echo

echo "==> 422 problem+json: validação (nome vazio + preço negativo)"
curl -i -X POST $BASE \
  -H "Content-Type: application/json" \
  -d '{"nome":"","preco":-1}'
echo

echo "==> 500 problem+json: erro genérico (catch-all). Olhe o log do servidor pelo traceId."
curl -i $BASE/boom
echo

# Dicas:
# - Cabeçalho Content-Type da resposta de erro deve ser: application/problem+json
# - A resposta 500 traz um campo "traceId" que casa com a linha "Erro inesperado [traceId=...]" no log
# - O 422 traz "errors": [{ "campo": ..., "mensagem": ... }, ...]
