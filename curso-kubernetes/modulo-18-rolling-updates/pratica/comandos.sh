#!/usr/bin/env bash
# Módulo 18 — Rolling Updates e Estratégias de Deploy
# Prática: rollout, pause/resume, falha + undo
#
# PRÉ-REQUISITO: cluster kind rodando (kind create cluster --name estudo)
# Rode linha a linha pra ver o efeito de cada comando.

set -e

cd "$(dirname "$0")"

echo "=== Exercício 1: subir v1 ==="
kubectl apply -f v1.yaml
kubectl rollout status deployment/webapp --timeout=60s
kubectl get pods -l app=webapp -L version
# Devem aparecer 4 pods com version=v1

echo ""
echo "=== Exercício 2: testar v1 (port-forward em background) ==="
# Em outro terminal: kubectl port-forward svc/webapp 8080:80
# E rode: curl http://localhost:8080  → "Hello from v1"
echo "  Em outro terminal: kubectl port-forward svc/webapp 8080:80"
echo "  Depois: curl http://localhost:8080"

echo ""
echo "=== Exercício 3: rollout pra v2 — assistir os pods trocarem ==="
# Em outro terminal rode: watch -n 0.5 'kubectl get pods -l app=webapp -L version'
# E aqui aplica:
kubectl apply -f v2.yaml
kubectl rollout status deployment/webapp --timeout=120s

# Você vai ver: sobe pod v2 → fica Ready → derruba 1 v1 → sobe 1 v2 ...
# Como maxUnavailable=0, sempre existem >=4 pods Ready durante a transição.

echo ""
echo "=== Exercício 4: ver histórico ==="
kubectl rollout history deployment/webapp
# Deve ter 2 revisões. Pra ver detalhes:
kubectl rollout history deployment/webapp --revision=2

# E os ReplicaSets antigos ficam zerados, prontos pra undo:
kubectl get rs -l app=webapp

echo ""
echo "=== Exercício 5: pause / resume ==="
# Cenário: você quer rollout "manual" — sobe um pouco, observa, continua.
# Vamos fazer rollout pra "v3" (só mudando uma label) e pausar no meio.

kubectl patch deployment webapp -p '{"spec":{"template":{"metadata":{"labels":{"version":"v3-test"}}}}}'
# IMEDIATAMENTE pausa (antes do controller terminar):
kubectl rollout pause deployment/webapp
echo "Rollout PAUSADO. Estado parcial:"
kubectl get pods -l app=webapp -L version
echo "Mesmo se você 'apply' de novo, nada se move até dar resume."

read -p "Pressione ENTER pra retomar..." _
kubectl rollout resume deployment/webapp
kubectl rollout status deployment/webapp --timeout=60s

echo ""
echo "=== Exercício 6: forçar falha (imagem inválida) e dar undo ==="
# Simulando um deploy quebrado: imagem que não existe.
kubectl set image deployment/webapp web=hashicorp/http-echo:imagem-que-nao-existe

# Vai ficar travado — pods novos ficam ImagePullBackOff e não viram Ready.
# Como maxUnavailable=0, os pods antigos NÃO caem. Aplicação continua no ar.
sleep 10
echo "Estado dos pods (alguns devem estar ImagePullBackOff):"
kubectl get pods -l app=webapp

echo ""
echo "rollout status vai dar timeout — usa --timeout pequeno só pra demonstrar:"
kubectl rollout status deployment/webapp --timeout=15s || echo "(esperado: timeout, rollout não progrediu)"

echo ""
echo "=== Exercício 7: undo ==="
kubectl rollout undo deployment/webapp
kubectl rollout status deployment/webapp --timeout=60s
kubectl get pods -l app=webapp -L version
# Voltou pra revisão anterior (v3-test) com imagem boa.

echo ""
echo "=== Exercício 8: undo pra revisão específica ==="
kubectl rollout history deployment/webapp
# Volta pra revisão 1 (v1 original):
# kubectl rollout undo deployment/webapp --to-revision=1

echo ""
echo "=== Exercício 9: restart (recria pods com mesma imagem) ==="
# Útil pra recarregar Secret/ConfigMap montado, ou pra "reset" geral.
kubectl rollout restart deployment/webapp
kubectl rollout status deployment/webapp --timeout=60s

echo ""
echo "=== Limpeza ==="
echo "kubectl delete -f v2.yaml"
echo "(ou kubectl delete deployment webapp && kubectl delete service webapp)"
