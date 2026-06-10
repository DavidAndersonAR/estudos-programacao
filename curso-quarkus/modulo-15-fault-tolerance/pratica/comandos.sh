#!/bin/bash
# Adicionar extensão
./mvnw quarkus:add-extension -Dextensions="smallrye-fault-tolerance"

# Rodar a aplicação
./mvnw quarkus:dev

# --- Em outro terminal: ---

# Chamada única
curl http://localhost:8080/status/42

# Loop de 30 chamadas pra ver o circuit breaker abrir e o fallback agir
for i in $(seq 1 30); do
  echo "--- request $i ---"
  curl -s http://localhost:8080/status/$i
  echo ""
  sleep 0.3
done

# Olhar métricas de fault tolerance
curl http://localhost:8080/q/metrics | grep ft_

# O que observar:
# - Origens diferentes: "servico-externo" (ok), "cache-fallback" (deu ruim)
# - Depois de várias falhas o circuito abre: fallback dispara imediatamente
# - Após 5s o circuito vai pra meio-aberto e testa de novo
