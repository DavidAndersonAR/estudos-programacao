#!/usr/bin/env bash
# Comandos da solução do desafio do Módulo 11

# 1) Rodar em dev
./mvnw quarkus:dev

# 2) Validar endpoints
curl -s http://localhost:8080/clientes | jq
curl -s http://localhost:8080/clientes/1 | jq
curl -i http://localhost:8080/clientes/999

curl -s -X POST http://localhost:8080/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"Carla Dias","email":"carla@email.com","cpf":"11122233344"}' | jq

# Reativar o cliente 2 (que está inativo)
curl -s -X PATCH http://localhost:8080/clientes/2/ativar | jq
# Tentar reativar de novo — deve dar 409
curl -i -X PATCH http://localhost:8080/clientes/2/ativar

# 3) Conferir documentação
# Swagger UI no path customizado:
# http://localhost:8080/docs

# Schema YAML:
curl -s http://localhost:8080/q/openapi.yaml -o clientes-api.yaml
grep -E "tags:|summary:|description:" clientes-api.yaml | head -20

# 4) Bônus — gerar client TypeScript
# npx @openapitools/openapi-generator-cli generate \
#   -i clientes-api.yaml \
#   -g typescript-axios \
#   -o ./client-clientes

# 5) Conferir Swagger UI em produção
./mvnw package -DskipTests
java -jar target/quarkus-app/quarkus-run.jar &
sleep 5
curl -s -o /dev/null -w "Swagger UI em prod: %{http_code}\n" http://localhost:8080/docs/
