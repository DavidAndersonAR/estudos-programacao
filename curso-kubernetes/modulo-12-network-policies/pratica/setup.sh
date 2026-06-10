#!/usr/bin/env bash
# Módulo 12 — Network Policies
# Setup: cluster kind COM suporte a NetworkPolicy (Calico)
#
# Por que: o CNI default do kind (kindnet) ignora NetworkPolicy.
# Você cria a policy, kubectl aceita, e nada acontece. Pra valer
# precisamos de um CNI que implemente — Calico é o mais clássico.
#
# Rode este script UMA vez antes da prática.

set -e

CLUSTER=netpol-lab

echo "=== 1. Apagar cluster antigo (se existir) ==="
kind delete cluster --name "$CLUSTER" || true

echo ""
echo "=== 2. Criar cluster SEM o CNI default ==="
# disableDefaultCNI=true → kind não instala kindnet
# podSubnet → range pros pods (Calico precisa saber)
cat > /tmp/kind-netpol.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "192.168.0.0/16"
nodes:
  - role: control-plane
  - role: worker
EOF

kind create cluster --name "$CLUSTER" --config /tmp/kind-netpol.yaml

echo ""
echo "=== 3. Instalar Calico ==="
# Os nodes ficam NotReady até o CNI subir — normal.
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo ""
echo "=== 4. Esperar Calico ficar pronto (pode demorar 1-2 min) ==="
kubectl -n kube-system wait --for=condition=Ready pod -l k8s-app=calico-node --timeout=180s
kubectl wait --for=condition=Ready node --all --timeout=180s

echo ""
echo "=== 5. Verificar ==="
kubectl get nodes
kubectl get pods -n kube-system | grep -E 'calico|coredns'

echo ""
echo "✅ Cluster '$CLUSTER' pronto com Calico."
echo "Agora rode: bash pratica/comandos.sh"
