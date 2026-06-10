#!/usr/bin/env bash
# App de demo — só fica vivo imprimindo o usuário e tentando escrever em / a cada 10s.
# A ideia é VER na prática a diferença entre rodar como root e como appuser,
# e ver o --read-only barrar a escrita.

set -u

echo "=========================================="
echo "Demo de segurança Docker"
echo "=========================================="
echo "Usuário atual: $(id)"
echo "Hostname:      $(hostname)"
echo "Filesystem /:  $(mount | grep ' / ' | head -1)"
echo "=========================================="

while true; do
  echo ""
  echo "[$(date +%H:%M:%S)] tentando escrever em /malicioso.txt ..."
  if echo "fui aqui" > /malicioso.txt 2>/dev/null; then
    echo "  ⚠️  CONSEGUI escrever em / — filesystem está gravável!"
    rm -f /malicioso.txt
  else
    echo "  ✅ bloqueado (read-only ou sem permissão) — bom!"
  fi

  echo "[$(date +%H:%M:%S)] tentando escrever em /tmp/ok.txt ..."
  if echo "ok" > /tmp/ok.txt 2>/dev/null; then
    echo "  ✅ /tmp gravável (tmpfs ou normal) — esperado"
    rm -f /tmp/ok.txt
  else
    echo "  ⚠️  /tmp também bloqueado — app real iria quebrar"
  fi

  sleep 10
done
