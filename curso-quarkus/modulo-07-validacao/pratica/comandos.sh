#!/usr/bin/env bash
# Rode antes:
#   quarkus extension add hibernate-validator
#   quarkus dev

BASE="http://localhost:8080/usuarios"

echo "=== 1) POST válido — deve retornar 201 ==="
curl -i -X POST "$BASE" \
  -H 'Content-Type: application/json' \
  -d '{
    "nome": "Maria Silva",
    "email": "maria@exemplo.com",
    "idade": 30,
    "cpf": "123.456.789-00",
    "telefone": "(11) 91234-5678",
    "nascimento": "1995-04-12"
  }'
echo

echo "=== 2) POST inválido — várias violations, deve retornar 400 ==="
curl -i -X POST "$BASE" \
  -H 'Content-Type: application/json' \
  -d '{
    "nome": "Jo",
    "email": "naoeemail",
    "idade": 15,
    "cpf": "123",
    "telefone": "11912345678",
    "nascimento": "2099-01-01"
  }'
echo

echo "=== 3) POST com id preenchido — viola @Null do grupo Criar ==="
curl -i -X POST "$BASE" \
  -H 'Content-Type: application/json' \
  -d '{
    "id": 99,
    "nome": "Carlos",
    "email": "c@ex.com",
    "idade": 25,
    "cpf": "111.222.333-44",
    "telefone": "(21) 99999-0000"
  }'
echo

echo "=== 4) PUT sem id no body — viola @NotNull do grupo Atualizar ==="
curl -i -X PUT "$BASE/1" \
  -H 'Content-Type: application/json' \
  -d '{
    "nome": "Maria Atualizada",
    "email": "maria@exemplo.com",
    "idade": 31,
    "cpf": "123.456.789-00",
    "telefone": "(11) 91234-5678"
  }'
echo

echo "=== 5) PUT válido com id ==="
curl -i -X PUT "$BASE/1" \
  -H 'Content-Type: application/json' \
  -d '{
    "id": 1,
    "nome": "Maria Atualizada",
    "email": "maria@exemplo.com",
    "idade": 31,
    "cpf": "123.456.789-00",
    "telefone": "(11) 91234-5678"
  }'
echo

echo "=== 6) GET sem query param 'pagina' — viola @NotNull ==="
curl -i "$BASE"
echo

echo "=== 7) GET com pagina=0 — viola @Min(1) ==="
curl -i "$BASE?pagina=0"
echo

echo "=== 8) GET válido ==="
curl -i "$BASE?pagina=1"
echo

echo "=== 9) Endpoint manual (validação programática) — payload ruim ==="
curl -i -X POST "$BASE/manual" \
  -H 'Content-Type: application/json' \
  -d '{ "nome": "X", "email": "ruim", "idade": 5, "cpf": "abc", "telefone": "x" }'
echo
