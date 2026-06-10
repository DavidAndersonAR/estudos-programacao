#!/usr/bin/env bash
# Módulo 08 — Volumes e PVC
# Prática: emptyDir compartilhado + PVC com persistência real.
#
# PRÉ-REQUISITO:
#   cluster kind rodando (kind create cluster --name estudo)
#
# Rode linha a linha.

set -e

echo "=== Exercício 0: olhar a StorageClass default do cluster ==="
kubectl get storageclass
# No kind aparece "standard (default)" com provisioner rancher.io/local-path.

echo ""
echo "=== Exercício 1: emptyDir — 2 containers conversando ==="
kubectl apply -f pod-emptydir.yaml
kubectl wait --for=condition=Ready pod/pod-emptydir --timeout=60s

# Vê logs do "leitor" — ele tá fazendo tail do que o "escritor" escreve.
echo "--- logs do leitor (5s) ---"
kubectl logs pod-emptydir -c leitor --tail=5
sleep 4
kubectl logs pod-emptydir -c leitor --tail=8

echo ""
echo "=== Exercício 2: prova que emptyDir morre com o pod ==="
# Escreve algo manualmente pelo escritor
kubectl exec pod-emptydir -c escritor -- sh -c 'echo "MARCA-AQUI" >> /shared/log.txt'
kubectl exec pod-emptydir -c leitor   -- grep MARCA-AQUI /shared/log.txt

# Mata o pod
kubectl delete pod pod-emptydir

# Recria
kubectl apply -f pod-emptydir.yaml
kubectl wait --for=condition=Ready pod/pod-emptydir --timeout=60s

# O arquivo foi do zero — não acha MARCA-AQUI.
echo "--- tentando achar MARCA-AQUI no pod novo (esperado: nada) ---"
kubectl exec pod-emptydir -c leitor -- sh -c 'grep MARCA-AQUI /shared/log.txt || echo "[ok] arquivo foi do zero, emptyDir é efêmero mesmo"'

kubectl delete pod pod-emptydir

echo ""
echo "=== Exercício 3: criar o PVC ==="
kubectl apply -f pvc.yaml
kubectl get pvc
# Status pode ficar "Pending" por 1-2s até o local-path provisionar.
sleep 3
kubectl get pvc,pv

echo ""
echo "=== Exercício 4: pod usando o PVC + escrever dado ==="
kubectl apply -f pod-pvc.yaml
kubectl wait --for=condition=Ready pod/pod-pvc --timeout=60s

kubectl exec pod-pvc -- sh -c 'echo "anotacao importante - $(date)" > /dados/anotacoes.txt'
kubectl exec pod-pvc -- cat /dados/anotacoes.txt

echo ""
echo "=== Exercício 5: olhar PV provisionado dinamicamente ==="
kubectl get pv
kubectl describe pvc dados-pvc | head -25

echo ""
echo "=== Exercício 6: matar o pod (PVC fica) ==="
kubectl delete pod pod-pvc
kubectl get pvc      # PVC continua Bound
kubectl get pv       # PV continua lá

echo ""
echo "=== Exercício 7: novo pod, mesmo PVC, dado tá lá ==="
kubectl apply -f pod-pvc.yaml
kubectl wait --for=condition=Ready pod/pod-pvc --timeout=60s
kubectl exec pod-pvc -- cat /dados/anotacoes.txt
echo ">>> Persistência funcionando: dado sobreviveu à morte do pod."

echo ""
echo "=== Exercício 8: limpeza ==="
kubectl delete pod pod-pvc
kubectl delete pvc dados-pvc
# Com reclaim policy Delete (default no kind), o PV some junto.
kubectl get pv
