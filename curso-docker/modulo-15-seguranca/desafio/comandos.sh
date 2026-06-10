#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 15 — Hardening de Imagem
#
# Objetivo:
# Pegar uma imagem Node padrão (ruim) e aplicar TODO o hardening:
#  - Dockerfile reescrito (veja desafio/Dockerfile)
#  - Runtime com --read-only, --cap-drop ALL, no-new-privileges, --user
#  - Secret entrando via env_file ou docker secret (NÃO via ENV no Dockerfile)
#  - Scan com docker scout antes e depois
#
# Pré-requisito:
# Edite o Dockerfile do desafio (TODOs) e tenha um server.js + package.json mínimos
# pra build funcionar. Se não tiver, descomente o bloco "STUBS" abaixo.

set -e
cd "$(dirname "$0")"

# ============================
# STUBS — descomente se quiser rodar sem app real
# ============================
: <<'STUBS'
cat > package.json <<'JSON'
{
  "name": "demo-hardening",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {}
}
JSON

cat > server.js <<'JS'
const http = require('http');
http.createServer((req, res) => {
  if (req.url === '/healthz') { res.writeHead(200); res.end('ok'); return; }
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ user: process.getuid(), pid: process.pid, secret: process.env.DB_PASSWORD ? 'set' : 'missing' }));
}).listen(3000, () => console.log('listening on 3000 as uid', process.getuid()));
JS
STUBS

# ============================
# PASSO A — build da sua versão hardened
# ============================
echo "=== A) Build da imagem hardened ==="
docker build -t demo-hardening:1.0 .

# ============================
# PASSO B — scan com docker scout
# ============================
echo ""
echo "=== B) Scan de CVEs ==="
docker scout quickview demo-hardening:1.0 || echo "(scout opcional — pulando)"
# Bonus: docker scout recommendations demo-hardening:1.0

# ============================
# PASSO C — verificar histórico (não pode ter secret!)
# ============================
echo ""
echo "=== C) Conferindo que NÃO tem secret em history ==="
if docker history --no-trunc demo-hardening:1.0 | grep -E "PASSWORD|SECRET|TOKEN" ; then
  echo "❌ FALHOU: tem secret na imagem!"
  exit 1
else
  echo "✅ OK: nenhum secret encontrado em history"
fi

# ============================
# PASSO D — secret via env_file no RUNTIME (jeito certo)
# ============================
echo ""
echo "=== D) Secret entra via env_file (NÃO no Dockerfile) ==="
cat > /tmp/demo-secrets.env <<'ENV'
DB_PASSWORD=valor-real-vem-do-vault
JWT_SECRET=valor-real-vem-do-vault
ENV
chmod 600 /tmp/demo-secrets.env

# ============================
# PASSO E — rodar com hardening de RUNTIME completo
# ============================
echo ""
echo "=== E) docker run com TODO o hardening ==="
docker run -d \
  --name demo-hardening \
  --read-only \
  --tmpfs /tmp:rw,size=16m \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --user 1000:1000 \
  --env-file /tmp/demo-secrets.env \
  -p 3000:3000 \
  demo-hardening:1.0

sleep 3

# ============================
# PASSO F — auditar o container rodando
# ============================
echo ""
echo "=== F) Auditoria do container rodando ==="
echo "Usuário:"
docker exec demo-hardening id
echo ""
echo "Root filesystem é read-only?"
docker inspect demo-hardening --format '{{.HostConfig.ReadonlyRootfs}}'
echo ""
echo "Capabilities dropadas:"
docker inspect demo-hardening --format '{{.HostConfig.CapDrop}}'
echo ""
echo "no-new-privileges:"
docker inspect demo-hardening --format '{{.HostConfig.SecurityOpt}}'

# ============================
# PASSO G — provar que escalada está barrada
# ============================
echo ""
echo "=== G) Tentando escalar privilégio (deve falhar) ==="
docker exec demo-hardening sh -c 'whoami; touch /malicioso 2>&1 || echo "(/ read-only ✅)"; cat /etc/shadow 2>&1 || echo "(shadow inacessível ✅)"'

# ============================
# PASSO H — limpeza
# ============================
echo ""
echo "=== H) Limpeza ==="
docker stop demo-hardening >/dev/null
docker rm   demo-hardening >/dev/null
rm -f /tmp/demo-secrets.env

echo ""
echo "=========================================="
echo "✅ Hardening completo. Checklist:"
echo "  [x] Imagem base mínima + tag fixa"
echo "  [x] Multi-stage (build deps fora)"
echo "  [x] USER non-root no Dockerfile"
echo "  [x] SEM secrets em ENV/ARG"
echo "  [x] --read-only + tmpfs"
echo "  [x] --cap-drop ALL"
echo "  [x] --security-opt no-new-privileges"
echo "  [x] Secret via env_file em runtime"
echo "  [x] Scan com docker scout"
echo "=========================================="
