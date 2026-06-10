#!/usr/bin/env bash
# Módulo 04 — Prática: Deployment + Scale + Rolling Update + Rollback
#
# PRÉ-REQUISITO: cluster rodando (kind create cluster --name estudo)
#
# Rode linha a linha pra acompanhar o que acontece.

set -e

echo "=== Exercício 1: Aplicar o Deployment ==="
kubectl apply -f deployment.yaml

echo ""
echo "=== Exercício 2: Ver a cadeia Deployment -> ReplicaSet -> Pods ==="
kubectl get deploy nginx-deploy
kubectl get rs -l app=nginx          # 1 ReplicaSet (com hash no nome)
kubectl get pods -l app=nginx        # 3 Pods (cada um com 2 hashes: rs + pod)

echo ""
echo "Repare nos nomes: nginx-deploy-<hash-rs>-<hash-pod>"
echo "O hash do RS muda quando você troca a imagem. O hash do pod é aleatório."

echo ""
echo "=== Exercício 3: Esperar todos Ready ==="
kubectl rollout status deployment/nginx-deploy --timeout=120s

echo ""
echo "=== Exercício 4: Escalar pra 5 réplicas (sem editar YAML) ==="
kubectl scale deployment/nginx-deploy --replicas=5
kubectl get pods -l app=nginx -w &   # -w fica olhando ao vivo
WATCH_PID=$!
sleep 8
kill $WATCH_PID 2>/dev/null || true

kubectl get pods -l app=nginx
echo "Agora são 5 Pods. Mesmo ReplicaSet (mudar replicas NÃO cria revisão nova)."

echo ""
echo "=== Exercício 5: Rolling update — trocar nginx:1.25 -> nginx:1.27 ==="
kubectl set image deployment/nginx-deploy nginx=nginx:1.27

echo "Acompanhando o rollout..."
kubectl rollout status deployment/nginx-deploy --timeout=120s

echo ""
echo "Veja: agora tem 2 ReplicaSets — o velho (0 réplicas) e o novo (5):"
kubectl get rs -l app=nginx

echo ""
echo "=== Exercício 6: Histórico de revisões ==="
kubectl rollout history deployment/nginx-deploy
# Detalhes da revisão 2 (a que acabou de subir)
kubectl rollout history deployment/nginx-deploy --revision=2

echo ""
echo "=== Exercício 7: Rollback pra versão anterior (1.25) ==="
kubectl rollout undo deployment/nginx-deploy
kubectl rollout status deployment/nginx-deploy --timeout=120s

# Confirma: a imagem voltou pra 1.25
kubectl get deploy nginx-deploy -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""

echo ""
echo "=== Exercício 8: Provar self-healing — matar um Pod ==="
POD=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo "Matando $POD..."
kubectl delete pod "$POD"
sleep 3
kubectl get pods -l app=nginx
echo "Continuam 5 Pods. O ReplicaSet subiu um novo automaticamente."

echo ""
echo "=== Exercício 9: Limpar ==="
kubectl delete -f deployment.yaml
# Deletar o Deployment apaga RS e Pods em cascata.

echo ""
echo "Cluster fica de pé pro próximo módulo. Pra destruir tudo:"
echo "  kind delete cluster --name estudo"
