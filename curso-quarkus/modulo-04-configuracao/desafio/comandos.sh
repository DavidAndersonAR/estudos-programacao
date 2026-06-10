#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 04 — LimitesConfig
#
# Leia enunciado.md primeiro.
#
# Passo a passo:
# 1. Crie src/main/java/com/exemplo/LimitesConfig.java
# 2. Crie src/main/java/com/exemplo/LimitesResource.java
# 3. Adicione as chaves em src/main/resources/application.properties
# 4. quarkus dev
# 5. curl http://localhost:8080/limites
# 6. ./mvnw package
# 7. Rode com env vars e confirme override
#
# Soluções em LimitesConfig.java.solucao, LimitesResource.java.solucao e
# application.properties.solucao — só abra DEPOIS de tentar.

set -e

echo "=== TODO 1: criar LimitesConfig (interface @ConfigMapping prefix=\"limites\") ==="
echo "    → 2 sub-interfaces: Requisicoes, Tamanho"
echo ""
echo "=== TODO 2: declarar defaults em application.properties ==="
echo "    + bloco %dev. com valores folgados"
echo ""
echo "=== TODO 3: criar LimitesResource em /limites ==="
echo "    → retorna JSON com os 4 valores"
echo ""
echo "=== TODO 4: testar em dev ==="
echo "    quarkus dev"
echo "    curl -s http://localhost:8080/limites | jq"
echo "    → deve mostrar 600, 1000000, 4096, 50 (defaults de dev)"
echo ""
echo "=== TODO 5: build prod ==="
echo "    ./mvnw package"
echo "    java -jar target/quarkus-app/quarkus-run.jar"
echo "    curl -s http://localhost:8080/limites | jq"
echo "    → deve mostrar 60, 10000, 512, 50 (defaults globais)"
echo ""
echo "=== TODO 6: override por env var (o ponto principal!) ==="
echo "    Pare o jar. Rode:"
echo ""
echo "    LIMITES_REQUISICOES_POR_MINUTO=30 \\"
echo "    LIMITES_TAMANHO_MAX_PAYLOAD_KB=128 \\"
echo "    java -jar target/quarkus-app/quarkus-run.jar"
echo ""
echo "    curl -s http://localhost:8080/limites | jq"
echo "    → porMinuto=30, maxPayloadKb=128, os outros mantêm default"
echo ""
echo "=== BÔNUS ==="
echo "  - Adicione bloqueioDuracao: Optional<Duration>"
echo "  - LIMITES_BLOQUEIO_DURACAO=PT5M no env"
echo "  - @PostConstruct logando limites no startup"
