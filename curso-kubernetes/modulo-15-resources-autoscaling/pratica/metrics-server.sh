#!/usr/bin/env bash
# Módulo 15 — Instalar metrics-server no kind
#
# O HPA precisa de métricas de uso de CPU/memória dos pods.
# Quem fornece isso é o metrics-server. Ele NÃO vem instalado em kind/minikube.
#
# Em cluster gerenciado (EKS, GKE, AKS) geralmente já vem. Em kind, precisa
# adicionar a flag --kubelet-insecure-tls porque o cert do kubelet é self-signed.

set -e

echo "=== 1. Aplicando manifest oficial do metrics-server ==="
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo ""
echo "=== 2. Patchando deployment pra aceitar cert inseguro (kind) ==="
# Adiciona --kubelet-insecure-tls na lista de args do container.
# SÓ FAÇA ISSO EM DEV/KIND. Em produção, configure cert correto.
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo ""
echo "=== 3. Esperando rollout terminar ==="
kubectl rollout status -n kube-system deployment/metrics-server --timeout=120s

echo ""
echo "=== 4. Esperando primeiras métricas aparecerem (~30s) ==="
# Loop curto até `kubectl top nodes` parar de dar erro.
for i in {1..20}; do
  if kubectl top nodes >/dev/null 2>&1; then
    echo "Métricas disponíveis!"
    break
  fi
  echo "  ainda não... ($i/20)"
  sleep 3
done

echo ""
echo "=== 5. Testando ==="
kubectl top nodes
echo ""
kubectl top pods -A | head -10

echo ""
echo "Pronto. Agora o HPA vai conseguir ler métricas."
