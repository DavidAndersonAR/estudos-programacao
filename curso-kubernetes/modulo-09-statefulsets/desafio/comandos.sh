#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 09 — Postgres no K8s
#
# Objetivo:
# 1. Escrever os 3 manifestos em manifestos.yaml (Secret + Headless Svc + StatefulSet)
# 2. Aplicar e ver postgres-0 ficar Ready
# 3. Conectar via psql client num pod separado, usando o DNS postgres-0.pg-svc
# 4. Criar tabela, inserir dado
# 5. Deletar postgres-0 e provar que o dado SOBREVIVEU (PVC reaproveitado)
# 6. (Bônus) Limpar tudo, inclusive PVC
#
# 💡 Dicas:
#   - Senha vem da Secret (POSTGRES_PASSWORD) — passe via PGPASSWORD pro psql
#   - DNS do pod: postgres-0.pg-svc.default.svc.cluster.local
#     (mas dentro do mesmo namespace basta: postgres-0.pg-svc)
#   - Pra psql client use a própria imagem postgres:16-alpine

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: aplicar manifestos.yaml"
# kubectl apply -f manifestos.yaml

echo "TODO 2: esperar postgres-0 ficar Ready"
# kubectl rollout status statefulset/postgres --timeout=180s

echo "TODO 3: subir pod cliente com psql"
# kubectl run pg-client --image=postgres:16-alpine --restart=Never --command -- sleep 3600

echo "TODO 4: conectar via DNS do pod e criar tabela"
# kubectl exec pg-client -- env PGPASSWORD=... psql -h postgres-0.pg-svc -U postgres -d estudo -c "..."

echo "TODO 5: deletar postgres-0 e ver o dado sobrevivendo"
# kubectl delete pod postgres-0
# (espera voltar)
# select * na tabela — dado tem que estar lá

echo "TODO 6 (bônus): limpar tudo (inclusive PVC)"
# kubectl delete -f manifestos.yaml
# kubectl delete pvc -l app=postgres

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco SOLUTION pra rodar)
# ============================

: <<'SOLUTION'
# 1. Aplica tudo
kubectl apply -f manifestos.yaml
kubectl get sts,svc,secret

# 2. Espera Postgres ficar pronto
kubectl rollout status statefulset/postgres --timeout=180s
kubectl get pods -l app=postgres -o wide
kubectl get pvc
# Deve aparecer: pvc "data-postgres-0" no estado Bound

# 3. Sobe um pod cliente com a CLI do Postgres (mesma imagem, mais simples)
kubectl run pg-client --image=postgres:16-alpine --restart=Never --command -- sleep 3600
kubectl wait --for=condition=Ready pod/pg-client --timeout=60s

# 4. Pega a senha da Secret e conecta via DNS estável do pod
PGPASS=$(kubectl get secret pg-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d)

# Conecta no pod 0 pelo NOME DNS — não pelo IP.
# É exatamente isso que o StatefulSet permite.
kubectl exec pg-client -- env PGPASSWORD="$PGPASS" \
  psql -h postgres-0.pg-svc -U postgres -d estudo -c "SELECT version();"

# 5. Cria tabela e insere dado
kubectl exec pg-client -- env PGPASSWORD="$PGPASS" \
  psql -h postgres-0.pg-svc -U postgres -d estudo -c "
    CREATE TABLE IF NOT EXISTS alunos (id serial PRIMARY KEY, nome text);
    INSERT INTO alunos (nome) VALUES ('david'), ('claude');
    SELECT * FROM alunos;
  "

# 6. A prova dos nove: mata o pod e vê se o dado sobrevive
echo ""
echo "=== Matando postgres-0... ==="
kubectl delete pod postgres-0
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s

echo ""
echo "=== Pod renasceu. Mesmo nome, mesmo PVC. Dado ainda lá? ==="
kubectl exec pg-client -- env PGPASSWORD="$PGPASS" \
  psql -h postgres-0.pg-svc -U postgres -d estudo -c "SELECT * FROM alunos;"
# Os 2 inserts continuam lá. PVC sobreviveu ao delete do pod. 🎉

# 7. Limpeza completa (inclusive PVC — senão fica ocupando disco)
kubectl delete pod pg-client
kubectl delete -f manifestos.yaml
kubectl delete pvc -l app=postgres
# Confirma que sumiu:
kubectl get pvc
SOLUTION
