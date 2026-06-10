#!/usr/bin/env bash
# Módulo 16 — Helm
# Pratica: criar/instalar/atualizar/rollback do chart "meuapp"
#
# PRE-REQUISITO:
#   - cluster kind rodando (kind create cluster --name estudo)
#   - helm instalado (veja install-helm.sh)
#
# Rode linha a linha pra acompanhar.

set -e

CHART=./meuapp
REL=meuapp

echo "=== Exercicio 1: Inspecionar o chart ==="
ls -la $CHART
helm lint $CHART          # valida sintaxe e boas praticas
helm template $REL $CHART # renderiza local (sem aplicar) — bom pra debugar

echo ""
echo "=== Exercicio 2: Instalar a release ==="
# upgrade --install = idempotente. Instala se nao existe, atualiza se existe.
helm upgrade --install $REL $CHART
helm list

echo ""
echo "=== Exercicio 3: Ver o que foi aplicado no cluster ==="
kubectl get deploy,svc,pod -l app=meuapp
helm status $REL
helm get values $REL      # values usados nessa release

echo ""
echo "=== Exercicio 4: Upgrade com --set (escalar pra 5 replicas) ==="
helm upgrade --install $REL $CHART --set replicaCount=5
kubectl get pods -l app=meuapp
helm history $REL         # ja deve mostrar 2 revisoes

echo ""
echo "=== Exercicio 5: Upgrade trocando a tag da imagem ==="
helm upgrade --install $REL $CHART \
  --set replicaCount=3 \
  --set image.tag=stable-alpine
kubectl rollout status deploy/$REL-meuapp
helm history $REL

echo ""
echo "=== Exercicio 6: Rollback pra revisao 1 (estado inicial) ==="
helm rollback $REL 1
kubectl get pods -l app=meuapp
helm history $REL         # rollback tambem vira uma revisao nova

echo ""
echo "=== Exercicio 7: Override via arquivo (dry-run) ==="
# Cria um values alternativo na hora e simula
cat > /tmp/values-extra.yaml <<EOF
replicaCount: 4
service:
  type: NodePort
EOF
helm upgrade --install $REL $CHART -f /tmp/values-extra.yaml --dry-run | head -40

echo ""
echo "=== Exercicio 8: Limpar ==="
helm uninstall $REL
kubectl get all -l app=meuapp
echo ""
echo "Tudo limpo. Bora pro desafio."
