#!/usr/bin/env bash
# Módulo 02 — Pods
# Prática: Pod simples, Pod multi-container (sidecar), debug.
#
# PRÉ-REQUISITO: cluster do Módulo 1 rodando (kind-estudo).
#   Se não tiver: kind create cluster --name estudo
#
# Rode linha a linha pra acompanhar.

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercício 1: Pod simples (declarativo) ==="
kubectl apply -f "$HERE/pod-simples.yaml"
kubectl wait --for=condition=Ready pod/nginx-simples --timeout=60s
kubectl get pod nginx-simples -o wide

echo ""
echo "=== Exercício 2: Inspecionar ciclo de vida ==="
# Mostra eventos: scheduled, pulling image, started...
kubectl describe pod nginx-simples | head -40

echo ""
echo "=== Exercício 3: Logs e exec ==="
kubectl logs nginx-simples | head -5
# Pod com 1 container só, não precisa de -c. Mas funciona:
kubectl exec nginx-simples -- nginx -v
kubectl exec nginx-simples -- sh -c 'echo "<h1>oi do pod</h1>" > /usr/share/nginx/html/index.html'

echo ""
echo "=== Exercício 4: Port-forward (acessar localmente) ==="
echo "Rode em outro terminal:"
echo "  kubectl port-forward nginx-simples 8080:80"
echo "E abra http://localhost:8080"
echo "(pulando aqui pra não bloquear)"

echo ""
echo "=== Exercício 5: Multi-container Pod (app + sidecar) ==="
kubectl apply -f "$HERE/pod-multi.yaml"
kubectl wait --for=condition=Ready pod/app-com-sidecar --timeout=60s
kubectl get pod app-com-sidecar -o wide
# Repare a coluna READY: "2/2" — dois containers prontos.

echo ""
echo "=== Exercício 6: Logs por container (-c) ==="
echo "--- logs do nginx ---"
kubectl logs app-com-sidecar -c nginx | tail -5 || true
echo "--- logs do sidecar ---"
kubectl logs app-com-sidecar -c log-sidecar | tail -5 || true

echo ""
echo "=== Exercício 7: Gerar tráfego e ver o sidecar reagir ==="
# Bate no nginx por dentro do próprio pod (localhost entre containers).
kubectl exec app-com-sidecar -c log-sidecar -- wget -qO- localhost:80 >/dev/null
kubectl exec app-com-sidecar -c log-sidecar -- wget -qO- localhost:80 >/dev/null
sleep 2
echo "--- sidecar agora deve mostrar acessos ---"
kubectl logs app-com-sidecar -c log-sidecar | tail -10

echo ""
echo "=== Exercício 8: Exec especificando container ==="
# Sem -c em pod multi-container o kubectl reclama.
# Errado (descomente pra ver o erro):
# kubectl exec -it app-com-sidecar -- sh
# Certo:
kubectl exec app-com-sidecar -c nginx -- ls /var/log/nginx
kubectl exec app-com-sidecar -c log-sidecar -- ls /var/log/nginx
# Mesmos arquivos nos dois — volume compartilhado funcionando.

echo ""
echo "=== Exercício 9: Limpar ==="
kubectl delete -f "$HERE/pod-simples.yaml"
kubectl delete -f "$HERE/pod-multi.yaml"
echo "Pods removidos. Cluster continua de pé pro próximo módulo."
