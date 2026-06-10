#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 04 — Deployment + Rolling Update + Rollback de bug
#
# Objetivo:
# 1. Completar deployment.yaml (4 FIXMEs no YAML)
# 2. Aplicar e ver 4 Pods de http-echo subirem
# 3. Fazer rolling update mudando -text="v1..." -> -text="v2..."
# 4. SIMULAR UM BUG: rolar pra uma imagem que NÃO existe
# 5. Ver o rollout travado (ImagePullBackOff)
# 6. Fazer rollback pra v2 (a última que funcionou)
# 7. Limpar tudo
#
# 💡 Dicas:
#   - http-echo escuta na porta 5678. Pra testar:
#       kubectl port-forward deploy/echo-app 8080:5678
#       curl http://localhost:8080
#   - Pra mudar o -text de um Deployment, edite o YAML e dê apply de novo
#     (set image só troca imagem, não args).
#   - rollout status retorna exit code != 0 se travar — use isso pra
#     detectar deploy quebrado em CI/CD.

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: aplicar deployment.yaml"
# kubectl apply -f ...

echo "TODO 2: esperar rollout terminar e confirmar 4 Pods"
# kubectl rollout status ...
# kubectl get pods -l app=echo

echo "TODO 3: testar a app (port-forward em outro terminal)"
# kubectl port-forward deploy/echo-app 8080:5678 &
# curl http://localhost:8080

echo "TODO 4: rolling update pra v2 (edite deployment.yaml: -text=\"v2 - ...\")"
# kubectl apply -f deployment.yaml
# kubectl rollout status ...

echo "TODO 5: simular bug — apontar pra imagem que não existe"
# kubectl set image deployment/echo-app echo=hashicorp/http-echo:NAO-EXISTE
# kubectl rollout status deployment/echo-app --timeout=30s  # vai falhar
# kubectl get pods -l app=echo   # uns ficam ImagePullBackOff

echo "TODO 6: rollback pra última versão boa (v2)"
# kubectl rollout undo deployment/echo-app
# kubectl rollout status ...

echo "TODO 7: limpar"
# kubectl delete -f deployment.yaml

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Aplicar (depois de preencher os FIXMEs no YAML)
kubectl apply -f deployment.yaml

# 2. Esperar e confirmar
kubectl rollout status deployment/echo-app --timeout=120s
kubectl get deploy echo-app
kubectl get rs -l app=echo
kubectl get pods -l app=echo,tier=frontend -o wide
# Devem aparecer 4 Pods Running, todos com nome echo-app-<hash-rs>-<hash-pod>

# 3. Testar a app
kubectl port-forward deploy/echo-app 8080:5678 &
PF_PID=$!
sleep 2
curl -s http://localhost:8080    # "v1 - hello from echo"
kill $PF_PID 2>/dev/null || true

# 4. Rolling update pra v2
# Edite deployment.yaml e mude -text="v1 - hello from echo" -> -text="v2 - hello from echo"
# Depois:
kubectl apply -f deployment.yaml
kubectl rollout status deployment/echo-app --timeout=120s

# Confirma: agora deve responder "v2 - ..."
kubectl port-forward deploy/echo-app 8080:5678 &
PF_PID=$!
sleep 2
curl -s http://localhost:8080
kill $PF_PID 2>/dev/null || true

# 5. SIMULAR BUG — imagem que não existe
kubectl set image deployment/echo-app echo=hashicorp/http-echo:VERSAO-FANTASMA
# Esse comando volta na hora; o rollout é assíncrono. Vamos ver travar:
kubectl rollout status deployment/echo-app --timeout=30s || \
  echo ">>> rollout falhou (esperado) — exit code != 0"

# Diagnóstico: alguns Pods novos ficam ImagePullBackOff,
# mas como maxUnavailable=1, o Deployment NÃO derruba os Pods bons.
# Sua app continua respondendo v2 nos Pods velhos. Esse é o ponto do rolling update.
kubectl get pods -l app=echo
kubectl describe pod $(kubectl get pods -l app=echo \
  -o jsonpath='{.items[?(@.status.phase!="Running")].metadata.name}' | awk '{print $1}') \
  | tail -20

# 6. Rollback pra revisão anterior (v2)
kubectl rollout history deployment/echo-app
kubectl rollout undo deployment/echo-app
kubectl rollout status deployment/echo-app --timeout=120s

# Confirma: voltou pra v2 e tá tudo Running
kubectl get pods -l app=echo
kubectl port-forward deploy/echo-app 8080:5678 &
PF_PID=$!
sleep 2
curl -s http://localhost:8080     # "v2 - hello from echo"
kill $PF_PID 2>/dev/null || true

# 7. Limpar
kubectl delete -f deployment.yaml
SOLUTION

# ============================
# 🧠 PERGUNTAS PRA PENSAR (sem resposta no script):
# 1. Por que durante o "bug" os Pods velhos NÃO morreram?
#    (dica: olhe maxUnavailable)
# 2. O que aconteceria se você tivesse 4 réplicas e maxUnavailable=4?
# 3. Se você fizesse `kubectl delete rs <rs-antigo>` durante o bug,
#    o rollback ainda funcionaria? Por quê?
# ============================
