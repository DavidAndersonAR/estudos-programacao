#!/usr/bin/env bash
# Comandos da prática do Módulo 11 — OpenAPI + Swagger UI

# 1) Subir a aplicação em dev mode
./mvnw quarkus:dev

# 2) Em outro terminal — baixar o schema OpenAPI em JSON
curl -s http://localhost:8080/q/openapi | jq . | head -50

# 3) Baixar o schema em YAML (formato preferido pra versionar em git)
curl -s http://localhost:8080/q/openapi.yaml -o api.yaml
cat api.yaml | head -30

# 4) Abrir o Swagger UI no navegador
# Linux:   xdg-open http://localhost:8080/q/swagger-ui
# Windows: start http://localhost:8080/q/swagger-ui
# Mac:     open http://localhost:8080/q/swagger-ui

# 5) Testar os endpoints
curl -s http://localhost:8080/pedidos | jq
curl -s http://localhost:8080/pedidos/1 | jq

curl -s -X POST http://localhost:8080/pedidos \
  -H "Content-Type: application/json" \
  -d '{"cliente":"Ana Costa","valor":350.00,"status":"PENDENTE"}' | jq

curl -i -X DELETE http://localhost:8080/pedidos/1

# 6) Gerar client TypeScript a partir do schema (exige Node)
# npx @openapitools/openapi-generator-cli generate \
#   -i api.yaml -g typescript-axios -o ./client-ts

# 7) Build em modo produção e conferir que o Swagger UI continua disponível
./mvnw package -DskipTests
java -jar target/quarkus-app/quarkus-run.jar
# Em outro terminal:
# curl -s http://localhost:8080/q/swagger-ui/ -o /dev/null -w "%{http_code}\n"
