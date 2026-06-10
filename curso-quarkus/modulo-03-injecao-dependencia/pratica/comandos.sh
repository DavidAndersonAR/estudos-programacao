#!/usr/bin/env bash
# Módulo 03 — Injeção de Dependência (CDI)
# Prática: API de Produtos em 3 camadas (Resource → Service → Repository)
#
# PRÉ-REQUISITOS:
#   1. Projeto Quarkus já criado (Módulo 01) com extensão rest-jackson
#      quarkus create app com.exemplo:produtos-api --extension=rest-jackson --java=21
#   2. Copiar os 4 arquivos .java desta pasta pra src/main/java/com/exemplo/
#   3. Subir em dev:
#      cd produtos-api && quarkus dev

set -e

BASE="http://localhost:8080/produtos"

echo "=== Exercício 1: Listar (já vem com 2 produtos do seed @PostConstruct) ==="
curl -s "$BASE" | jq .

echo ""
echo "=== Exercício 2: Buscar por id ==="
curl -s "$BASE/1" | jq .

echo ""
echo "=== Exercício 3: Criar produto novo ==="
curl -s -X POST "$BASE" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Borracha","preco":2.30}' | jq .

echo ""
echo "=== Exercício 4: Tentar criar inválido (nome vazio) ==="
# O Service rejeita com IllegalArgumentException → vira 500 por enquanto.
# No Módulo 08 (tratamento de erros) vamos transformar em 400 elegante.
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST "$BASE" \
  -H "Content-Type: application/json" \
  -d '{"nome":"","preco":1.0}'

echo ""
echo "=== Exercício 5: Listar de novo (3 agora) ==="
curl -s "$BASE" | jq .

echo ""
echo "=== Exercício 6: Remover ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X DELETE "$BASE/1"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X DELETE "$BASE/9999"  # → 404

echo ""
echo "=== Exercício 7: Inspecionar beans CDI ==="
echo "Abra no browser:  http://localhost:8080/q/dev"
echo "Vá em 'Arc' → 'Beans'. Procure por:"
echo "  - ProdutoResource    (@Dependent — recursos REST não precisam de escopo)"
echo "  - ProdutoService     (@ApplicationScoped)"
echo "  - ProdutoRepository  (@ApplicationScoped)"
echo "Repare nas dependências (Injection Points) listadas em cada um."

echo ""
echo "=== Exercício 8 (opcional): Trocar pra @Singleton e observar ==="
echo "1. Em ProdutoRepository, troque @ApplicationScoped por @Singleton"
echo "2. Salve — live reload aplica"
echo "3. Comportamento idêntico, mas a instância é criada no startup (eager)"
echo "4. Volte pra @ApplicationScoped antes de seguir"
