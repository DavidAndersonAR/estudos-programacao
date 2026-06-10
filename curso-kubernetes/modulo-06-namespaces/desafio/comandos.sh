#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 06 — Dois times, quotas diferentes, services cruzando ns
#
# Cenário:
#   - Sua empresa criou dois times: time-a (pequeno) e time-b (grande).
#   - Cada um tem seu namespace e roda uma "api" própria.
#   - A api do time-a precisa CONSULTAR a api do time-b (e vice-versa).
#   - Você (plataforma) precisa garantir que cada time não estoure recursos.
#
# Sua missão:
#
# 1. Aplique desafio/manifestos.yaml (cria os 2 ns + deployments + services)
# 2. Crie ResourceQuotas DIFERENTES:
#    - time-a: pods=3,  requests.cpu=1, requests.memory=2Gi
#    - time-b: pods=8,  requests.cpu=4, requests.memory=8Gi
#    DICA: você pode criar a quota inline com `kubectl apply -f -` + heredoc,
#          ou salvar em arquivo. Sua escolha.
# 3. Confirme que os deployments subiram em ambos os ns
# 4. Suba 1 pod "client" em CADA ns (use busybox + sleep) pra testar
# 5. Do client de time-a, faça wget pro service api.time-b.svc.cluster.local
# 6. Do client de time-b, faça wget pro service api.time-a
# 7. Tente escalar o deployment de time-a pra 5 réplicas — deve FALHAR
#    (quota só permite 3 pods, e o client busybox já ocupa 1)
# 8. Apague tudo deletando só os 2 namespaces
#
# 💡 Dicas:
#   - Service em outro ns: SERVICE.NAMESPACE (ex: api.time-b)
#   - http-echo escuta em :8080 e responde texto
#   - kubectl run NOME --image=busybox --restart=Never --command -- sleep 3600
#   - pra ver o erro de quota: kubectl get events -n time-a --sort-by=.lastTimestamp
#   - kubectl describe rs (replicaset) também mostra o motivo da falha

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: aplicar manifestos.yaml"
# kubectl apply -f manifestos.yaml

echo "TODO 2: criar quotas diferentes pros 2 times"
# kubectl apply -f - <<EOF
# ...
# EOF

echo "TODO 3: ver deployments"
# kubectl get deploy -n time-a
# kubectl get deploy -n time-b

echo "TODO 4: subir 2 clients busybox"
# kubectl run client -n time-a --image=busybox --restart=Never --command -- sleep 3600
# kubectl run client -n time-b --image=busybox --restart=Never --command -- sleep 3600

echo "TODO 5: time-a -> time-b"
# kubectl exec -n time-a client -- wget -qO- api.time-b.svc.cluster.local:8080

echo "TODO 6: time-b -> time-a"
# kubectl exec -n time-b client -- wget -qO- api.time-a:8080

echo "TODO 7: estourar a quota de time-a"
# kubectl scale deploy/api -n time-a --replicas=5
# kubectl get events -n time-a --sort-by=.lastTimestamp | tail -5

echo "TODO 8: limpar"
# kubectl delete ns time-a time-b

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Cria ns + deployments + services
kubectl apply -f manifestos.yaml

# 2. Quotas diferentes — usando heredoc
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-time-a
  namespace: time-a
spec:
  hard:
    pods: "3"
    requests.cpu: "1"
    requests.memory: 2Gi
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-time-b
  namespace: time-b
spec:
  hard:
    pods: "8"
    requests.cpu: "4"
    requests.memory: 8Gi
EOF

# Confere as quotas
kubectl describe quota -n time-a
kubectl describe quota -n time-b

# 3. Espera deployments
kubectl rollout status deploy/api -n time-a --timeout=120s
kubectl rollout status deploy/api -n time-b --timeout=120s
kubectl get deploy -A | grep api

# 4. Clients pra testar (precisam de requests pra passar na quota)
kubectl run client -n time-a --image=busybox --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"client","image":"busybox","command":["sleep","3600"],"resources":{"requests":{"cpu":"50m","memory":"64Mi"},"limits":{"cpu":"100m","memory":"128Mi"}}}]}}'
kubectl run client -n time-b --image=busybox --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"client","image":"busybox","command":["sleep","3600"],"resources":{"requests":{"cpu":"50m","memory":"64Mi"},"limits":{"cpu":"100m","memory":"128Mi"}}}]}}'

kubectl wait --for=condition=Ready pod/client -n time-a --timeout=60s
kubectl wait --for=condition=Ready pod/client -n time-b --timeout=60s

# 5. Cross-namespace: time-a chama time-b (FQDN completo)
echo "--- time-a -> time-b ---"
kubectl exec -n time-a client -- wget -qO- --timeout=5 api.time-b.svc.cluster.local:8080
# Deve imprimir: hello from time-b

# 6. Cross-namespace: time-b chama time-a (forma curta também funciona)
echo "--- time-b -> time-a ---"
kubectl exec -n time-b client -- wget -qO- --timeout=5 api.time-a:8080
# Deve imprimir: hello from time-a

# 7. Forçar estouro de quota em time-a
# time-a tem quota=3 pods. Já temos 2 (api) + 1 (client) = 3.
# Subir pra 5 réplicas vai pedir 5 pods de api + 1 client = 6 > 3.
kubectl scale deploy/api -n time-a --replicas=5
sleep 3
echo "--- pods em time-a (devia ter 3 no máx) ---"
kubectl get pods -n time-a
echo "--- eventos (procure 'exceeded quota' / 'forbidden') ---"
kubectl get events -n time-a --sort-by=.lastTimestamp | tail -10
echo "--- e o replicaset reclamando ---"
kubectl describe rs -n time-a | grep -A2 "FailedCreate" || true

# Volta pra 2
kubectl scale deploy/api -n time-a --replicas=2

# 8. Limpar TUDO deletando só os ns
kubectl delete ns time-a time-b
SOLUTION
