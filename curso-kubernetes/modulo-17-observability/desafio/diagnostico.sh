#!/usr/bin/env bash
# 🎯 DESAFIO Módulo 17 — Diagnosticar pod misterioso
#
# Cenário: você é o SRE de plantão. O time de pagamentos avisou que
# o Deployment "api-pagamentos" foi atualizado às 14h e desde então
# NENHUMA réplica fica em Ready. Latência subiu, pagamentos não passam.
#
# Você tem o YAML (bug.yaml) e o cluster. Descubra:
#   (a) Qual é o status atual das réplicas?
#   (b) Por que elas estão nesse estado?
#   (c) Qual é a causa raiz (ou MÚLTIPLAS causas)?
#   (d) O que precisa ser feito pra arrumar?
#
# 💡 Dicas:
#   - Use o fluxo do AULA.md: get pods -> describe -> logs (com -p!) -> events.
#   - O Deployment tem 2 réplicas. Use kubectl logs -p <POD> pra cada uma OU
#     kubectl logs -l app=api-pagamentos --previous --all-containers.
#   - kubectl get events --sort-by=.lastTimestamp ajuda a ver a linha do tempo.
#   - Verifique se os recursos referenciados (Secrets, ConfigMaps) EXISTEM:
#       kubectl get configmap
#       kubectl get secret
#
# Aplique o bug e comece a investigação:
#   kubectl apply -f bug.yaml

set -e

# ============================
# SUA INVESTIGAÇÃO ABAIXO
# ============================

echo "TODO 1: ver status dos pods do deployment"
# kubectl get pods -l app=api-pagamentos

echo "TODO 2: pegar o nome de um pod e descrever"
# POD=$(kubectl get pod -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
# kubectl describe pod $POD | tail -30

echo "TODO 3: olhar os logs (e o -p se tiver crashando)"
# kubectl logs $POD
# kubectl logs -p $POD

echo "TODO 4: ver eventos do namespace ordenados por tempo"
# kubectl get events --sort-by=.lastTimestamp | tail -15

echo "TODO 5: verificar se Secret existe (o YAML referencia api-pagamentos-secret)"
# kubectl get secret

echo "TODO 6: verificar ConfigMap (tem todas as envs que o app precisa?)"
# kubectl get configmap api-pagamentos-config -o yaml

echo ""
echo "TODO 7: escrever (em comentário) a causa raiz e o que arrumar"
# CAUSA(S) RAIZ:
# 1. _________________________________________________
# 2. _________________________________________________
# 3. _________________________________________________
#
# FIX:
# _________________________________________________


# ============================
# SOLUÇÃO DE REFERÊNCIA
# (rode comentando o "exit 0" pra ver o passo a passo executado)
# ============================
exit 0

: <<'SOLUTION'
# -----------------------------------------------------------------
# PASSO 1 — visão geral
# -----------------------------------------------------------------
kubectl apply -f bug.yaml
sleep 10
kubectl get pods -l app=api-pagamentos
# Resultado típico:
#   NAME                              READY   STATUS                       RESTARTS
#   api-pagamentos-xxxxxxxxxx-aaaaa   0/1     CreateContainerConfigError   0
#   api-pagamentos-xxxxxxxxxx-bbbbb   0/1     CreateContainerConfigError   0
#
# Status "CreateContainerConfigError" = K8s nem conseguiu CRIAR o container
# porque algo na config (Secret, ConfigMap, env, volume) está faltando.

# -----------------------------------------------------------------
# PASSO 2 — describe pra ver o porquê
# -----------------------------------------------------------------
POD=$(kubectl get pod -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $POD | tail -25
# Na seção Events vamos ver algo como:
#   Warning  Failed   ...  Error: secret "api-pagamentos-secret" not found
#
# >>> ACHADO 1: o Secret "api-pagamentos-secret" referenciado no env DATABASE_URL
#               NÃO EXISTE no cluster. Sem ele, o K8s nem cria o container.

# -----------------------------------------------------------------
# PASSO 3 — confirmar com get
# -----------------------------------------------------------------
kubectl get secret api-pagamentos-secret 2>&1 || echo ">>> confirmado: secret nao existe"
kubectl get secret
# Lista todos os secrets — o esperado não está lá.

# -----------------------------------------------------------------
# PASSO 4 — criar o secret faltante
# -----------------------------------------------------------------
kubectl create secret generic api-pagamentos-secret \
  --from-literal=database-url='postgres://app:senha@db.prod:5432/pagamentos'

# Espera ~15s pro Deployment tentar de novo (ele fica em retry loop)
sleep 15
kubectl get pods -l app=api-pagamentos
# Agora deve mudar de CreateContainerConfigError pra Running/CrashLoopBackOff.

# -----------------------------------------------------------------
# PASSO 5 — novo problema! Pods agora crashando em loop
# -----------------------------------------------------------------
POD=$(kubectl get pod -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
kubectl get pods -l app=api-pagamentos
# Status:
#   api-pagamentos-...   0/1   CrashLoopBackOff   3
#
# Agora precisamos dos LOGS — e como crashou, use -p!
kubectl logs -p $POD
# Saída:
#   [api-pagamentos] iniciando em log_level=info
#   [ERRO] PORT nao definida — abortando
#
# >>> ACHADO 2: o ConfigMap "api-pagamentos-config" NÃO tem a chave PORT.
#               O app exige PORT e sai com exit 3 sem ela.

# -----------------------------------------------------------------
# PASSO 6 — confirmar e arrumar o ConfigMap
# -----------------------------------------------------------------
kubectl get configmap api-pagamentos-config -o yaml | grep -A 5 data:
# data:
#   APP_NAME: api-pagamentos
#   LOG_LEVEL: info
# ↑ falta PORT mesmo.

# Adiciona PORT ao ConfigMap (patch JSON merge)
kubectl patch configmap api-pagamentos-config \
  --type=merge \
  -p '{"data":{"PORT":"8080"}}'

# Força os pods a recriarem com a config nova
kubectl rollout restart deployment api-pagamentos

# Espera e confere
kubectl rollout status deployment api-pagamentos --timeout=120s
kubectl get pods -l app=api-pagamentos
# Esperado:
#   api-pagamentos-...   1/1   Running   0   ...

# -----------------------------------------------------------------
# RESUMO — CAUSAS RAIZ (foram DUAS, descobertas em sequência)
# -----------------------------------------------------------------
# 1. Secret "api-pagamentos-secret" referenciado em env.valueFrom.secretKeyRef
#    NÃO EXISTIA no cluster. Sintoma: CreateContainerConfigError.
#    Diagnóstico: kubectl describe pod → Events → "secret not found".
#
# 2. ConfigMap "api-pagamentos-config" estava INCOMPLETO — faltava a chave
#    PORT, que o app exige na inicialização. Sintoma: CrashLoopBackOff.
#    Diagnóstico: kubectl logs -p <pod> → "[ERRO] PORT nao definida".
#    >>> Esse é o caso clássico onde SEM o -p você ficaria perdido,
#    >>> porque o kubectl logs sem -p mostra o container atual que pode
#    >>> ainda estar nos primeiros segundos antes de imprimir o erro.
#
# FIX FINAL:
#   - Criar o Secret com a chave database-url.
#   - Adicionar PORT ao ConfigMap.
#   - kubectl rollout restart pra recriar os pods.
#
# LIÇÃO:
#   - SEMPRE conferir se Secrets/ConfigMaps referenciados existem ANTES
#     de subir o Deployment (ou seu CI deveria validar).
#   - SEMPRE rodar kubectl logs -p em CrashLoopBackOff.
#   - kubectl describe é o primeiro passo: mostra Events do pod com a
#     mensagem exata do K8s sobre o problema.
SOLUTION
