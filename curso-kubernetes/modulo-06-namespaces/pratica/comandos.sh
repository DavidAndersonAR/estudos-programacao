#!/usr/bin/env bash
# Módulo 06 — Namespaces
# Prática: subir dev/staging/prod, aplicar quota em dev, navegar entre ns.
#
# PRÉ-REQUISITO: cluster kind rodando (módulo 01).
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Ver namespaces que já existem ==="
kubectl get ns
# Deve aparecer pelo menos: default, kube-system, kube-public, kube-node-lease

echo ""
echo "=== Exercício 2: Criar os 3 ambientes ==="
kubectl apply -f namespaces.yaml
kubectl get ns --show-labels

echo ""
echo "=== Exercício 3: Aplicar quota e LimitRange em dev ==="
kubectl apply -f quota.yaml
kubectl get resourcequota -n dev
kubectl describe quota quota-dev -n dev
# Veja "Used" vs "Hard" — começa zerado.

echo ""
echo "=== Exercício 4: Subir o mesmo app nos 3 ns ==="
kubectl apply -f deployments.yaml

# Espera os deployments ficarem prontos
kubectl rollout status deployment/webapp -n dev --timeout=120s
kubectl rollout status deployment/webapp -n staging --timeout=120s
kubectl rollout status deployment/webapp -n prod --timeout=120s

echo ""
echo "=== Exercício 5: Listar pods em cada ns ==="
echo "--- dev ---"
kubectl get pods -n dev
echo "--- staging ---"
kubectl get pods -n staging
echo "--- prod ---"
kubectl get pods -n prod

echo ""
echo "=== Exercício 6: Listar pods de TODOS os ns ==="
kubectl get pods -A | grep webapp

echo ""
echo "=== Exercício 7: Ver quota de dev sendo consumida ==="
kubectl describe quota quota-dev -n dev
# Used.pods deve ser 2 (réplicas), Used.requests.cpu = 200m, etc.

echo ""
echo "=== Exercício 8: Mudar ns default pra dev (vida mais fácil) ==="
kubectl config set-context --current --namespace=dev
kubectl config view --minify | grep namespace:
# Agora 'kubectl get pods' (sem -n) vai listar dev.
kubectl get pods

echo ""
echo "=== Exercício 9: Tentar estourar a quota (deve FALHAR) ==="
# A quota permite 5 pods em dev. Já temos 2. Vamos escalar pra 6.
kubectl scale deployment/webapp -n dev --replicas=6
sleep 3
kubectl get pods -n dev
# Você vai ver só 5 pods criados — o ReplicaSet tentou criar o 6º e o
# API Server bloqueou. Olhe os eventos:
kubectl get events -n dev --sort-by=.lastTimestamp | tail -10
# Procure por "exceeded quota" ou "forbidden".

echo ""
echo "=== Exercício 10: Voltar pra 2 réplicas ==="
kubectl scale deployment/webapp -n dev --replicas=2

echo ""
echo "=== Exercício 11: DNS cross-namespace ==="
# Subir um busybox em dev e curlar o webapp de prod
kubectl run probe -n dev --image=busybox --restart=Never --command -- sleep 3600
kubectl wait --for=condition=Ready pod/probe -n dev --timeout=60s

# Mesmo ns (dev) — só o nome
kubectl exec -n dev probe -- wget -qO- --timeout=5 http://webapp | head -5

# Cross-ns: webapp.prod
kubectl exec -n dev probe -- wget -qO- --timeout=5 http://webapp.prod | head -5

# FQDN completo
kubectl exec -n dev probe -- wget -qO- --timeout=5 http://webapp.staging.svc.cluster.local | head -5

echo ""
echo "=== Exercício 12: Voltar ns default pra 'default' ==="
kubectl config set-context --current --namespace=default

echo ""
echo "=== Exercício 13: Limpar (opcional) ==="
echo "Pra apagar TUDO de cada ambiente de uma vez:"
echo "  kubectl delete ns dev staging prod"
echo "(isso some com deployments, services, pods, quota, limitrange — tudo)"
