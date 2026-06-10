#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 11 — comandos pra testar o roteamento por path
#
# Pré-requisitos:
#   1. Cluster do módulo 11 rodando (setup-kind.sh + ingress-controller.sh)
#   2. /etc/hosts com:  127.0.0.1  app.local.test
#   3. manifestos.yaml preenchido (TODOs feitos)

set -e

echo "=== Passo 1: aplicar os manifestos do desafio ==="
kubectl apply -f manifestos.yaml

echo ""
echo "=== Passo 2: esperar tudo subir ==="
kubectl wait --for=condition=Available deploy/api deploy/static deploy/default --timeout=90s
kubectl get pods,svc,ingress

echo ""
echo "=== Passo 3: testar os 3 paths ==="
echo "-- /api/users --"
curl -s http://app.local.test/api/users
echo "-- /static/logo.png --"
curl -s http://app.local.test/static/logo.png
echo "-- / (catch-all) --"
curl -s http://app.local.test/

echo ""
echo "=== Passo 4: confirmar o que cada um respondeu ==="
echo "Esperado:"
echo "  /api/users      → 'Sou a API 🔌'"
echo "  /static/logo... → 'Conteúdo estático 📁'"
echo "  /              → 'Página padrão 🏠'"

echo ""
echo "=== Passo 5: experimentar com Host header (sem /etc/hosts) ==="
curl -s -H "Host: app.local.test" http://127.0.0.1/api/v1/ping
curl -s -H "Host: app.local.test" http://127.0.0.1/static/css/main.css
curl -s -H "Host: app.local.test" http://127.0.0.1/qualquer/outra/coisa

echo ""
echo "=== Passo 6: limpar (mantém cluster) ==="
echo "  kubectl delete -f manifestos.yaml"
echo ""
echo "Pra apagar o cluster:"
echo "  kind delete cluster --name ingress-lab"

# ============================
# 💡 DICAS DE DEBUG
# ============================
# - Path errado / 404? kubectl describe ingress roteamento-por-path
#   (olha a seção Rules e Events)
# - Controller não acordou? kubectl get pods -n ingress-nginx
# - Bate no Service direto pra confirmar que o app responde:
#     kubectl port-forward svc/api 8080:80
#     curl localhost:8080
# - Logs do nginx em tempo real:
#     kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f
