#!/usr/bin/env bash
# Módulo 01 — Bem-vindo + Setup
# Prática: criar projeto Quarkus e rodar em modo dev
#
# PRÉ-REQUISITOS:
#   1. JDK 21+:  java --version
#   2. JBang:    winget install JBang.JBang
#   3. CLI:      jbang app install --fresh --force quarkus@quarkusio
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Verificar ferramentas ==="
java --version
quarkus --version

echo ""
echo "=== Exercício 2: Criar projeto ==="
# Vai criar uma pasta meu-app no diretório atual.
quarkus create app com.exemplo:meu-app \
  --extension=rest-jackson \
  --java=21
cd meu-app

echo ""
echo "=== Exercício 3: Ver estrutura ==="
ls -la
echo "---"
cat pom.xml | grep -A1 "<artifactId>quarkus-" | head -10

echo ""
echo "=== Exercício 4: Rodar dev mode (em outro terminal!) ==="
echo "Abra outro terminal nesta pasta e rode:"
echo "  quarkus dev"
echo ""
echo "Vai subir em < 1s. Teste:"
echo "  curl http://localhost:8080/hello"
echo "  → 'Hello from Quarkus REST'"

echo ""
echo "=== Exercício 5: Live reload ==="
echo "Com o dev rodando, edite src/main/java/com/exemplo/GreetingResource.java"
echo "Troque o return pra 'Olá David!' e salve."
echo "Faça curl de novo — vai mostrar a mudança SEM restart."

echo ""
echo "=== Exercício 6: Dev UI ==="
echo "Abra no browser: http://localhost:8080/q/dev"
echo "Explore: Extensions, Configuration, Endpoints, CDI Beans."

echo ""
echo "=== Exercício 7: Adicionar extensão ==="
echo "Sem precisar mexer no pom.xml:"
echo "  quarkus ext add openapi"
echo "Em modo dev, ele já fica disponível em /q/openapi"
echo "Swagger UI em /q/swagger-ui"

echo ""
echo "=== Exercício 8: Rodar testes ==="
./mvnw test
# Vai rodar GreetingResourceTest (gerado junto)
