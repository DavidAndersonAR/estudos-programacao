#!/usr/bin/env bash
# Módulo 05 — Services
# Prática: expor um Deployment com ClusterIP e NodePort,
# acessar o Service pelo DNS interno e ver load balancing.
#
# PRÉ-REQUISITO: cluster kind rodando (modulo-01)
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Aplicar deployment + services ==="
kubectl apply -f deployment.yaml
kubectl apply -f service-clusterip.yaml
kubectl apply -f service-nodeport.yaml

echo ""
echo "=== Exercício 2: Ver o que subiu ==="
kubectl get deploy,pods,svc -o wide
# Repare que cada Service tem CLUSTER-IP (um IP interno, fixo).
# O Deployment tem 2 pods — cada um com IP DIFERENTE e EFÊMERO.

echo ""
echo "Esperando pods ficarem prontos..."
kubectl wait --for=condition=Available deploy/web-demo --timeout=60s

echo ""
echo "=== Exercício 3: Ver endpoints (os IPs por trás do Service) ==="
kubectl get endpoints web-demo-svc
# Deve mostrar 2 endpoints (um por réplica), na porta 80.
# Se aparecer <none> ou vazio: o selector tá errado OU os pods não estão Ready.

echo ""
echo "=== Exercício 4: Acessar o Service de DENTRO do cluster ==="
echo "Vamos subir um pod temporário com 'curl' e bater no Service pelo NOME DNS."
# --rm: deleta ao sair. -i -t: interativo. --restart=Never: pra ser um Pod simples e não um Deployment.
# O comando bate 6 vezes no Service — deve cair em pods diferentes (load balancing).
kubectl run curl-test \
  --rm -i --restart=Never \
  --image=curlimages/curl:8.10.1 \
  -- sh -c 'for i in 1 2 3 4 5 6; do curl -s http://web-demo-svc; done'

# Note que usamos só "web-demo-svc" — o DNS do K8s completa pra
# web-demo-svc.default.svc.cluster.local automaticamente.

echo ""
echo "=== Exercício 5: Exec em pod EXISTENTE e curl pelo DNS ==="
# Pega o nome de um dos pods do Deployment
POD=$(kubectl get pods -l app=web-demo -o jsonpath='{.items[0].metadata.name}')
echo "Pod escolhido: $POD"

# nginx:alpine não tem curl — usamos wget que tem
kubectl exec "$POD" -- wget -qO- http://web-demo-svc
# Mostra o conteúdo de algum pod do Service (pode ser o próprio $POD ou o outro).

echo ""
echo "=== Exercício 6: NodePort via port-forward ==="
# No kind a porta NodePort não fica exposta no host por padrão.
# Solução: port-forward bate direto no Service (funciona em qualquer cluster).
echo "Em OUTRO terminal, rode:"
echo "  kubectl port-forward svc/web-demo-nodeport 8080:80"
echo "E acesse: http://localhost:8080"
echo ""
echo "(Pulando aqui pra não bloquear o script.)"

echo ""
echo "=== Exercício 7: Inspecionar um Service ==="
kubectl describe svc web-demo-svc
# Repare em: Type, IP, Port, TargetPort, Endpoints, Selector.

echo ""
echo "=== Exercício 8: Limpar ==="
kubectl delete -f service-nodeport.yaml
kubectl delete -f service-clusterip.yaml
kubectl delete -f deployment.yaml
echo "Tudo limpo."
