#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 03 — Verificação
#
# Esse script TESTA se o seu pod.yaml atende aos requisitos do desafio.
# Antes de rodar, complete os TODOs em pod.yaml.
#
# Como usar:
#   1. Edite pod.yaml e complete os TODOs.
#   2. Rode: bash comandos.sh
#   3. Se todos os checks passarem, parabéns. Senão, leia a mensagem.

set -e

POD=api-pedidos

echo "=== 1. Validando YAML (dry-run, sem aplicar de verdade) ==="
# --dry-run=server manda pro API Server validar SEM persistir.
# Se a sintaxe ou os campos tiverem errados, falha aqui.
kubectl apply -f pod.yaml --dry-run=server
echo "   YAML válido."

echo ""
echo "=== 2. Aplicando de verdade ==="
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/$POD --timeout=60s

echo ""
echo "=== 3. Conferindo labels obrigatorias ==="
for kv in "app=pedidos" "tier=backend" "env=prod" "versao=v2"; do
  k=${kv%=*}; v=${kv#*=}
  atual=$(kubectl get pod $POD -o jsonpath="{.metadata.labels.$k}")
  if [ "$atual" = "$v" ]; then
    echo "   OK   label $k=$v"
  else
    echo "   FAIL label $k esperado=$v, obtido=$atual"
    exit 1
  fi
done

echo ""
echo "=== 4. Conferindo annotations ==="
desc=$(kubectl get pod $POD -o jsonpath='{.metadata.annotations.descricao}')
resp=$(kubectl get pod $POD -o jsonpath='{.metadata.annotations.responsavel}')
[ -n "$desc" ] && echo "   OK   annotation descricao: $desc"   || { echo "   FAIL annotation descricao faltando"; exit 1; }
[ -n "$resp" ] && echo "   OK   annotation responsavel: $resp" || { echo "   FAIL annotation responsavel faltando"; exit 1; }

echo ""
echo "=== 5. Conferindo imagem do container ==="
img=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].image}')
if [ "$img" = "nginx:1.27-alpine" ]; then
  echo "   OK   imagem: $img"
else
  echo "   FAIL imagem esperada=nginx:1.27-alpine, obtida=$img"
  exit 1
fi

echo ""
echo "=== 6. Conferindo porta 8080 ==="
porta=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].ports[0].containerPort}')
[ "$porta" = "8080" ] && echo "   OK   porta: $porta" || { echo "   FAIL porta esperada=8080, obtida=$porta"; exit 1; }

echo ""
echo "=== 7. Conferindo resources ==="
cpuReq=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
memReq=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].resources.requests.memory}')
cpuLim=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].resources.limits.cpu}')
memLim=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].resources.limits.memory}')
echo "   requests: cpu=$cpuReq mem=$memReq"
echo "   limits:   cpu=$cpuLim mem=$memLim"
[ "$cpuReq" = "100m" ]  || { echo "   FAIL cpu request"; exit 1; }
[ "$memReq" = "128Mi" ] || { echo "   FAIL mem request"; exit 1; }
[ "$cpuLim" = "500m" ]  || { echo "   FAIL cpu limit"; exit 1; }
[ "$memLim" = "256Mi" ] || { echo "   FAIL mem limit"; exit 1; }

echo ""
echo "=== 8. Conferindo variável de ambiente AMBIENTE=producao ==="
amb=$(kubectl exec $POD -- printenv AMBIENTE)
[ "$amb" = "producao" ] && echo "   OK   AMBIENTE=$amb" || { echo "   FAIL AMBIENTE esperado=producao, obtido=$amb"; exit 1; }

echo ""
echo "==============================="
echo "  TODOS OS CHECKS PASSARAM 🎉"
echo "==============================="

echo ""
echo "=== Limpando ==="
kubectl delete -f pod.yaml
