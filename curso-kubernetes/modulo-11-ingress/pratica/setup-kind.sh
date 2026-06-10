#!/usr/bin/env bash
# Módulo 11 — Ingress
# Prática parte 1: subir cluster kind com portas 80/443 expostas
#
# kind roda dentro de Docker. Por padrão NADA do cluster sai pro host.
# Pra acessar o Ingress de localhost, precisamos:
#   1. Expor portas 80 e 443 do node pra o host (extraPortMappings)
#   2. Marcar o node como "ingress-ready" (label que o nginx-ingress procura)
#
# Rode UMA vez. Depois pula direto pro ingress-controller.sh.

set -e

CLUSTER_NAME="ingress-lab"

echo "=== Apagando cluster antigo se existir ==="
kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true

echo ""
echo "=== Criando config do kind ==="
cat > /tmp/kind-ingress-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

echo ""
echo "=== Subindo cluster $CLUSTER_NAME (demora ~30s) ==="
kind create cluster --name "$CLUSTER_NAME" --config /tmp/kind-ingress-config.yaml

echo ""
echo "=== Verificando ==="
kubectl cluster-info --context "kind-$CLUSTER_NAME"
kubectl get nodes --show-labels | grep ingress-ready

echo ""
echo "✅ Cluster pronto. Próximo passo: ./ingress-controller.sh"
