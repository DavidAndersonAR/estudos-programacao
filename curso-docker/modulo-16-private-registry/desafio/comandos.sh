#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 16 — Registry privado COM autenticação
#
# Objetivo:
# Subir um registry local que exige usuário/senha pra push e pull. É o setup
# mínimo aceitável pra um time pequeno antes de partir pra Harbor/cloud.
#
# Você vai:
# 1. Criar um arquivo htpasswd com usuário + senha
# 2. Subir o registry:2 montando esse arquivo e ativando auth básica
# 3. Tentar push SEM login (deve falhar com 401)
# 4. docker login no localhost:5000
# 5. Push autenticado (deve funcionar)
# 6. Bônus: replicar o fluxo no ghcr.io
#
# 💡 Dicas:
# - htpasswd vive na imagem httpd:2 — não precisa instalar nada
# - registry:2 lê auth via 3 env vars: REGISTRY_AUTH=htpasswd,
#   REGISTRY_AUTH_HTPASSWD_REALM, REGISTRY_AUTH_HTPASSWD_PATH
# - Sem TLS, o Docker reclama se não for "localhost". Em rede real,
#   gere certificado (Let's Encrypt ou self-signed) e monte em /certs.

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: criar pasta ./auth e gerar htpasswd com usuario=admin senha=senha123"
# mkdir ...
# docker run --rm httpd:2 htpasswd ...

echo "TODO 2: subir registry:2 com auth ativada montando ./auth em /auth"
# docker run -d -p 5000:5000 --name registry-auth \
#   -v ... \
#   -e REGISTRY_AUTH=... \
#   registry:2

echo "TODO 3: tentar push SEM login — deve falhar com 'no basic auth credentials'"
# docker tag alpine:3.20 localhost:5000/segura:v1
# docker push localhost:5000/segura:v1   # esperado: erro 401

echo "TODO 4: fazer docker login localhost:5000"
# docker login ...

echo "TODO 5: push autenticado — agora vai"
# docker push localhost:5000/segura:v1

echo "TODO 6: verificar via API com credenciais"
# curl -u admin:senha123 http://localhost:5000/v2/_catalog

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# ---------- PARTE 1: Registry local autenticado ----------

# 1.1 Cria pasta pro arquivo de senhas
mkdir -p auth

# 1.2 Gera htpasswd com bcrypt (-B) — usuario=admin / senha=senha123
# A flag -c CRIA o arquivo (sobrescreve). Pra adicionar mais usuarios depois, tire o -c.
docker run --rm --entrypoint htpasswd httpd:2 -Bbn admin senha123 > auth/htpasswd
cat auth/htpasswd   # confira: deve mostrar "admin:$2y$05$..."

# 1.3 Sobe o registry com auth básica
# REGISTRY_AUTH=htpasswd                       -> liga o mecanismo
# REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm  -> nome que aparece no prompt
# REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd   -> arquivo dentro do container
docker run -d -p 5000:5000 --name registry-auth \
  -v "$(pwd)/auth:/auth" \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  registry:2

sleep 2

# 1.4 Prepara uma imagem cobaia
docker pull alpine:3.20
docker tag alpine:3.20 localhost:5000/segura:v1

# 1.5 Tenta push SEM login — vai falhar com 401
# (sem set -e nesse bloco; queremos ver o erro)
docker push localhost:5000/segura:v1 || echo ">>> falhou como esperado (401)"

# 1.6 Login
echo "senha123" | docker login localhost:5000 -u admin --password-stdin

# 1.7 Push autenticado — agora funciona
docker push localhost:5000/segura:v1

# 1.8 Inspeciona via API (curl precisa do -u também)
curl -s -u admin:senha123 http://localhost:5000/v2/_catalog
echo ""

# 1.9 Logout e limpeza
docker logout localhost:5000
docker stop registry-auth && docker rm registry-auth
# (a pasta auth/ pode ficar pra próxima)

# ---------- PARTE 2: Mesmo fluxo no ghcr.io ----------
#
# Pré-requisito: PAT do GitHub com escopo write:packages, read:packages.
# Gere em: https://github.com/settings/tokens (classic).
#
# export CR_PAT=ghp_xxxxxxxxxxxxxxxxxxxx
# export GH_USER=davidanderson    # seu usuário GitHub em minúsculo
#
# # Login (use --password-stdin sempre — token NUNCA vai pro histórico)
# echo "$CR_PAT" | docker login ghcr.io -u "$GH_USER" --password-stdin
#
# # Retag e push
# docker tag alpine:3.20 ghcr.io/$GH_USER/segura:v1
# docker push ghcr.io/$GH_USER/segura:v1
#
# # A imagem aparece em: https://github.com/$GH_USER?tab=packages
# # Por padrão fica PRIVADA — vá em Package Settings pra deixar pública se quiser.
#
# docker logout ghcr.io

# ---------- Notas finais ----------
# - Em produção: SEMPRE TLS. Auth básica sem HTTPS expõe a senha em texto claro
#   na rede.
# - htpasswd com bcrypt (-B) é o recomendado. -b é simples mas menos seguro.
# - Pra múltiplos usuários, basta rodar 'htpasswd' várias vezes (sem -c) e
#   acumular no mesmo arquivo.
# - Pra time grande, parta direto pra Harbor — htpasswd não escala.
SOLUTION
