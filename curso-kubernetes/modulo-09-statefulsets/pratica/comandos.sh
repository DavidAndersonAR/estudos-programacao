#!/usr/bin/env bash
# Módulo 09 — StatefulSets (Prática)
# Subir um StatefulSet de nginx com 3 réplicas + Headless Service
# e ver na prática nome estável + DNS por pod.
#
# Pré-requisito: cluster kind rodando (modulo-01).

set -e

echo "=== Exercício 1: Aplicar Headless Service + StatefulSet ==="
kubectl apply -f headless-svc.yaml
kubectl apply -f statefulset.yaml

echo ""
echo "=== Exercício 2: Observar a criação SEQUENCIAL dos pods ==="
# Diferente do Deployment, os pods sobem em ordem: nginx-0, depois 1, depois 2.
# Use -w pra ver em tempo real (Ctrl+C pra sair quando os 3 estiverem Running).
echo "Rode em outro terminal: kubectl get pods -w"
kubectl rollout status statefulset/nginx --timeout=120s

echo ""
echo "=== Exercício 3: Ver os pods e seus nomes ordinais ==="
kubectl get pods -l app=web -o wide
# Repare: nginx-0, nginx-1, nginx-2 — não tem hash aleatório.

echo ""
echo "=== Exercício 4: Confirmar que o Service é headless ==="
kubectl get svc app-svc
# CLUSTER-IP deve aparecer como <none>

echo ""
echo "=== Exercício 5: Subir um pod auxiliar pra testar DNS ==="
# busybox pra fazer nslookup de dentro do cluster
kubectl run dns-test --image=busybox:1.36 --restart=Never --command -- sleep 3600
kubectl wait --for=condition=Ready pod/dns-test --timeout=60s

echo ""
echo "=== Exercício 6: nslookup do Service (lista todos os pods) ==="
# O headless service retorna os IPs dos 3 pods.
kubectl exec dns-test -- nslookup app-svc

echo ""
echo "=== Exercício 7: nslookup dos PODS INDIVIDUAIS (a mágica) ==="
# Cada pod tem DNS próprio: nome-do-pod.nome-do-service
kubectl exec dns-test -- nslookup nginx-0.app-svc
kubectl exec dns-test -- nslookup nginx-1.app-svc
kubectl exec dns-test -- nslookup nginx-2.app-svc

echo ""
echo "=== Exercício 8: Acessar um pod específico via DNS ==="
# wget direto no nginx-0, depois nginx-2 — pega o HTML
kubectl exec dns-test -- wget -qO- nginx-0.app-svc | head -5
echo "---"
kubectl exec dns-test -- wget -qO- nginx-2.app-svc | head -5

echo ""
echo "=== Exercício 9: Provar a identidade estável ==="
# Deleta nginx-1 e observa: o substituto vai se chamar nginx-1 de novo.
kubectl delete pod nginx-1
kubectl wait --for=condition=Ready pod/nginx-1 --timeout=60s
kubectl get pods -l app=web
# Mesmo nome. Mesmo DNS. Identidade preservada.

echo ""
echo "=== Exercício 10: Limpar ==="
kubectl delete pod dns-test
kubectl delete -f statefulset.yaml
kubectl delete -f headless-svc.yaml
# Como neste exercício NÃO usamos volumeClaimTemplates, nada de PVC sobrou.
