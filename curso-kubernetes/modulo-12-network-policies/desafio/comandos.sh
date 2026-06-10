#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 12 — Stack 3-tier blindada
#
# Roteiro:
#   1. Criar ns "shop" e 3 deployments com labels tier=web/api/db
#   2. Aplicar as policies do desafio/netpol.yaml
#   3. Testar todos os caminhos — só os permitidos devem passar
#
# PRÉ-REQUISITO: cluster kind com Calico (rode pratica/setup.sh)

set -e

NS=shop

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: criar namespace + 3 deployments (web/api/db) com labels corretas"
# kubectl create ns $NS
# kubectl -n $NS create deploy web --image=...
# (lembre de SETAR a label tier=web no template — use kubectl edit ou apply -f)

echo "TODO 2: aplicar policies"
# kubectl apply -f desafio/netpol.yaml

echo "TODO 3: rodar os 6 testes (3 deviam passar, 3 deviam falhar)"

# ============================
# SOLUÇÃO DE REFERÊNCIA
# ============================

: <<'SOLUTION'
# 1. Namespace + apps
kubectl create namespace "$NS"

# Vamos usar o postgres como db, netshoot como web/api (pra ter ferramentas de teste)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {tier: web}}
  template:
    metadata: {labels: {tier: web}}
    spec:
      containers:
        - name: c
          image: nicolaka/netshoot
          command: ["sleep", "infinity"]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: api, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {tier: api}}
  template:
    metadata: {labels: {tier: api}}
    spec:
      containers:
        - name: c
          image: nicolaka/netshoot
          command: ["sh", "-c", "nc -lk -p 80 -e /bin/cat & sleep infinity"]
          ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata: {name: api, namespace: $NS}
spec:
  selector: {tier: api}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: db, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {tier: db}}
  template:
    metadata: {labels: {tier: db}}
    spec:
      containers:
        - name: postgres
          image: postgres:16-alpine
          env:
            - {name: POSTGRES_PASSWORD, value: "x"}
          ports: [{containerPort: 5432}]
---
apiVersion: v1
kind: Service
metadata: {name: db, namespace: $NS}
spec:
  selector: {tier: db}
  ports: [{port: 5432, targetPort: 5432}]
EOF

# Espera tudo subir
kubectl -n "$NS" wait --for=condition=Ready pod --all --timeout=180s

# 2. Aplicar policies
kubectl apply -f desafio/netpol.yaml
kubectl -n "$NS" get netpol

# 3. Testes
echo ""
echo "===== TESTES — esperado vs real ====="

run() {
  # $1 = descrição, $2 = pod de origem (deploy/), $3 = comando dentro, $4 = "PASSA" ou "FALHA"
  echo ""
  echo "→ $1 (esperado: $4)"
  if kubectl -n "$NS" exec "deploy/$2" -- sh -c "$3" 2>&1 | head -3; then
    echo "  [resultado: SUCESSO]"
  else
    echo "  [resultado: FALHA]"
  fi
}

run "web → api:80"           web "nc -zv -w 3 api 80"        "PASSA"
run "web → db:5432"          web "nc -zv -w 3 db 5432"       "FALHA"
run "api → db:5432"          api "nc -zv -w 3 db 5432"       "PASSA"
run "api → web:80 (volta)"   api "nc -zv -w 3 web-pod 80"    "FALHA (sem service de web, mas o ponto é egress)"
run "db  → api:80"           db  "nc -zv -w 3 api 80"        "FALHA"
run "db  → google.com:443"   db  "nc -zv -w 3 google.com 443" "FALHA"

# 4. Limpar
# kubectl delete namespace "$NS"
SOLUTION
