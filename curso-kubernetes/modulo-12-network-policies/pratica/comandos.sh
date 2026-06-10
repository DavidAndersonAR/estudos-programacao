#!/usr/bin/env bash
# Módulo 12 — Network Policies / Prática
# Roteiro:
#   1. Subir apps SEM policy → todo mundo fala com todo mundo
#   2. Aplicar netpol → frontend perde acesso ao db, api mantém
#
# PRÉ-REQUISITO: rodar pratica/setup.sh antes (cluster kind com Calico)

set -e

NS=lab

echo "=== 1. Subir apps (frontend, api, db) ==="
kubectl apply -f pratica/apps.yaml

echo ""
echo "=== 2. Esperar pods prontos ==="
kubectl -n "$NS" wait --for=condition=Ready pod -l app=db --timeout=120s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=api --timeout=60s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=frontend --timeout=60s
kubectl -n "$NS" get pods -o wide

echo ""
echo "=== 3. SEM policy: TUDO conecta no db (cenário inseguro) ==="
echo "--- api → db:5432 (deve conectar) ---"
kubectl -n "$NS" exec deploy/api -- nc -zv -w 3 db 5432 || true
echo "--- frontend → db:5432 (deve conectar — RUIM, é o que vamos consertar) ---"
kubectl -n "$NS" exec deploy/frontend -- nc -zv -w 3 db 5432 || true

echo ""
echo "=== 4. Aplicar NetworkPolicies (default-deny + libera api→db) ==="
kubectl apply -f pratica/netpol.yaml
kubectl -n "$NS" get netpol

echo ""
echo "=== 5. COM policy: testar de novo ==="
echo "--- api → db:5432 (deve continuar conectando — PERMITIDO) ---"
kubectl -n "$NS" exec deploy/api -- nc -zv -w 5 db 5432 || echo "❌ ops, api devia conectar"
echo ""
echo "--- frontend → db:5432 (deve dar TIMEOUT — BLOQUEADO) ---"
# Esperamos que falhe — por isso o || true
kubectl -n "$NS" exec deploy/frontend -- nc -zv -w 5 db 5432 || echo "✅ bloqueado (esperado)"

echo ""
echo "=== 6. Inspecionar as policies ==="
kubectl -n "$NS" describe netpol db-aceita-so-api

echo ""
echo "=== 7. Limpar (opcional) ==="
echo "Para remover só o lab:"
echo "  kubectl delete namespace $NS"
echo "Para apagar o cluster inteiro:"
echo "  kind delete cluster --name netpol-lab"
