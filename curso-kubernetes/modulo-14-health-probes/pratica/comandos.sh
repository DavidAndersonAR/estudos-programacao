#!/usr/bin/env bash
# Módulo 14 — Prática: self-healing na real
#
# Vamos:
#  1. Aplicar o deployment com 3 probes configurados
#  2. Ver o pod ficando Ready
#  3. "Matar" a saúde dele e ver K8s reiniciando automaticamente
#  4. "Matar" só a readiness e ver pod sumindo do Service (mas vivo)
#
# Pré-requisito: cluster do módulo 1 rodando (kind-estudo).

set -e

cd "$(dirname "$0")"

echo "=== Exercício 1: Aplicar o deployment ==="
kubectl apply -f deployment.yaml

echo ""
echo "=== Exercício 2: Esperar ficar Ready ==="
# Note que esse wait usa a CONDITION=Ready, que é exatamente o que a readinessProbe controla.
kubectl wait --for=condition=Ready pod -l app=app-saudavel --timeout=120s
kubectl get pods -l app=app-saudavel -o wide

echo ""
echo "=== Exercício 3: Ver as probes configuradas ==="
# Procure por "Liveness:", "Readiness:", "Startup:" no output
kubectl describe pod -l app=app-saudavel | grep -A 1 -E "(Liveness|Readiness|Startup):"

echo ""
echo "=== Exercício 4: Confirmar Service tem endpoint ==="
# Deve listar 1 IP — o do pod saudável
kubectl get endpoints app-saudavel

echo ""
echo "=== Exercício 5: Quebrar a READINESS (só remove do Service) ==="
POD=$(kubectl get pod -l app=app-saudavel -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $POD"
echo "Apagando /tmp/ready dentro do pod..."
kubectl exec "$POD" -- rm /tmp/ready

echo "Esperando ~10s pra readiness detectar..."
sleep 10

echo "--- Status do pod (deve estar Running mas READY 0/1) ---"
kubectl get pod "$POD"

echo "--- Endpoints do Service (deve estar VAZIO) ---"
kubectl get endpoints app-saudavel
echo "Reparou? Pod CONTINUA VIVO, mas o Service não envia tráfego mais."

echo ""
echo "=== Exercício 6: Recuperar readiness ==="
kubectl exec "$POD" -- touch /tmp/ready
sleep 8
kubectl get pod "$POD"
kubectl get endpoints app-saudavel
echo "Voltou pro pool sozinho."

echo ""
echo "=== Exercício 7: Quebrar a LIVENESS (força reinício) ==="
echo "Pegando contador de restarts ANTES..."
RESTARTS_ANTES=$(kubectl get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "Restarts antes: $RESTARTS_ANTES"

echo "Apagando /tmp/healthy..."
kubectl exec "$POD" -- rm /tmp/healthy

echo "Esperando ~25s (3 falhas × 5s + grace)..."
sleep 25

echo "--- Status do pod agora ---"
kubectl get pod "$POD"
RESTARTS_DEPOIS=$(kubectl get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "Restarts depois: $RESTARTS_DEPOIS"
echo "Se RESTARTS subiu, K8s te curou sozinho. Self-healing funcionando."

echo ""
echo "=== Exercício 8: Ver os Events (a história completa) ==="
kubectl describe pod "$POD" | tail -20

echo ""
echo "=== Limpar ==="
echo "Quando terminar:"
echo "  kubectl delete -f deployment.yaml"
