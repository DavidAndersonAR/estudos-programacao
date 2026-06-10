#!/usr/bin/env bash
# Módulo 04 — Configuração
# Prática: usar @ConfigProperty, @ConfigMapping, profiles e override por env var.
#
# PRÉ-REQUISITO: ter um projeto Quarkus rodando. Se não tiver:
#   quarkus create app com.exemplo:config-demo --extension=rest-jackson --java=21
#   cd config-demo
#
# Copie os arquivos desta pasta pratica/ para o projeto:
#   - application.properties → src/main/resources/
#   - AppConfig.java, EmailService.java, StatusResource.java → src/main/java/com/exemplo/

set -e

echo "=== Exercício 1: Rodar em dev mode ==="
echo "  quarkus dev"
echo "Profile ativo: dev → vai usar %dev.app.email.remetente=dev@local.test"

echo ""
echo "=== Exercício 2: Ver config efetiva ==="
echo "  curl -s http://localhost:8080/status | jq"
echo ""
echo "Resposta esperada (em dev):"
echo '  {'
echo '    "profile": "dev",'
echo '    "remetente": "dev@local.test",'
echo '    "assuntoPadrao": "Boas-vindas",'
echo '    "copiaOculta": "auditoria@exemplo.com",'
echo '    "limiteRequisicoes": 100,'
echo '    "betaAtivo": true'
echo '  }'

echo ""
echo "=== Exercício 3: Endpoint que usa EmailService ==="
echo "  curl http://localhost:8080/status/teste-envio"
echo "  → DE: dev@local.test | PARA: cliente@destino.com | ..."

echo ""
echo "=== Exercício 4: Live reload de config ==="
echo "Edite src/main/resources/application.properties:"
echo "  troque app.limite-requisicoes=100 para 200"
echo "Salve e bata /status de novo — vai mostrar 200 sem restart."

echo ""
echo "=== Exercício 5: Dev UI - configuração ==="
echo "Abra http://localhost:8080/q/dev → Configuration"
echo "Procure por 'app.' — vai ver todas as suas chaves e a fonte de cada uma."

echo ""
echo "=== Exercício 6: Build pra produção ==="
echo "  ./mvnw package"
echo "  java -jar target/quarkus-app/quarkus-run.jar"
echo ""
echo "Agora o profile é 'prod' (sem %dev. override)."
echo "  curl http://localhost:8080/status"
echo "  → remetente: no-reply@exemplo.com  (valor default)"
echo "  → betaAtivo: false"

echo ""
echo "=== Exercício 7: Override por variável de ambiente (chave da aula!) ==="
echo "Pare o app. Rode com env var:"
echo ""
echo "  APP_EMAIL_REMETENTE=contato@empresa.com \\"
echo "  APP_LIMITE_REQUISICOES=500 \\"
echo "  java -jar target/quarkus-app/quarkus-run.jar"
echo ""
echo "  curl http://localhost:8080/status"
echo "  → remetente: contato@empresa.com"
echo "  → limiteRequisicoes: 500"
echo ""
echo "Mesmo JAR, mesmo .properties, comportamento diferente. É assim que se faz em prod."

echo ""
echo "=== Exercício 8: System property ganha de tudo ==="
echo "  java -Dapp.email.remetente=urgente@x.com -jar target/quarkus-app/quarkus-run.jar"
echo "  → remetente: urgente@x.com (vence até a env var)"

echo ""
echo "=== Exercício 9: Profile customizado ==="
echo "  java -Dquarkus.profile=staging -jar target/quarkus-app/quarkus-run.jar"
echo "Adicione no .properties: %staging.app.email.remetente=staging@x.com"
echo "Rebuild e teste."
