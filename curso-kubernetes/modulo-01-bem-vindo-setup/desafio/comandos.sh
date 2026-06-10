#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 01 — Cluster Funcional + 3 Pods
#
# Objetivo:
# Subir um cluster, rodar 3 pods diferentes e fazer perguntas básicas:
#
# 1. Crie um cluster com nome "desafio01"
# 2. Rode 3 pods:
#    - nginx (servidor web)
#    - redis (cache key-value)
#    - busybox (utilitário Linux pra testar comandos)
# 3. Liste todos
# 4. Pegue os logs do redis nos primeiros 5 segundos
# 5. Entre no busybox e faça curl pro nginx (use o IP que aparece no describe)
# 6. Delete os 3 pods sem deletar o cluster
# 7. (Bônus) Destrua o cluster
#
# 💡 Dicas:
#   - busybox precisa de um comando pra ficar vivo: --command -- sleep 3600
#   - dentro do busybox, instale curl: apk add curl  (não tem por padrão)
#   - ou use wget que já vem instalado
#   - kubectl get pod NOME -o jsonpath='{.status.podIP}' pega o IP

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: criar cluster"
# kind create cluster ...

echo "TODO 2: rodar 3 pods"
# kubectl run ... nginx
# kubectl run ... redis
# kubectl run ... busybox

echo "TODO 3: listar"
# kubectl get pods

echo "TODO 4: logs do redis"
# kubectl logs ...

echo "TODO 5: pegar IP do nginx e fazer wget do busybox"
# IP=$(kubectl get pod nginx -o jsonpath='{.status.podIP}')
# kubectl exec busybox -- wget -qO- $IP

echo "TODO 6: deletar pods"
# kubectl delete pod ...

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Cluster
kind create cluster --name desafio01

# 2. Três pods
kubectl run nginx --image=nginx:alpine
kubectl run redis --image=redis:7-alpine
kubectl run busybox --image=busybox --command -- sleep 3600

# Espera ficarem prontos
kubectl wait --for=condition=Ready pod/nginx pod/redis pod/busybox --timeout=120s

# 3. Listar
kubectl get pods -o wide

# 4. Logs do redis
kubectl logs redis --tail=20

# 5. Curl do busybox pro nginx (via IP do pod)
IP=$(kubectl get pod nginx -o jsonpath='{.status.podIP}')
echo "IP do nginx: $IP"
kubectl exec busybox -- wget -qO- "$IP"
# Deve retornar o HTML default do nginx

# 6. Limpar pods (mas mantém cluster pro próximo módulo)
kubectl delete pod nginx redis busybox

# 7. (BÔNUS) Destruir o cluster — só faça se for embora:
# kind delete cluster --name desafio01
SOLUTION
