#!/usr/bin/env bash
# Módulo 11 — Ingress
# Prática parte 3: aplicar apps + Ingress e testar roteamento por host
#
# Pré-requisitos (na ordem):
#   1. ./setup-kind.sh           — cluster com portas 80/443
#   2. ./ingress-controller.sh   — nginx-ingress instalado
#   3. Adicionar no hosts:       127.0.0.1  app1.local.test app2.local.test

set -e

echo "=== Exercício 1: Aplicar Deployments + Services ==="
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml

echo ""
echo "=== Exercício 2: Esperar pods subirem ==="
kubectl wait --for=condition=Available deploy/app1 deploy/app2 --timeout=90s
kubectl get pods,svc

echo ""
echo "=== Exercício 3: Criar o Ingress ==="
kubectl apply -f ingress.yaml
kubectl get ingress
kubectl describe ingress roteamento-por-host | head -40

echo ""
echo "=== Exercício 4: Testar via Host header (sem mexer no hosts) ==="
# Truque clássico: bate em 127.0.0.1 forçando o header Host.
# Útil pra debug rápido — mesmo sem editar /etc/hosts.
curl -s -H "Host: app1.local.test" http://127.0.0.1/
curl -s -H "Host: app2.local.test" http://127.0.0.1/

echo ""
echo "=== Exercício 5: Testar via DNS (precisa do /etc/hosts editado) ==="
echo "Se você adicionou em hosts, isto deve funcionar:"
curl -s http://app1.local.test/ || echo "(falhou — confere /etc/hosts)"
curl -s http://app2.local.test/ || echo "(falhou — confere /etc/hosts)"

echo ""
echo "=== Exercício 6: Verificar logs do controller (opcional) ==="
echo "Comando útil pra debugar:"
echo "  kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=20"

echo ""
echo "=== Exercício 7: Limpar (mantém cluster pro desafio) ==="
echo "Pra apagar só os objetos:"
echo "  kubectl delete -f ingress.yaml -f app2.yaml -f app1.yaml"
echo ""
echo "Pra destruir o cluster inteiro (recomeçar do zero):"
echo "  kind delete cluster --name ingress-lab"
