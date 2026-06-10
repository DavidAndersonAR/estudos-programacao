#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 15 — Aplicar e validar
#
# Pré-requisitos:
#   - Cluster kind rodando
#   - metrics-server instalado (veja pratica/metrics-server.sh)
#   - Você completou manifestos.yaml (ou descomentou a SOLUÇÃO DE REFERÊNCIA)

set -e

# ============================
# SUA VALIDAÇÃO ABAIXO
# ============================

echo "TODO 1: Aplicar manifestos.yaml"
# kubectl apply -f manifestos.yaml

echo "TODO 2: Verificar QoS class do pod (deve ser Burstable)"
# POD=$(kubectl get pod -l app=api -o jsonpath='{.items[0].metadata.name}')
# kubectl get pod "$POD" -o jsonpath='{.status.qosClass}{"\n"}'

echo "TODO 3: Verificar HPA criado e lendo métricas"
# kubectl get hpa api

echo "TODO 4: Gerar carga e ver escalando devagar"
# kubectl run loader --image=busybox:1.36 --restart=Never --rm -i --tty=false \
#   --command -- /bin/sh -c "while true; do wget -q -O- http://api; done" &
# watch kubectl get hpa,pods

echo "TODO 5: Parar carga e cronometrar quanto demora pra descer"
# (deve demorar pelo menos 5min por causa da stabilizationWindowSeconds)

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Aplicar
kubectl apply -f manifestos.yaml

# 2. Esperar deployment ficar disponível
kubectl wait --for=condition=Available deployment/api --timeout=120s

# 3. Conferir QoS class — esperado: Burstable
POD=$(kubectl get pod -l app=api -o jsonpath='{.items[0].metadata.name}')
echo "QoS class: $(kubectl get pod "$POD" -o jsonpath='{.status.qosClass}')"

# 4. Conferir HPA — pode demorar uns 30s pra TARGETS sair de <unknown>
kubectl get hpa api
echo "Esperando HPA ler métricas..."
sleep 30
kubectl get hpa api

# 5. Gerar carga
echo ""
echo "=== Gerando carga (3 min) ==="
kubectl run loader \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i --tty=false \
  --command -- /bin/sh -c "while true; do wget -q -O- http://api; done" &
LOADER_PID=$!

# Acompanhar
for i in {1..18}; do
  sleep 10
  echo ""
  echo "--- $((i*10))s de carga ---"
  kubectl get hpa api --no-headers
  kubectl get pods -l app=api --no-headers | wc -l | xargs -I{} echo "Pods: {}"
done

# Observe: réplicas crescem em DEGRAUS — no máximo +50% por minuto.
# Compare com o HPA da prática (sem behavior), que poderia dobrar em segundos.

# 6. Parar carga
echo ""
echo "=== Parando carga ==="
kubectl delete pod loader --ignore-not-found --grace-period=0 --force 2>/dev/null || true
kill $LOADER_PID 2>/dev/null || true

# 7. Cronometrar quanto demora pra descer
START=$(date +%s)
INITIAL=$(kubectl get hpa api -o jsonpath='{.status.currentReplicas}')
echo "Réplicas no início do cooldown: $INITIAL"
echo "Aguardando descer..."

# Espera até voltar pra 2 (minReplicas) ou 10 min
for i in {1..60}; do
  sleep 10
  CUR=$(kubectl get hpa api -o jsonpath='{.status.currentReplicas}')
  ELAPSED=$(( $(date +%s) - START ))
  echo "t=${ELAPSED}s, réplicas=$CUR"
  if [ "$CUR" = "2" ]; then
    echo "Voltou ao mínimo em ${ELAPSED}s (esperado: >= 300s pela janela de estabilização)"
    break
  fi
done

# 8. Ver histórico de eventos do HPA — cada SuccessfulRescale é uma decisão
echo ""
echo "=== Eventos do HPA ==="
kubectl describe hpa api | sed -n '/Events:/,$p'

# Limpar
# kubectl delete -f manifestos.yaml
SOLUTION
