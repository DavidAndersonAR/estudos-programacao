#!/usr/bin/env bash
# Módulo 11 — Ingress
# Prática parte 2: instalar nginx-ingress controller
#
# K8s NÃO vem com Ingress Controller. Tem que instalar manualmente.
# Vamos usar o ingress-nginx oficial — manifesto pré-configurado pro kind.
#
# Pré-requisito: rodou setup-kind.sh.

set -e

echo "=== Instalando ingress-nginx (versão pré-configurada pro kind) ==="
# Manifesto oficial — cria namespace ingress-nginx + controller + IngressClass
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo ""
echo "=== Esperando controller ficar pronto (até 2 minutos) ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo ""
echo "=== Verificando ==="
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get ingressclass

echo ""
echo "✅ Controller rodando. Agora aplicar os apps:"
echo "   kubectl apply -f app1.yaml"
echo "   kubectl apply -f app2.yaml"
echo "   kubectl apply -f ingress.yaml"
echo ""
echo "⚠️  Adicione no seu /etc/hosts (ou C:\\Windows\\System32\\drivers\\etc\\hosts):"
echo "   127.0.0.1  app1.local.test app2.local.test"
