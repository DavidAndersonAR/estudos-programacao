#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 05 — comandos pra validar a solução
#
# Objetivo:
# 1. Aplicar manifestos.yaml (Deployment api + Service api-svc + Pod cliente)
# 2. Esperar tudo ficar pronto
# 3. Do pod "cliente", bater 30 vezes em http://api-svc (pelo NOME DNS)
# 4. Olhar os logs dos 3 pods da api e ver que cada um recebeu
#    aproximadamente 1/3 das requisições — provando load balancing
# 5. Limpar
#
# Antes de rodar: implemente os TODOs em manifestos.yaml (ou descomente a solução).

set -e

echo "=== Passo 1: Aplicar manifestos ==="
kubectl apply -f manifestos.yaml

echo ""
echo "=== Passo 2: Esperar Deployment e Pod cliente ficarem prontos ==="
kubectl wait --for=condition=Available deploy/api --timeout=60s
kubectl wait --for=condition=Ready pod/cliente --timeout=60s

echo ""
echo "=== Passo 3: Ver o que tá no ar ==="
kubectl get pods -o wide
kubectl get svc api-svc
kubectl get endpoints api-svc
# A linha de endpoints DEVE mostrar 3 IPs:5678 — um por réplica.

echo ""
echo "=== Passo 4: Disparar 30 requisições do cliente pro Service (pelo DNS) ==="
kubectl exec cliente -- sh -c 'for i in $(seq 1 30); do curl -s http://api-svc; done' > /dev/null
echo "30 requisições enviadas pra http://api-svc"

echo ""
echo "=== Passo 5: Ver quantas requisições cada pod da api recebeu ==="
# Cada request gera 1 linha de log. Contamos as linhas por pod.
for POD in $(kubectl get pods -l app=api -o jsonpath='{.items[*].metadata.name}'); do
  COUNT=$(kubectl logs "$POD" | wc -l)
  echo "Pod $POD => $COUNT linhas de log"
done

# Se o balanceamento tá funcionando, os 3 pods devem ter ~10 cada
# (não vai ser exato — kube-proxy em modo iptables é probabilístico).
# Se um pod recebeu 0: cheque selector / labels / readiness.

echo ""
echo "=== Passo 6: Teste rápido de DNS de dentro do cliente ==="
kubectl exec cliente -- nslookup api-svc || true
# Mostra o ClusterIP do Service — provando que o DNS interno tá resolvendo.

echo ""
echo "=== Passo 7: Limpar ==="
kubectl delete -f manifestos.yaml
echo "Tudo limpo. Próximo: módulo 06 — Namespaces."
