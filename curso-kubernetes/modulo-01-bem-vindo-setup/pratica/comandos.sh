#!/usr/bin/env bash
# Módulo 01 — Bem-vindo + Setup
# Prática: subir cluster com kind e rodar primeiro pod
#
# PRÉ-REQUISITO: instale kind antes
#   winget install Kubernetes.kind
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Verificar ferramentas ==="
kubectl version --client | head -3
kind version

echo ""
echo "=== Exercício 2: Criar cluster local ==="
# --name dá um nome (default é "kind"). Vamos chamar de "estudo".
kind create cluster --name estudo

echo ""
echo "=== Exercício 3: Ver info do cluster ==="
kubectl cluster-info
kubectl get nodes
kubectl config current-context  # deve ser kind-estudo

echo ""
echo "=== Exercício 4: Primeiro pod (imperativo) ==="
kubectl run meu-nginx --image=nginx:alpine
kubectl get pods

# Espera ficar Ready (pode demorar uns segundos pra baixar imagem)
kubectl wait --for=condition=Ready pod/meu-nginx --timeout=60s

echo ""
echo "=== Exercício 5: Inspecionar pod ==="
kubectl describe pod meu-nginx | head -30
kubectl logs meu-nginx | head -5

echo ""
echo "=== Exercício 6: Port-forward (acessar localmente) ==="
echo "Rode em outro terminal: kubectl port-forward meu-nginx 8080:80"
echo "E abra http://localhost:8080"
echo "(Pulando aqui pra não bloquear o script)"

echo ""
echo "=== Exercício 7: Limpar ==="
kubectl delete pod meu-nginx
echo ""
echo "Para destruir o cluster inteiro (libera RAM/CPU):"
echo "  kind delete cluster --name estudo"
