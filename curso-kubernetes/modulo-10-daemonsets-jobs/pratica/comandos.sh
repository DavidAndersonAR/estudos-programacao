#!/usr/bin/env bash
# Módulo 10 — DaemonSets, Jobs e CronJobs
# Prática: rodar um agente por node, calcular pi, e ver CronJob disparando Jobs.
#
# PRÉ-REQUISITO: cluster kind rodando (kind create cluster --name estudo)

set -e

cd "$(dirname "$0")"

echo "=== Exercício 1: DaemonSet (1 pod por node) ==="
kubectl apply -f daemonset.yaml
kubectl rollout status ds/log-agent --timeout=60s

# Em kind com 1 node, vai ter 1 pod. Em cluster maior, 1 por node.
kubectl get ds log-agent
kubectl get pods -l app=log-agent -o wide
echo ""
echo "Veja em qual node ele subiu (coluna NODE)."

echo ""
echo "=== Exercício 2: Logs do agente ==="
POD=$(kubectl get pod -l app=log-agent -o jsonpath='{.items[0].metadata.name}')
kubectl logs "$POD" --tail=3
# Deve mostrar "[data] coletando logs do node ..."

echo ""
echo "=== Exercício 3: Job calculando pi ==="
kubectl apply -f job.yaml

# Espera o Job terminar (ou até 2min)
kubectl wait --for=condition=complete job/pi --timeout=120s

echo ""
echo "Status do Job:"
kubectl get job pi
echo ""
echo "Pod do Job (status Completed):"
kubectl get pods --selector=job-name=pi
echo ""
echo "Resultado (pi com 2000 dígitos — primeiros 80 chars):"
kubectl logs job/pi | head -c 80
echo "..."

echo ""
echo "=== Exercício 4: CronJob (hello a cada 1 minuto) ==="
kubectl apply -f cronjob.yaml
kubectl get cronjob hello

echo ""
echo "Aguarde ~70s pro CronJob disparar a primeira execução..."
sleep 70

echo ""
echo "Jobs criados automaticamente pelo CronJob:"
kubectl get jobs
# Vai aparecer algo tipo: hello-28xxxxxxx   1/1   5s

echo ""
echo "Pods criados (em Completed):"
kubectl get pods --selector=job-name -o wide

echo ""
echo "Logs do último Job criado:"
LAST_JOB=$(kubectl get jobs -l app.kubernetes.io/managed-by!=Helm \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1:].metadata.name}')
kubectl logs "job/$LAST_JOB" 2>/dev/null || echo "(ainda inicializando)"

echo ""
echo "=== Exercício 5: Disparar CronJob manualmente (sem esperar schedule) ==="
kubectl create job hello-manual --from=cronjob/hello
kubectl wait --for=condition=complete job/hello-manual --timeout=60s
kubectl logs job/hello-manual

echo ""
echo "=== Exercício 6: Pausar o CronJob (sem deletar) ==="
kubectl patch cronjob hello -p '{"spec":{"suspend":true}}'
kubectl get cronjob hello   # coluna SUSPEND deve estar True
echo "(Pra reativar: kubectl patch cronjob hello -p '{\"spec\":{\"suspend\":false}}')"

echo ""
echo "=== Exercício 7: Limpar ==="
kubectl delete -f cronjob.yaml
kubectl delete -f job.yaml --ignore-not-found
kubectl delete job hello-manual --ignore-not-found
kubectl delete -f daemonset.yaml

echo ""
echo "Pronto. Pratique olhar 'kubectl describe cronjob hello' — mostra:"
echo "  - Last Schedule Time"
echo "  - Active jobs"
echo "  - Events com histórico das criações"
