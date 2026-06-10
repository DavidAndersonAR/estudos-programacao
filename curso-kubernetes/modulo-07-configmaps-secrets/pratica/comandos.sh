#!/usr/bin/env bash
# Modulo 07 — ConfigMaps e Secrets
# Pratica: app configuravel via ConfigMap + Secret
#
# PRE-REQUISITO: cluster do modulo 01 rodando
#   kind create cluster --name estudo
#
# Rode linha a linha pra acompanhar.

set -e

echo "=== Exercicio 1: Criar ConfigMap IMPERATIVO ==="
# So pra praticar — dps vamos apagar e usar o YAML.
kubectl create configmap teste-cm \
  --from-literal=COR=azul \
  --from-literal=TAMANHO=42
kubectl get cm teste-cm -o yaml
kubectl delete cm teste-cm

echo ""
echo "=== Exercicio 2: Criar Secret IMPERATIVO ==="
kubectl create secret generic teste-secret \
  --from-literal=API_KEY='abc-123-xyz'
# Repare: 'describe' nao mostra o valor (so o tamanho)
kubectl describe secret teste-secret
# Pra ver o valor: pega o base64 e decodifica
kubectl get secret teste-secret -o jsonpath='{.data.API_KEY}' | base64 -d
echo ""
kubectl delete secret teste-secret

echo ""
echo "=== Exercicio 3: Aplicar tudo via YAML (DECLARATIVO) ==="
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml

echo ""
echo "Esperando os pods ficarem prontos..."
kubectl wait --for=condition=Available deploy/app-configuravel --timeout=120s

echo ""
echo "=== Exercicio 4: Inspecionar ConfigMap e Secret ==="
kubectl get cm app-config -o yaml
echo ""
echo "Secret (so mostra '<bytes>', sem vazar valor):"
kubectl describe secret db-secret

echo ""
echo "=== Exercicio 5: Ver as env vars dentro do pod ==="
POD=$(kubectl get pod -l app=app-configuravel -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $POD"
echo ""
echo "--- LOG_LEVEL (do ConfigMap via env.valueFrom) ---"
kubectl exec "$POD" -- printenv LOG_LEVEL
echo "--- FEATURE_FLAG (do ConfigMap via envFrom) ---"
kubectl exec "$POD" -- printenv FEATURE_FLAG
echo "--- DB_PASSWORD (do Secret) ---"
kubectl exec "$POD" -- printenv DB_PASSWORD
echo "--- DB_USER (do Secret via envFrom) ---"
kubectl exec "$POD" -- printenv DB_USER

echo ""
echo "=== Exercicio 6: Ver arquivos do ConfigMap montados como volume ==="
echo "--- Conteudo de /etc/app/ ---"
kubectl exec "$POD" -- ls -la /etc/app/
echo ""
echo "--- /etc/app/app.properties ---"
kubectl exec "$POD" -- cat /etc/app/app.properties

echo ""
echo "=== Exercicio 7: Atualizar ConfigMap e ver o que muda ==="
# Editando in-place pra demo (em real seria editar o YAML + apply)
kubectl patch cm app-config --type merge -p '{"data":{"LOG_LEVEL":"info"}}'

echo "Aguarda 5s e olha o ARQUIVO (volume atualiza sozinho, com delay)..."
sleep 5
kubectl exec "$POD" -- cat /etc/app/LOG_LEVEL || true
echo ""
echo "Agora olha a ENV VAR (NAO atualiza — precisa restart!):"
kubectl exec "$POD" -- printenv LOG_LEVEL
echo "(Continua 'debug' mesmo o CM ja sendo 'info')"

echo ""
echo "=== Exercicio 8: Restart do deployment pra pegar a env nova ==="
kubectl rollout restart deploy/app-configuravel
kubectl rollout status deploy/app-configuravel --timeout=60s
POD2=$(kubectl get pod -l app=app-configuravel -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD2" -- printenv LOG_LEVEL
echo "(Agora ja virou 'info')"

echo ""
echo "=== Exercicio 9: Limpar ==="
kubectl delete -f deployment.yaml -f secret.yaml -f configmap.yaml
echo ""
echo "Pronto! Proximo: desafio/"
