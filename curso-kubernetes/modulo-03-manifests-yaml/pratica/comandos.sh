#!/usr/bin/env bash
# Módulo 03 — Manifests YAML
# Prática: aplicar manifests, explorar kubectl explain e dry-run.
#
# PRÉ-REQUISITO: cluster rodando (kind create cluster --name estudo)
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercício 1: Inspecionar os manifests ANTES de aplicar ==="
# Sempre uma boa pratica olhar o YAML antes de jogar no cluster.
ls -la pod.yaml multi.yaml
echo "(dê uma lida nos dois antes de continuar)"

echo ""
echo "=== Exercício 2: kubectl explain — descobrindo campos ==="
# Top-level do Pod
kubectl explain Pod | head -20
echo "---"
# Campos do spec
kubectl explain Pod.spec | head -25
echo "---"
# Campos de cada container (esse é o mais útil de decorar visualmente)
kubectl explain Pod.spec.containers | head -30

echo ""
echo "=== Exercício 3: Aplicar o pod manual (declarativo) ==="
kubectl apply -f pod.yaml
kubectl get pod web-manual
kubectl wait --for=condition=Ready pod/web-manual --timeout=60s

echo ""
echo "=== Exercício 4: Idempotência — apply de novo NÃO dá erro ==="
kubectl apply -f pod.yaml
kubectl apply -f pod.yaml
# (note o "unchanged" na saída — esse é o ponto)

echo ""
echo "=== Exercício 5: kubectl create FALHA quando recurso já existe ==="
# Vai dar erro (esperado). O || true só evita derrubar o script.
kubectl create -f pod.yaml || echo ">>> ERRO ESPERADO: create não é idempotente"

echo ""
echo "=== Exercício 6: Filtrar por label ==="
kubectl get pods -l app=web
kubectl get pods -l env=estudo
kubectl get pods -l tier=frontend,env=estudo

echo ""
echo "=== Exercício 7: Inspecionar annotations ==="
kubectl get pod web-manual -o jsonpath='{.metadata.annotations}'
echo ""

echo ""
echo "=== Exercício 8: Aplicar o multi-doc (3 pods de uma vez) ==="
kubectl apply -f multi.yaml
kubectl get pods -l projeto=multi
kubectl wait --for=condition=Ready pod/multi-front pod/multi-cache --timeout=120s

echo ""
echo "=== Exercício 9: Gerar YAML com --dry-run=client (sem criar) ==="
# Não cria nada — só imprime o YAML que SERIA criado.
kubectl run gerado --image=nginx:alpine --dry-run=client -o yaml | head -25
echo ""
echo "(use isso pra ter um esqueleto rapido em vez de digitar do zero)"

echo ""
echo "=== Exercício 10: Exportar YAML do que está rodando ==="
kubectl get pod web-manual -o yaml | head -15
echo "(vem cheio de campos de status/managedFields — pra versionar no git, escreva manual)"

echo ""
echo "=== Exercício 11: kubectl diff (o que mudaria se eu aplicasse?) ==="
kubectl diff -f pod.yaml || echo "(sem diff = manifest local igual ao do cluster)"

echo ""
echo "=== Exercício 12: Limpar TUDO via arquivo ==="
kubectl delete -f multi.yaml
kubectl delete -f pod.yaml

echo ""
echo "=== Fim ==="
echo "Próximo passo: encarar o desafio em ../desafio/pod.yaml"
