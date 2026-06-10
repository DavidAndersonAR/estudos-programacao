#!/usr/bin/env bash
# Módulo 17 — Observability
# Prática: diagnosticar 3 pods quebrados de propósito
#
# Pré-requisitos:
#   - cluster kind rodando (kind create cluster --name estudo)
#   - metrics-server instalado (pra kubectl top funcionar) — instalamos no Ex.1
#   - opcional: stern instalado (winget install stern.stern)
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Instalar metrics-server (se ainda não tem) ==="
# Sem isso, kubectl top não funciona. No kind, precisa do --kubelet-insecure-tls.
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml || true

# Patch pra ignorar TLS (kind usa cert self-signed)
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

echo ""
echo "Esperando metrics-server ficar pronto (~30s)..."
kubectl wait --for=condition=Available --timeout=120s -n kube-system deployment/metrics-server || true

echo ""
echo "=== Exercício 2: Aplicar os 3 pods quebrados ==="
kubectl apply -f pods-problema.yaml

echo ""
echo "Esperando 20s pra eles entrarem em estado problemático..."
sleep 20

echo ""
echo "=== Exercício 3: Visão geral — quem tá quebrado? ==="
kubectl get pods -l app=pod-problema -o wide
# Você deve ver:
#   pod-imagem-ruim    0/1  ImagePullBackOff / ErrImagePull
#   pod-sem-memoria    0/1  OOMKilled / CrashLoopBackOff
#   pod-crashando      0/1  CrashLoopBackOff / Error

echo ""
echo "=== Exercício 4: Eventos do cluster (visão macro) ==="
# Eventos do namespace, ordenados por tempo (último embaixo).
kubectl get events --sort-by=.lastTimestamp | tail -20

echo ""
echo "Só warnings (mais sinal, menos ruído):"
kubectl get events --field-selector type=Warning --sort-by=.lastTimestamp | tail -10

echo ""
echo "=== Exercício 5: Diagnóstico do pod-imagem-ruim ==="
echo "--- describe (vai mostrar ErrImagePull em Events no fim) ---"
kubectl describe pod pod-imagem-ruim | tail -20

echo ""
echo "--- logs (vai falhar — container nem subiu) ---"
kubectl logs pod-imagem-ruim || echo "(esperado: erro porque container nunca rodou)"

echo ""
echo ">>> DIAGNÓSTICO: imagem nginx:essa-tag-nao-existe-9.99 não existe no Docker Hub."
echo ">>> SOLUÇÃO: corrigir tag pra uma válida (ex: nginx:alpine)."

echo ""
echo "=== Exercício 6: Diagnóstico do pod-sem-memoria ==="
echo "--- describe (procura Last State + OOMKilled + Exit Code 137) ---"
kubectl describe pod pod-sem-memoria | grep -A 10 "Last State\|State:\|Reason\|Exit"

echo ""
echo "--- logs do container ANTERIOR (-p) — o que morreu ---"
kubectl logs -p pod-sem-memoria || echo "(pode não ter logs — kernel matou antes de imprimir)"

echo ""
echo ">>> DIAGNÓSTICO: container alocou 100Mi mas limit era 20Mi. Kernel matou (OOMKilled, exit 137)."
echo ">>> SOLUÇÃO: aumentar limits.memory ou reduzir alocação do app."

echo ""
echo "=== Exercício 7: Diagnóstico do pod-crashando ==="
echo "--- describe (vai mostrar BackOff em events) ---"
kubectl describe pod pod-crashando | tail -15

echo ""
echo "--- logs do container ATUAL (pode ser do attempt mais recente) ---"
kubectl logs pod-crashando || true

echo ""
echo "--- logs do container ANTERIOR (-p) — o que crashou ---"
kubectl logs -p pod-crashando

echo ""
echo ">>> DIAGNÓSTICO: app sai com exit 1 reclamando que DATABASE_URL não tá configurada."
echo ">>> SOLUÇÃO: injetar env var DATABASE_URL via ConfigMap/Secret."

echo ""
echo "=== Exercício 8: Métricas com kubectl top ==="
echo "--- top nodes (CPU/RAM do node) ---"
kubectl top nodes || echo "(se falhar, metrics-server ainda subindo — espere mais 30s)"

echo ""
echo "--- top pods do namespace ---"
kubectl top pods || true

echo ""
echo "--- top pods quebrando por container, ordenado por memória ---"
kubectl top pods --containers --sort-by=memory || true

echo ""
echo "=== Exercício 9: Stern (se instalado) ==="
if command -v stern >/dev/null 2>&1; then
  echo "Stern instalado. Mostrando logs de todos os pods com label app=pod-problema (5s)..."
  timeout 5 stern -l app=pod-problema --tail 5 || true
else
  echo "Stern não instalado. Instale com: winget install stern.stern"
  echo "Alternativa nativa: kubectl logs -l app=pod-problema --all-containers --prefix"
  kubectl logs -l app=pod-problema --all-containers --prefix --tail=3 || true
fi

echo ""
echo "=== Exercício 10: Eventos de UM pod específico ==="
kubectl get events --field-selector involvedObject.name=pod-crashando --sort-by=.lastTimestamp

echo ""
echo "=== Exercício 11: Limpar ==="
echo "Pra deletar os pods quando terminar:"
echo "  kubectl delete -f pods-problema.yaml"
echo ""
echo "=== Resumo do fluxo de diagnóstico ==="
echo "1. kubectl get pods                   -> ver status (ImagePullBackOff, CrashLoop, OOM, Pending)"
echo "2. kubectl describe pod NOME          -> ver eventos do pod no fim"
echo "3. kubectl logs NOME                  -> logs atuais"
echo "4. kubectl logs -p NOME               -> logs do container que morreu (CRUCIAL pra crash)"
echo "5. kubectl get events --sort-by...    -> visão do que o cluster fez"
echo "6. kubectl top pods/nodes             -> uso de recursos"
