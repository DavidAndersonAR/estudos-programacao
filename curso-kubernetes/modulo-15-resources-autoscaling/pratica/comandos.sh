#!/usr/bin/env bash
# Módulo 15 — Prática: ver o HPA escalar sob carga
#
# Pré-requisitos:
#   - Cluster kind rodando
#   - metrics-server instalado (rode `bash metrics-server.sh` antes)
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Aplicar deployment + service ==="
kubectl apply -f deployment.yaml
kubectl wait --for=condition=Available deployment/php-apache --timeout=120s
kubectl get deploy php-apache

echo ""
echo "=== Exercício 2: Ver a QoS class do pod ==="
POD=$(kubectl get pod -l app=php-apache -o jsonpath='{.items[0].metadata.name}')
kubectl get pod "$POD" -o jsonpath='{.status.qosClass}{"\n"}'
# Deve mostrar "Burstable" — porque requests != limits

echo ""
echo "=== Exercício 3: Aplicar HPA ==="
kubectl apply -f hpa.yaml
kubectl get hpa php-apache

# Espera o HPA conseguir ler métricas (pode demorar ~30s)
echo "Esperando HPA conseguir ler métricas..."
for i in {1..20}; do
  TARGETS=$(kubectl get hpa php-apache -o jsonpath='{.status.currentMetrics}' 2>/dev/null || echo "")
  if [ -n "$TARGETS" ] && [ "$TARGETS" != "<none>" ]; then
    break
  fi
  echo "  ainda não... ($i/20)"
  sleep 3
done
kubectl get hpa php-apache

echo ""
echo "=== Exercício 4: Gerar carga ==="
# Pod busybox em loop infinito fazendo wget pro service php-apache.
# Cada request faz PHP calcular algo pesado → consome CPU → HPA escala.
echo "Subindo pod gerador de carga..."
kubectl run load-generator \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -i --tty=false \
  --command -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done" &

LOAD_PID=$!

echo ""
echo "=== Exercício 5: Observar o HPA escalando ==="
echo "Em outro terminal, rode:"
echo "  watch kubectl get hpa,pods"
echo ""
echo "Vai ver:"
echo "  - TARGETS subir de 0% pra >50%"
echo "  - REPLICAS subir de 1 pra 4, 6, 8..."
echo "  - Novos pods 'php-apache-xxx' aparecendo"
echo ""
echo "Aguardando 3 minutos pra ver o efeito..."
sleep 180

echo ""
echo "=== Estado depois de 3min de carga ==="
kubectl get hpa php-apache
kubectl top pods -l app=php-apache
kubectl get pods -l app=php-apache

echo ""
echo "=== Exercício 6: Parar a carga ==="
# Mata o pod gerador de carga
kubectl delete pod load-generator --ignore-not-found --grace-period=0 --force 2>/dev/null || true
kill $LOAD_PID 2>/dev/null || true

echo ""
echo "Agora o HPA vai DESCALAR (mais devagar — cooldown padrão ~5min)."
echo "Pra acompanhar:"
echo "  watch kubectl get hpa,pods"
echo ""
echo "=== Exercício 7: Ver eventos do HPA ==="
kubectl describe hpa php-apache | tail -20
# Olha os eventos "SuccessfulRescale" — ele conta cada vez que escalou.

echo ""
echo "=== Limpar (opcional) ==="
echo "kubectl delete -f hpa.yaml -f deployment.yaml"
