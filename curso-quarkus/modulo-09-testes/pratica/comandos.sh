#!/usr/bin/env bash
# Módulo 09 — Testes em Quarkus
#
# COMO USAR:
# 1. Em um projeto Quarkus (criado no Módulo 01), garanta no pom.xml as extensões:
#       - quarkus-rest-jackson
#       - quarkus-junit5            (test scope)
#       - rest-assured              (test scope)
#       - quarkus-junit5-mockito    (test scope)
# 2. Copie Produto.java, ProdutoService.java e ProdutoResource.java pra:
#       src/main/java/com/exemplo/
# 3. Copie ProdutoServiceTest.java, ProdutoResourceTest.java,
#    ProdutoResourceMockTest.java e BancoVazioProfile.java pra:
#       src/test/java/com/exemplo/
# 4. Rode os comandos abaixo.

set -e

echo "=== 1) Rodar todos os testes (Maven) ==="
./mvnw test

echo ""
echo "=== 2) Rodar só uma classe ==="
./mvnw test -Dtest=ProdutoServiceTest

echo ""
echo "=== 3) Rodar só um método ==="
./mvnw test -Dtest=ProdutoResourceTest#criarValidoDevolve201ComId

echo ""
echo "=== 4) Modo verbose (vê o que sobe e quanto demora) ==="
./mvnw test -X | tail -50

echo ""
echo "=== 5) Continuous Testing — manual, não dá pra automatizar aqui ==="
echo "Em outro terminal: quarkus dev"
echo "No prompt do quarkus dev, aperte 'r' duas vezes."
echo "Edite ProdutoService.java e veja os testes rodando sozinhos."

echo ""
echo "=== 6) Integration test (roda o jar empacotado, não @QuarkusTest) ==="
echo "Pra disparar testes terminados em IT, use:"
echo "./mvnw verify"
