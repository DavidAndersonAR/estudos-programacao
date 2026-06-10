#!/bin/bash
# Roteiro de testes manuais. Suba antes: ./mvnw quarkus:dev

BASE=http://localhost:8080

# 1) Login do admin -> guarda token
TOKEN=$(curl -s -X POST $BASE/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"david","senha":"123"}')
echo "Token: $TOKEN"

# 2) Chamada sem token -> 401
curl -i $BASE/me

# 3) Chamada com token -> claims
curl -i $BASE/me -H "Authorization: Bearer $TOKEN"

# 4) Endpoint de admin (david tem groups [user, admin]) -> 200
curl -i $BASE/admin/painel -H "Authorization: Bearer $TOKEN"

# 5) Login da maria (so user) -> /admin/painel deve dar 403
TOKEN_MARIA=$(curl -s -X POST $BASE/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"maria","senha":"123"}')
curl -i $BASE/admin/painel -H "Authorization: Bearer $TOKEN_MARIA"

# 6) Credencial errada -> 401
curl -i -X POST $BASE/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"hacker","senha":"x"}'
