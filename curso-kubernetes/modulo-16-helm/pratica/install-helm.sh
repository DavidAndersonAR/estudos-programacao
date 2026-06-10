#!/usr/bin/env bash
# Módulo 16 — Helm
# Instalação do Helm (Windows / Linux / Mac)
#
# Roda só uma vez antes da prática.

set -e

echo "=== Instalar Helm ==="
echo ""
echo "Windows (PowerShell):"
echo "  winget install Helm.Helm"
echo ""
echo "Mac:"
echo "  brew install helm"
echo ""
echo "Linux (script oficial):"
echo "  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
echo ""

echo "=== Verificar instalação ==="
helm version

echo ""
echo "=== Adicionar repos públicos úteis ==="
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update
helm repo list

echo ""
echo "Helm pronto. Veja pratica/comandos.sh."
