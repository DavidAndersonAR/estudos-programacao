#!/usr/bin/env bash
# Comandos para testar o módulo 13 — Mensageria com Kafka
# Pré-requisito: Docker rodando (Dev Services sobe o Kafka)

# 1) Sobe a aplicação em modo dev — Dev Services cria container Kafka
./mvnw quarkus:dev

# --- Em outro terminal, manda alguns pedidos ---

# 2) POST simples
curl -X POST http://localhost:8080/pedidos \
  -H "Content-Type: application/json" \
  -d '{"item":"Café","quantidade":2}'

# 3) Mais um
curl -X POST http://localhost:8080/pedidos \
  -H "Content-Type: application/json" \
  -d '{"item":"Pão de queijo","quantidade":10}'

# 4) Rajada de 5
for i in 1 2 3 4 5; do
  curl -s -X POST http://localhost:8080/pedidos \
    -H "Content-Type: application/json" \
    -d "{\"item\":\"Item $i\",\"quantidade\":$i}"
  echo ""
done

# No terminal do quarkus:dev você deve ver, pra cada POST:
#   "Publicado no Kafka: Pedido[id=..., item=...]"
#   "Transformando pedido N"
#   ">>> Consumer recebeu: id=N item='... [PROCESSADO]' qtd=..."

# 5) Dev UI mostra os tópicos e mensagens
#    Abra: http://localhost:8080/q/dev-ui  -> aba "Kafka"
