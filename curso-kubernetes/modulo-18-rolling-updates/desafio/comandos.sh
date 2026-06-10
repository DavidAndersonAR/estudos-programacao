#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 18 — Blue/Green + Canary manuais
#
# Pré-requisito: cluster kind rodando.
#
# ===========================================================================
# PARTE A — BLUE/GREEN
# ===========================================================================
#
# 1. Aplicar blue-green.yaml (sobe blue + green + service "shop" apontando blue)
# 2. Confirmar que o Service "shop" só retorna "BLUE v1"
# 3. Confirmar que o Service "shop-preview" só retorna "GREEN v2"
#    (preview existe pra testar a versão nova SEM mexer no tráfego principal)
# 4. CUTOVER: mudar o selector do Service "shop" pra version=green
# 5. Confirmar que "shop" agora retorna "GREEN v2"
# 6. ROLLBACK: voltar selector pra version=blue
# 7. Confirmar que voltou pra "BLUE v1"
#
# Dicas:
#   - Pra testar sem expor nada: kubectl run curlbox --rm -it --image=curlimages/curl -- sh
#     e dentro: curl http://shop.default.svc.cluster.local
#   - Pra patch do selector: kubectl patch service shop -p '{"spec":{"selector":{"app":"shop","version":"green"}}}'
#
# ===========================================================================
# PARTE B — CANARY
# ===========================================================================
#
# 1. Aplicar canary.yaml (4 réplicas v1 + 1 réplica v2 + Service "api")
# 2. Fazer 20 requisições pro Service e contar quantas vão pra v2
#    (espera-se ~20% — pode variar por causa do round-robin do kube-proxy)
# 3. Promover canary: escalar v2 pra 2 réplicas (ratio v1:v2 fica 4:2 = ~33%)
# 4. Promover mais: v2 pra 4 réplicas (4:4 = 50%)
# 5. Promover pra 100%: escalar v2 pra 5 e v1 pra 0
# 6. Limpar: deletar api-v1 (promoção concluída, v2 vira o novo "stable")
# 7. (Alternativa de rollback): escalar v2 pra 0, v1 volta a receber 100%
#
# Dicas:
#   - kubectl scale deployment/api-v1 --replicas=4
#   - Loop de teste em shell:
#       for i in $(seq 1 20); do
#         kubectl exec curlbox -- curl -s http://api/
#       done | sort | uniq -c

set -e

cd "$(dirname "$0")"

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO A1: aplicar blue-green.yaml"
# kubectl apply -f blue-green.yaml

echo "TODO A2-A3: subir curlbox e testar shop + shop-preview"
# kubectl run curlbox --image=curlimages/curl --command -- sleep 3600
# kubectl wait --for=condition=Ready pod/curlbox --timeout=60s
# kubectl exec curlbox -- curl -s http://shop/
# kubectl exec curlbox -- curl -s http://shop-preview/

echo "TODO A4-A5: cutover pra green"
# kubectl patch service shop -p '{"spec":{"selector":{"app":"shop","version":"green"}}}'
# kubectl exec curlbox -- curl -s http://shop/

echo "TODO A6-A7: rollback pra blue"
# kubectl patch service shop -p '{"spec":{"selector":{"app":"shop","version":"blue"}}}'

echo ""
echo "TODO B1: aplicar canary.yaml"
# kubectl apply -f canary.yaml

echo "TODO B2: bater 20x no Service api e contar a distribuição"
# for i in $(seq 1 20); do kubectl exec curlbox -- curl -s http://api/; done | sort | uniq -c

echo "TODO B3-B5: promover gradualmente"
# kubectl scale deployment/api-v2 --replicas=2
# kubectl scale deployment/api-v2 --replicas=4
# kubectl scale deployment/api-v2 --replicas=5 && kubectl scale deployment/api-v1 --replicas=0

echo "TODO B6: limpar v1 (promoção concluída)"
# kubectl delete deployment api-v1


# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# ---------- PARTE A: BLUE/GREEN ----------

# A1. Aplicar
kubectl apply -f blue-green.yaml
kubectl rollout status deployment/shop-blue --timeout=60s
kubectl rollout status deployment/shop-green --timeout=60s

# Subir pod auxiliar pra fazer requisições internas
kubectl run curlbox --image=curlimages/curl --command -- sleep 3600
kubectl wait --for=condition=Ready pod/curlbox --timeout=60s

# A2. Service principal aponta pra blue
echo "Service shop (deve ser BLUE):"
for i in 1 2 3; do kubectl exec curlbox -- curl -s http://shop/; done
# Esperado: 3x "BLUE v1"

# A3. Service preview aponta pra green (pra testar v2 isolado)
echo "Service shop-preview (deve ser GREEN):"
for i in 1 2 3; do kubectl exec curlbox -- curl -s http://shop-preview/; done
# Esperado: 3x "GREEN v2"

# A4. CUTOVER — mudando selector do shop pra version=green
kubectl patch service shop -p '{"spec":{"selector":{"app":"shop","version":"green"}}}'

# A5. Validar — agora shop responde GREEN
echo "Apos cutover, shop deve ser GREEN:"
for i in 1 2 3; do kubectl exec curlbox -- curl -s http://shop/; done

# A6. ROLLBACK instantaneo — volta pra blue
kubectl patch service shop -p '{"spec":{"selector":{"app":"shop","version":"blue"}}}'

# A7. Validar volta
echo "Apos rollback, shop deve ser BLUE de novo:"
for i in 1 2 3; do kubectl exec curlbox -- curl -s http://shop/; done


# ---------- PARTE B: CANARY ----------

# B1. Aplicar (4 v1 + 1 v2 = ~20% canary)
kubectl apply -f canary.yaml
kubectl rollout status deployment/api-v1 --timeout=60s
kubectl rollout status deployment/api-v2 --timeout=60s

# B2. Bater 20x e contar
echo "Distribuicao com 4 v1 + 1 v2 (~20% canary):"
RESULTS=""
for i in $(seq 1 20); do
  RESULTS="$RESULTS$(kubectl exec curlbox -- curl -s http://api/)\n"
done
printf "$RESULTS" | sort | uniq -c
# Esperado: ~16x v1-stable, ~4x v2-canary (round-robin nem sempre e exato)

# B3. Promover canary pra 33%
kubectl scale deployment/api-v2 --replicas=2
kubectl rollout status deployment/api-v2 --timeout=60s
echo "Distribuicao com 4 v1 + 2 v2 (~33% canary):"
for i in $(seq 1 20); do kubectl exec curlbox -- curl -s http://api/; done | sort | uniq -c

# B4. Promover canary pra 50%
kubectl scale deployment/api-v2 --replicas=4
kubectl rollout status deployment/api-v2 --timeout=60s
echo "Distribuicao com 4 v1 + 4 v2 (~50% canary):"
for i in $(seq 1 20); do kubectl exec curlbox -- curl -s http://api/; done | sort | uniq -c

# B5. Promover pra 100% (cutover total)
kubectl scale deployment/api-v2 --replicas=5
kubectl scale deployment/api-v1 --replicas=0
kubectl rollout status deployment/api-v2 --timeout=60s
echo "Distribuicao apos cutover total (0 v1 + 5 v2):"
for i in $(seq 1 20); do kubectl exec curlbox -- curl -s http://api/; done | sort | uniq -c
# Esperado: 20x v2-canary

# B6. Promocao concluida — apagar v1
kubectl delete deployment api-v1

# B6.alt. Rollback (se tivesse dado ruim em qualquer etapa):
# kubectl scale deployment/api-v2 --replicas=0
# kubectl scale deployment/api-v1 --replicas=5


# ---------- LIMPEZA ----------
kubectl delete pod curlbox --grace-period=0 --force 2>/dev/null || true
kubectl delete -f canary.yaml --ignore-not-found
kubectl delete -f blue-green.yaml --ignore-not-found
SOLUTION
