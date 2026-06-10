#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 14 — Validação
#
# Passos:
#  1. Edite deployment.yaml e adicione as 3 probes (TODOs 1, 2, 3)
#  2. Rode este script
#  3. Observe: pod NÃO morre durante o boot de 30s
#  4. Espere ~60-90s e veja: quando o app sorteia "crash", K8s reinicia em ~15s
#
# Pré-requisito: cluster do módulo 1 rodando.

set -e
cd "$(dirname "$0")"

echo "=== Passo 1: Aplicar o deployment ==="
kubectl apply -f deployment.yaml

echo ""
echo "=== Passo 2: Observar o boot lento (30s) ==="
echo "Durante esses 30s, a app NÃO está saudável — mas startupProbe segura"
echo "a barra e o pod NÃO é reiniciado. Verifique:"
echo ""

# Loop de monitoramento por 50s
for i in 1 2 3 4 5; do
  echo "--- t=${i}0s ---"
  kubectl get pods -l app=app-instavel
  sleep 10
done

echo ""
echo "=== Passo 3: Conferir que pods ficaram Ready ==="
kubectl wait --for=condition=Ready pod -l app=app-instavel --timeout=120s
kubectl get pods -l app=app-instavel
kubectl get endpoints app-instavel
echo "Service tem 2 endpoints? Bom sinal."

echo ""
echo "=== Passo 4: Ver as probes ativas ==="
POD=$(kubectl get pod -l app=app-instavel -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD" | grep -A 1 -E "(Liveness|Readiness|Startup):"

echo ""
echo "=== Passo 5: Forçar um crash agora (sem esperar o sorteio) ==="
echo "Apagando /tmp/healthy manualmente no pod $POD..."
kubectl exec "$POD" -- rm -f /tmp/healthy

RESTARTS_ANTES=$(kubectl get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "Restarts antes: $RESTARTS_ANTES"

echo "Esperando ~25s pra liveness detectar e K8s reiniciar..."
sleep 25

RESTARTS_DEPOIS=$(kubectl get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "Restarts depois: $RESTARTS_DEPOIS"

if [ "$RESTARTS_DEPOIS" -gt "$RESTARTS_ANTES" ]; then
  echo "✓ K8s reiniciou o pod sozinho. Self-healing funcionando."
else
  echo "✗ Não reiniciou. Confira se a livenessProbe foi configurada (TODO 2)."
fi

echo ""
echo "=== Passo 6: (Opcional) Observar por 3 min pra pegar crash aleatório ==="
echo "A app sorteia crash a cada 30s, com ~20% chance. Em 3min você"
echo "deve ver pelo menos 1 reinício 'orgânico'."
echo ""
echo "Rode em outro terminal:"
echo "  kubectl get pods -l app=app-instavel -w"
echo ""
echo "Pra inspecionar eventos de probe:"
echo "  kubectl describe pod -l app=app-instavel | tail -30"
echo ""

echo "=== Limpar ==="
echo "  kubectl delete -f deployment.yaml"

# ============================================================
# 🧠 PERGUNTAS DE REFLEXÃO
# ============================================================
#
# 1. Se você botasse APENAS liveness com initialDelaySeconds: 45
#    (sem startup), o que aconteceria a cada reinício?
#    R: K8s esperaria 45s ANTES da primeira checagem após cada restart.
#       Crash demoraria 45s+15s = 60s pra ser detectado, em vez de 15s.
#
# 2. Por que readiness e liveness checam arquivos diferentes aqui?
#    R: Pra simular dimensões independentes. Num app real: liveness = "processo
#       vivo?", readiness = "BD conectado, cache aquecido, fila acessível?".
#       Pod pode estar vivo (não reiniciar) mas não pronto (fora do Service).
#
# 3. Se a sua app crashasse a cada 10s (mais rápido que period×failureThreshold),
#    o que aconteceria?
#    R: CrashLoopBackOff. K8s reinicia, app crasha, reinicia, crasha... K8s
#       começa a esperar cada vez mais entre tentativas (backoff exponencial:
#       10s, 20s, 40s, 80s, ... até 5min).
