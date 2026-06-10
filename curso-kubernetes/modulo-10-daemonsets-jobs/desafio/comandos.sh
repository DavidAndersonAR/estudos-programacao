#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 10 — CronJob de Backup
#
# Roteiro:
# 1. Edite desafio/cronjob.yaml e escreva sua versão (TODOs)
# 2. Aplique e observe rodar a cada 2min
# 3. Compare seu histórico com o que pediu (2 sucessos + 1 falha)
# 4. Confira logs do último Job pra ver o "backup" sendo gerado
#
# Quando travar, descomente o bloco "SOLUÇÃO DE REFERÊNCIA" no YAML.

set -e

cd "$(dirname "$0")"

# ============================
# TODO 1: Aplicar seu CronJob
# ============================
echo "TODO 1: aplicar cronjob.yaml"
# kubectl apply -f cronjob.yaml

# ============================
# TODO 2: Verificar criação
# ============================
echo "TODO 2: kubectl get cronjob backup"
# kubectl get cronjob backup
# kubectl describe cronjob backup | head -30

# ============================
# TODO 3: Aguardar primeira execução (até ~2min)
# ============================
echo "TODO 3: aguardar ~2min e listar Jobs"
# sleep 130
# kubectl get jobs
# kubectl get pods --selector=job-name

# ============================
# TODO 4: Ver logs do Job criado pelo CronJob
# ============================
echo "TODO 4: pegar último Job e mostrar logs"
# LAST=$(kubectl get jobs --sort-by=.metadata.creationTimestamp \
#   -o jsonpath='{.items[-1:].metadata.name}')
# kubectl logs "job/$LAST"

# ============================
# TODO 5: Disparar manualmente (sem esperar schedule)
# ============================
echo "TODO 5: kubectl create job ... --from=cronjob/backup"
# kubectl create job backup-manual --from=cronjob/backup
# kubectl wait --for=condition=complete job/backup-manual --timeout=60s
# kubectl logs job/backup-manual

# ============================
# TODO 6: Verificar retenção (successfulJobsHistoryLimit=2)
# ============================
echo "TODO 6: depois de 3-4 execuções, conferir que só há 2 sucessos guardados"
# kubectl get jobs    # nunca mais de 2 successful + 1 failed

# ============================
# TODO 7: Limpar
# ============================
echo "TODO 7: limpar tudo"
# kubectl delete -f cronjob.yaml
# kubectl delete job backup-manual --ignore-not-found

# ============================
# 🔓 SOLUÇÃO DE REFERÊNCIA — descomente abaixo pra rodar de uma vez
# ============================

: <<'SOLUTION'
# 1. Aplicar (assumindo que você descomentou a solução no cronjob.yaml)
kubectl apply -f cronjob.yaml

# 2. Ver criado
kubectl get cronjob backup
kubectl describe cronjob backup | head -30

# 3. Esperar 1ª execução (CronJob com */2 demora até ~2min)
echo "Aguardando 130s pra primeira execução do CronJob..."
sleep 130
kubectl get jobs
kubectl get pods --selector=job-name -o wide

# 4. Logs do último Job criado
LAST=$(kubectl get jobs --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1:].metadata.name}')
echo ""
echo "Logs do Job $LAST:"
kubectl logs "job/$LAST"

# 5. Disparar manualmente (sem esperar próximo schedule)
kubectl create job backup-manual --from=cronjob/backup
kubectl wait --for=condition=complete job/backup-manual --timeout=60s
echo ""
echo "Logs do backup manual:"
kubectl logs job/backup-manual

# 6. Esperar mais 2 execuções e ver retenção em ação
echo ""
echo "Aguardando mais 130s pra ver retenção..."
sleep 130
echo "Jobs (deve ter no máximo successfulJobsHistoryLimit=2 sucessos):"
kubectl get jobs

# 7. Limpar
kubectl delete -f cronjob.yaml
kubectl delete job backup-manual --ignore-not-found

# 🧠 Reflita:
# - Como você adaptaria isso pra backup REAL de Postgres?
#   (resposta curta: image=postgres, command com pg_dump, secret com senha,
#    volume=PVC pra persistir entre execuções)
# - Por que concurrencyPolicy: Forbid faz sentido pra backup?
#   (porque 2 pg_dump simultâneos brigariam pelo mesmo arquivo de output
#    e provavelmente corromperiam um ao outro)
SOLUTION
