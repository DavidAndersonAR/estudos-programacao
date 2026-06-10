#!/usr/bin/env bash
# Módulo 13 — RBAC e Service Accounts
# Prática: SA "ler-pods" com permissão mínima (só listar pods)
#
# Pré-requisito: cluster kind rodando (módulo 01).
# Rode linha a linha pra acompanhar.

set -e
NS=rbac-lab
SA=ler-pods

echo "=== Exercício 1: Criar namespace de laboratório ==="
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Exercício 2: Aplicar SA, Role e RoleBinding ==="
kubectl apply -f sa.yaml
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml

kubectl get sa,role,rolebinding -n "$NS"

echo ""
echo "=== Exercício 3: Testar permissões com can-i (sem subir pod ainda) ==="
# Lembrete: nome completo da SA é system:serviceaccount:<ns>:<nome>
SUBJECT="system:serviceaccount:${NS}:${SA}"

echo "-- Pode listar pods em $NS?"
kubectl auth can-i list pods --as="$SUBJECT" -n "$NS"   # yes

echo "-- Pode criar pods em $NS?"
kubectl auth can-i create pods --as="$SUBJECT" -n "$NS" # no

echo "-- Pode listar pods em outro namespace (kube-system)?"
kubectl auth can-i list pods --as="$SUBJECT" -n kube-system # no (Role é namespaced)

echo "-- Pode ler secrets em $NS?"
kubectl auth can-i get secrets --as="$SUBJECT" -n "$NS" # no

echo "-- Tudo que essa SA pode fazer em $NS:"
kubectl auth can-i --list --as="$SUBJECT" -n "$NS" | head -20

echo ""
echo "=== Exercício 4: Subir o pod que usa essa SA ==="
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/cliente-api -n "$NS" --timeout=90s

echo ""
echo "=== Exercício 5: Do DENTRO do pod, bater no API Server ==="
# O token da SA está montado pelo kubelet.
# Testa: listar pods do próprio namespace (deve funcionar).

kubectl exec -n "$NS" cliente-api -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CA=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  API=https://kubernetes.default.svc

  echo ">> GET /api/v1/namespaces/$NS/pods (deve dar 200 + lista)"
  curl -s -o /tmp/out.json -w "HTTP %{http_code}\n" \
    --cacert $CA -H "Authorization: Bearer $TOKEN" \
    "$API/api/v1/namespaces/$NS/pods"
  echo "Itens encontrados: $(grep -o "\"kind\":\"Pod\"" /tmp/out.json | wc -l)"
'

echo ""
echo "=== Exercício 6: Tentar criar pod via API (deve dar 403 Forbidden) ==="
kubectl exec -n "$NS" cliente-api -- sh -c '
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CA=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  API=https://kubernetes.default.svc

  echo ">> POST /api/v1/namespaces/$NS/pods (deve dar 403)"
  curl -s -o /tmp/err.json -w "HTTP %{http_code}\n" \
    --cacert $CA -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -X POST "$API/api/v1/namespaces/$NS/pods" \
    -d "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"name\":\"vai-falhar\"},\"spec\":{\"containers\":[{\"name\":\"c\",\"image\":\"nginx\"}]}}"
  echo "Mensagem do API Server:"
  cat /tmp/err.json
'

echo ""
echo "=== Exercício 7: Limpar ==="
echo "Pra apagar tudo do laboratório:"
echo "  kubectl delete namespace $NS"
