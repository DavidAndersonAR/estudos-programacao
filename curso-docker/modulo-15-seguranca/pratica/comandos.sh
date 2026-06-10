#!/usr/bin/env bash
# Módulo 15 — Segurança
# Prática: comparar imagem insegura vs segura, e aplicar runtime hardening
#
# Rode bloco por bloco (ou bash comandos.sh pra ver tudo).

set -e

cd "$(dirname "$0")"

echo "=== Exercício 1: Build das duas imagens ==="
docker build -f Dockerfile.inseguro -t demo-inseguro:1.0 .
docker build -f Dockerfile.seguro   -t demo-seguro:1.0   .

echo ""
echo "=== Exercício 2: Comparar tamanhos ==="
docker images | grep -E "demo-(inseguro|seguro)"
# Alpine + nada → bem menor que ubuntu + curl + sudo + wget.

echo ""
echo "=== Exercício 3: Ver secret vazando em docker history (INSEGURA) ==="
# OLHA O DB_PASSWORD aí no history! É por isso que ENV não serve pra secret.
docker history demo-inseguro:1.0 | grep -i password || echo "(grep não achou nessa view, tente --no-trunc)"
docker history --no-trunc demo-inseguro:1.0 | grep -i DB_PASSWORD || true

echo ""
echo "=== Exercício 4: Rodar INSEGURA — ver que está como root ==="
docker run --rm -d --name demo-inseguro demo-inseguro:1.0
sleep 2
echo "Quem está rodando dentro?"
docker exec demo-inseguro id
# uid=0(root) — péssimo
docker stop demo-inseguro >/dev/null

echo ""
echo "=== Exercício 5: Rodar SEGURA com hardening completo ==="
docker run --rm -d \
  --name demo-seguro \
  --read-only \
  --tmpfs /tmp:rw,size=16m \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --user 1000:1000 \
  demo-seguro:1.0
sleep 2
echo "Quem está rodando dentro?"
docker exec demo-seguro id
# uid=1000(appuser) — ótimo

echo ""
echo "=== Exercício 6: Ver os logs — tentativa de escrita em / deve ser BARRADA ==="
sleep 12   # deixa o loop do app.sh rodar pelo menos uma vez
docker logs demo-seguro | tail -20

echo ""
echo "=== Exercício 7: Tentar escalar privilégio dentro do container seguro ==="
# Sem sudo, sem capabilities, sem no-new-privileges — não tem como virar root.
docker exec demo-seguro sh -c 'whoami; id; ls -la /etc/shadow 2>&1 || echo "(barrado, como esperado)"'

docker stop demo-seguro >/dev/null

echo ""
echo "=== Exercício 8: Scan de vulnerabilidades com docker scout ==="
# Compare as duas. A insegura (ubuntu + curl + wget + sudo) provavelmente vai vir
# com BEM mais CVEs do que a alpine enxuta.
echo "--- INSEGURA ---"
docker scout quickview demo-inseguro:1.0 || echo "(docker scout não disponível? veja docs.docker.com/scout)"
echo ""
echo "--- SEGURA ---"
docker scout quickview demo-seguro:1.0   || true

echo ""
echo "=== Exercício 9: Tentar rodar a INSEGURA com --read-only — vai quebrar? ==="
# Como ela tenta escrever em / no app.sh, com --read-only o app trava.
# Mostra que hardening em runtime NÃO substitui hardening no Dockerfile.
docker run --rm --read-only --tmpfs /tmp demo-inseguro:1.0 &
RUNPID=$!
sleep 5
kill $RUNPID 2>/dev/null || true
wait $RUNPID 2>/dev/null || true

echo ""
echo "=== Limpeza ==="
docker rmi demo-inseguro:1.0 demo-seguro:1.0 >/dev/null 2>&1 || true

echo ""
echo "=== Pronto! ==="
echo "Lições:"
echo "  - USER non-root no Dockerfile é OBRIGATÓRIO"
echo "  - --read-only + tmpfs trava muita coisa, mas o app tem que cooperar"
echo "  - Secret em ENV vaza em docker history"
echo "  - docker scout te dá visão CVE de graça"
