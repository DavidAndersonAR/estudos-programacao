#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 13 — Testes da SA "ci-bot"
#
# Use este script DEPOIS de aplicar `manifestos.yaml` (com sua solução
# descomentada). Ele valida que:
#   - ci-bot CONSEGUE criar/atualizar/ver deployments em apps-prod
#   - ci-bot NÃO CONSEGUE deletar deployments
#   - ci-bot NÃO CONSEGUE ler secrets
#   - ci-bot NÃO CONSEGUE mexer em outros namespaces

set -u
NS=apps-prod
SA=ci-bot
SUBJECT="system:serviceaccount:${NS}:${SA}"

ok()   { printf "  ✅ %s\n" "$1"; }
fail() { printf "  ❌ %s\n" "$1"; }

# Helper: espera "yes" e marca ok; ou imprime fail.
expect_yes() {
  local desc="$1"; shift
  local out
  out=$(kubectl auth can-i "$@" --as="$SUBJECT" 2>/dev/null || true)
  if [ "$out" = "yes" ]; then ok "$desc (yes)"; else fail "$desc — esperado yes, veio: $out"; fi
}

expect_no() {
  local desc="$1"; shift
  local out
  out=$(kubectl auth can-i "$@" --as="$SUBJECT" 2>/dev/null || true)
  if [ "$out" = "no" ]; then ok "$desc (no)"; else fail "$desc — esperado no, veio: $out"; fi
}

echo "=== Aplicando manifestos ==="
kubectl apply -f manifestos.yaml

echo ""
echo "=== Verificando objetos criados ==="
kubectl get sa,role,rolebinding -n "$NS" 2>/dev/null || true

echo ""
echo "=== Testes de permissão (kubectl auth can-i) ==="

# ✅ Deve poder
expect_yes "criar deployments em $NS"     create deployments.apps -n "$NS"
expect_yes "atualizar deployments em $NS" update deployments.apps -n "$NS"
expect_yes "patch deployments em $NS"     patch  deployments.apps -n "$NS"
expect_yes "list deployments em $NS"      list   deployments.apps -n "$NS"
expect_yes "get deployments em $NS"       get    deployments.apps -n "$NS"

# ❌ Não deve poder
expect_no "deletar deployments em $NS"    delete deployments.apps -n "$NS"
expect_no "ler secrets em $NS"            get    secrets          -n "$NS"
expect_no "listar secrets em $NS"         list   secrets          -n "$NS"
expect_no "criar deployments em default"  create deployments.apps -n default
expect_no "listar pods em kube-system"    list   pods             -n kube-system

echo ""
echo "=== Teste prático: criar deployment real como ci-bot ==="
cat <<'YAML' | kubectl --as="$SUBJECT" -n "$NS" apply -f - && \
  ok "deployment criado pela SA ci-bot" || fail "criação falhou inesperadamente"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-demo
spec:
  replicas: 1
  selector: { matchLabels: { app: demo } }
  template:
    metadata: { labels: { app: demo } }
    spec:
      containers:
      - name: web
        image: nginx:alpine
YAML

echo ""
echo "=== Teste prático: ci-bot tentando deletar (DEVE FALHAR) ==="
if kubectl --as="$SUBJECT" -n "$NS" delete deployment app-demo 2>&1 | grep -qi forbidden; then
  ok "delete foi negado com Forbidden (como esperado)"
else
  fail "delete não foi negado — revise a Role"
fi

echo ""
echo "=== Limpeza (admin apaga o que sobrou) ==="
kubectl delete deployment app-demo -n "$NS" --ignore-not-found
echo "Pra zerar o lab: kubectl delete namespace $NS"
