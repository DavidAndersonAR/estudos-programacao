#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 02 — Init container + app lendo config compartilhada
#
# Roteiro:
#   1. Edite pod.yaml e complete os TODOs.
#   2. Aplique e veja se passou.
#   3. Confira: o app deve imprimir o JSON gerado pelo init.
#
# Dicas:
#   - Init e app têm que montar o MESMO volume com o MESMO mountPath
#     (ou pelo menos paths que façam sentido pros dois).
#   - Init precisa terminar com exit 0. Se travar, o Pod fica em Init:0/1.
#   - kubectl describe mostra o status de cada init container separado.

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== TODO 1: aplicar o YAML ==="
# kubectl apply -f "$HERE/pod.yaml"

echo ""
echo "=== TODO 2: acompanhar o ciclo (Init → Running) ==="
# kubectl get pod init-desafio -w
# (ctrl+c quando virar Running)

echo ""
echo "=== TODO 3: ver logs do init e do app ==="
# kubectl logs init-desafio -c gera-config
# kubectl logs init-desafio -c app

echo ""
echo "=== TODO 4: entrar no app e olhar o arquivo ==="
# kubectl exec -it init-desafio -c app -- sh
# # dentro: cat /shared/config.json

echo ""
echo "=== TODO 5: limpar ==="
# kubectl delete -f "$HERE/pod.yaml"

# =====================================================================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco abaixo pra rodar tudo)
# =====================================================================
: <<'SOLUTION'

# 1. Aplicar (depois de completar o YAML)
kubectl apply -f "$HERE/pod.yaml"

# 2. Espera ficar Ready (init roda antes, depois o app)
kubectl wait --for=condition=Ready pod/init-desafio --timeout=90s

# 3. Confirmar os 2 containers do ciclo
kubectl get pod init-desafio
kubectl describe pod init-desafio | sed -n '/Init Containers/,/Conditions/p'

# 4. Logs
echo "--- init ---"
kubectl logs init-desafio -c gera-config
echo "--- app ---"
kubectl logs init-desafio -c app

# 5. Conferir arquivo no app
kubectl exec init-desafio -c app -- cat /shared/config.json

# 6. Bônus: o que acontece se o init falhar?
#    Edite o command do init pra "exit 1" e reaplique — o Pod fica em
#    Init:Error e o app NUNCA sobe. Init é portão de entrada.

# 7. Limpar
kubectl delete -f "$HERE/pod.yaml"

SOLUTION
