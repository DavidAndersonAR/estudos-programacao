#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 09 — Config 12-factor para uma app
#
# Cenário:
# Sua app aceita 4 envs: LOG_LEVEL, PORT, DB_HOST, FEATURE_FLAG.
# O Dockerfile já tem defaults sensatos (info / 8080 / localhost / false).
#
# Você tem 3 ambientes: dev (defaults), staging e prod.
# Crie a config certa pra cada um SEM tocar no Dockerfile.
#
# Tarefas:
#   1. Buildar a imagem (uma vez só — a imagem é a MESMA pros 3 ambientes).
#   2. Rodar em "dev" usando só os defaults da imagem.
#   3. Criar um arquivo .env.staging com LOG_LEVEL=debug, PORT=8080, DB_HOST=staging-db, FEATURE_FLAG=true
#      e rodar usando ele.
#   4. Rodar em "prod" usando o .env já pronto (LOG_LEVEL=warn, PORT=80, etc).
#   5. Bonus: rodar em prod mas sobrescrevendo LOG_LEVEL=debug só pra essa execução (-e ganha do --env-file).
#
# 💡 Dicas:
#   - docker build -t app-config .
#   - docker run --rm app-config                                    # dev (defaults)
#   - docker run --rm --env-file .env.staging app-config            # staging
#   - docker run --rm --env-file .env app-config                    # prod
#   - -e sobrescreve --env-file: --env-file .env -e LOG_LEVEL=debug

set -e
cd "$(dirname "$0")"

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: build da imagem"
# docker build -t app-config .

echo "TODO 2: rodar com defaults (dev)"
# docker run ...

echo "TODO 3: criar .env.staging e rodar"
# cat > .env.staging <<EOF
# ...
# EOF
# docker run ...

echo "TODO 4: rodar prod com .env"
# docker run ...

echo "TODO 5 (bonus): prod com LOG_LEVEL=debug sobrescrito"
# docker run ...

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Build (UMA imagem só pros 3 ambientes — é a graça do 12-factor)
docker build -t app-config .

echo ""
echo "########## DEV (defaults do Dockerfile) ##########"
docker run --rm app-config
# LOG_LEVEL=info, PORT=8080, DB_HOST=localhost, FEATURE_FLAG=false

echo ""
echo "########## STAGING (.env.staging) ##########"
# Cria o arquivo de staging
cat > .env.staging <<'EOF'
LOG_LEVEL=debug
PORT=8080
DB_HOST=staging-db.empresa.com
FEATURE_FLAG=true
EOF

docker run --rm --env-file .env.staging app-config
# Deve aparecer "[DEBUG] Conectando em staging-db..." porque LOG_LEVEL=debug

echo ""
echo "########## PROD (.env) ##########"
docker run --rm --env-file .env app-config
# LOG_LEVEL=warn, PORT=80, DB_HOST=prod-db..., FEATURE_FLAG=true
# Feature ligada, sem linhas de DEBUG.

echo ""
echo "########## PROD com debug pontual (-e vence --env-file) ##########"
docker run --rm --env-file .env -e LOG_LEVEL=debug app-config
# Vai pro DB de prod, mas com log debug ligado só dessa vez.

echo ""
echo "########## Limpa ##########"
# docker rmi app-config
# rm .env.staging
SOLUTION
