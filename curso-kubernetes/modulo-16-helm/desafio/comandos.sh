#!/usr/bin/env bash
# 🎯 DESAFIO DO MODULO 16 — Chart "webapp" multi-ambiente
#
# Objetivo:
# Empacotar uma webapp completa em um chart Helm e instalar dois perfis
# (dev e prod) lado a lado no mesmo cluster, com configuracoes diferentes.
#
# Cenario:
#   - 1 Deployment (nginx)
#   - 1 Service
#   - 1 ConfigMap com variaveis (APP_ENV, LOG_LEVEL, WELCOME_MSG)
#   - 1 Ingress CONDICIONAL (so em prod)
#   - Labels padrao (app.kubernetes.io/*) via helper
#
# Voce vai:
#   1. Validar o chart (lint + template)
#   2. Instalar "webapp-dev" usando values-dev.yaml
#   3. Instalar "webapp-prod" usando values-prod.yaml no namespace "prod"
#   4. Conferir que so a release prod criou Ingress
#   5. Mudar o WELCOME_MSG do dev via --set e ver o pod fazer rollout
#      (graca a annotation checksum/config no Deployment)
#   6. Fazer rollback do dev pra revisao 1
#   7. Limpar tudo
#
# 💡 Dicas:
#   - helm lint ./manifestos
#   - helm template TESTE ./manifestos -f manifestos/values-prod.yaml
#   - --create-namespace cria o ns na hora do install
#   - helm list -A pra ver releases de todos os namespaces

set -e
CHART=./manifestos

# ============================
# SUA SOLUCAO ABAIXO
# ============================

echo "TODO 1: lint + template dry-run com values-prod"
# helm lint ...
# helm template ...

echo "TODO 2: instalar webapp-dev (default namespace, values-dev)"
# helm upgrade --install ...

echo "TODO 3: instalar webapp-prod (namespace prod, values-prod)"
# helm upgrade --install ... --namespace prod --create-namespace ...

echo "TODO 4: listar e conferir Ingress"
# helm list -A
# kubectl get ingress -A

echo "TODO 5: mudar WELCOME_MSG no dev e ver rollout"
# helm upgrade webapp-dev ... --set config.WELCOME_MSG="Oi turma"
# kubectl rollout status deploy/...

echo "TODO 6: rollback do dev pra revisao 1"
# helm history webapp-dev
# helm rollback webapp-dev 1

echo "TODO 7: limpar tudo"
# helm uninstall webapp-dev
# helm uninstall webapp-prod -n prod
# kubectl delete ns prod

# ============================
# SOLUCAO DE REFERENCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1) Validar
helm lint $CHART
helm template teste $CHART -f $CHART/values-prod.yaml | head -60

# 2) Instalar release DEV
helm upgrade --install webapp-dev $CHART \
  -f $CHART/values-dev.yaml

kubectl rollout status deploy/webapp-dev-webapp

# 3) Instalar release PROD num namespace separado
helm upgrade --install webapp-prod $CHART \
  -f $CHART/values-prod.yaml \
  --namespace prod --create-namespace

kubectl rollout status deploy/webapp-prod-webapp -n prod

# 4) Conferir tudo
helm list -A
kubectl get deploy,svc,cm -A -l app.kubernetes.io/name=webapp
# Ingress so deve aparecer em prod:
kubectl get ingress -A

# 5) Mudar config do dev — vai forcar rollout pelo hash da annotation
helm upgrade webapp-dev $CHART \
  -f $CHART/values-dev.yaml \
  --set config.WELCOME_MSG="Oi turma"

kubectl rollout status deploy/webapp-dev-webapp
helm history webapp-dev
# Confere a env var dentro do pod:
POD=$(kubectl get pod -l app.kubernetes.io/instance=webapp-dev -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD -- printenv | grep -E 'APP_ENV|WELCOME|LOG_LEVEL'

# 6) Rollback do dev pra revisao 1
helm history webapp-dev
helm rollback webapp-dev 1
helm history webapp-dev
POD=$(kubectl get pod -l app.kubernetes.io/instance=webapp-dev -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD -- printenv | grep WELCOME   # deve voltar pro msg original do dev

# 7) Limpar
helm uninstall webapp-dev
helm uninstall webapp-prod -n prod
kubectl delete ns prod
SOLUTION
