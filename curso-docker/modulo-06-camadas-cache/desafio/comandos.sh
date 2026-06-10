#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 06 — Refatorar Dockerfile pra Cache Máximo
#
# Objetivo:
# 1. Olhar o Dockerfile original (comentado dentro de ./Dockerfile)
# 2. Identificar os 6 problemas listados
# 3. Reescrever o Dockerfile seguindo os TODOs
# 4. Provar que rebuild incremental ficou bem mais rápido
#
# Estrutura fictícia que você vai criar pra testar:
#   desafio/
#   ├── Dockerfile         (já existe — você edita)
#   ├── requirements.txt   (você cria — lista de libs Python)
#   ├── VERSION            (você cria — string da versão)
#   └── src/main.py        (você cria — código que vai mudar nos testes)

set -e
cd "$(dirname "$0")"

echo "=== Passo 1: Preparar arquivos do app fictício ==="

mkdir -p src

cat > requirements.txt <<'EOF'
flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
EOF

cat > VERSION <<'EOF'
1.0.0
EOF

cat > src/main.py <<'EOF'
# Código mínimo só pra termos algo pra "editar" e ver o cache funcionando.
print("App do desafio rodando!")
EOF

# .dockerignore — bônus do desafio
cat > .dockerignore <<'EOF'
.git
tests/
__pycache__
*.pyc
.venv
EOF

echo "Arquivos criados:"
ls -la

echo ""
echo "=== Passo 2: Build INICIAL (cache vazio) ==="
# Lembre: você precisa ter editado o Dockerfile descomentando a solução
# (ou implementado os TODOs) pra esse comando funcionar.
time docker build --no-cache -t desafio-cache:v1 .

echo ""
echo "=== Passo 3: Simular edição no código-fonte ==="
echo "# editado em $(date)" >> src/main.py

echo ""
echo "=== Passo 4: Rebuild incremental — DEVE ser rápido ==="
# Se você ordenou direito, esta etapa pula:
#   - apt-get install (cache OK, deps de sistema não mudaram)
#   - pip install (cache OK, requirements.txt não mudou)
# E só refaz o COPY src/.
time docker build -t desafio-cache:v2 .

echo ""
echo "=== Passo 5: Inspecionar as camadas ==="
docker history desafio-cache:v2

echo ""
echo "=== Passo 6: Mudar requirements.txt e ver cache QUEBRANDO certinho ==="
echo "" >> requirements.txt
echo "click==8.1.7" >> requirements.txt
echo "Rebuild (agora pip install precisa rodar de novo — esperado):"
time docker build -t desafio-cache:v3 .

echo ""
echo "=== Pronto! ==="
echo "💡 Verifique que:"
echo "   - Passo 4 (só código mudou) foi MUITO mais rápido que o inicial"
echo "   - Passo 6 (deps mudaram) refez o pip install — comportamento correto"
echo "   - docker history mostra camadas separadas pra deps e código"
echo ""
echo "Limpeza (opcional):"
echo "  docker rmi desafio-cache:v1 desafio-cache:v2 desafio-cache:v3"
