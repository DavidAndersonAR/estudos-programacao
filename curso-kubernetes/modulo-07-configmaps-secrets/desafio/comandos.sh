#!/usr/bin/env bash
# 🎯 DESAFIO DO MODULO 07 — Nginx HTTPS com config + cert vindos do K8s
#
# Antes de rodar, abra desafio/manifestos.yaml e tente preencher os TODOs.
# Quando travar, descomente a SOLUCAO de manifestos.yaml e rode esse script.
#
# Pre-requisito: cluster do modulo 01 rodando e openssl instalado.

set -e

# ============================
# PASSO 1 — Gerar certificado TLS self-signed (so pra teste)
# ============================
echo "=== Passo 1: Gerando cert TLS self-signed ==="
TMPDIR=$(mktemp -d)
openssl req -x509 -newkey rsa:2048 -nodes -days 30 \
  -keyout "$TMPDIR/tls.key" -out "$TMPDIR/tls.crt" \
  -subj "/CN=desafio.local/O=Estudo"

# ============================
# PASSO 2 — Criar o Secret TLS (imperativo — mais facil que YAML)
# ============================
echo ""
echo "=== Passo 2: Criando Secret kubernetes.io/tls ==="
kubectl create secret tls nginx-tls \
  --cert="$TMPDIR/tls.crt" \
  --key="$TMPDIR/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

# Confirma o tipo
kubectl get secret nginx-tls -o jsonpath='{.type}{"\n"}'
# Deve imprimir: kubernetes.io/tls

# ============================
# PASSO 3 — Aplicar o resto (ConfigMaps + Secret app + Deployment)
# ============================
echo ""
echo "=== Passo 3: Aplicando manifestos.yaml ==="
echo "(Lembre de descomentar a SOLUCAO no manifestos.yaml antes!)"
kubectl apply -f manifestos.yaml

# ============================
# PASSO 4 — Esperar e verificar
# ============================
echo ""
echo "=== Passo 4: Aguardando deploy ficar pronto ==="
kubectl rollout status deploy/nginx-https --timeout=120s

POD=$(kubectl get pod -l app=nginx-https -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $POD"

# ============================
# PASSO 5 — Validacoes
# ============================
echo ""
echo "=== Passo 5a: nginx.conf foi montado corretamente? ==="
kubectl exec "$POD" -- cat /etc/nginx/nginx.conf | head -10

echo ""
echo "=== Passo 5b: cert TLS esta dentro do pod? ==="
kubectl exec "$POD" -- ls -la /etc/nginx/tls/
# Deve mostrar tls.crt e tls.key

echo ""
echo "=== Passo 5c: env vars do CM e do Secret chegaram? ==="
kubectl exec "$POD" -- printenv APP_ENV
kubectl exec "$POD" -- printenv SENHA_ADMIN

echo ""
echo "=== Passo 5d: HTTPS responde? ==="
# Port-forward em background e curl com -k (cert self-signed)
kubectl port-forward "$POD" 8443:443 >/dev/null 2>&1 &
PF_PID=$!
sleep 2
curl -k -s https://localhost:8443/ || true
kill $PF_PID 2>/dev/null || true

# ============================
# PASSO 6 — Limpar
# ============================
echo ""
echo "=== Passo 6: Limpar ==="
kubectl delete -f manifestos.yaml --ignore-not-found
kubectl delete secret nginx-tls --ignore-not-found
rm -rf "$TMPDIR"

echo ""
echo "Desafio concluido!"
echo ""
echo "💡 Pontos que voce praticou:"
echo "  - ConfigMap com arquivo de config (nginx.conf) via volume + subPath"
echo "  - Secret kubernetes.io/tls criado imperativamente"
echo "  - envFrom puxando vars de CM E de Secret"
echo "  - Diferenca entre mount normal (sobrescreve dir) e subPath (so 1 arquivo)"
