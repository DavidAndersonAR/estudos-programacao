#!/usr/bin/env bash
# Módulo 10 — Logs e Monitoramento
# Prática: explorando docker logs, stats, top, events.
#
# Rode linha a linha (ou bash comandos.sh pra rodar tudo).

set -e

echo "=== Exercício 1: Rodar container que gera logs (alpine em loop) ==="
# Loga uma linha por segundo, alternando stdout (out) e stderr (err)
docker run -d --name log-demo alpine sh -c '
  i=0
  while true; do
    i=$((i+1))
    if [ $((i % 5)) -eq 0 ]; then
      echo "ERROR linha $i" >&2
    else
      echo "INFO  linha $i"
    fi
    sleep 1
  done
'
sleep 6  # deixa gerar uns logs

echo ""
echo "=== Exercício 2: docker logs (tudo) ==="
docker logs log-demo

echo ""
echo "=== Exercício 3: docker logs --tail 20 ==="
docker logs --tail 20 log-demo

echo ""
echo "=== Exercício 4: docker logs --timestamps --since 5s ==="
docker logs --timestamps --since 5s log-demo

echo ""
echo "=== Exercício 5: docker logs --follow (10s e sai com timeout) ==="
# --follow trava no terminal; aqui usamos timeout pra demonstrar
timeout 10 docker logs --follow --tail 5 log-demo || true

echo ""
echo "=== Exercício 6: docker stats (snapshot, sem stream contínuo) ==="
docker stats --no-stream

echo ""
echo "=== Exercício 7: docker stats com format customizado ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "=== Exercício 8: docker top (processos dentro do container) ==="
docker top log-demo

echo ""
echo "=== Exercício 9: Container com log driver e rotação ==="
# max-size=1m, max-file=2 — total ~2MB por container
docker run -d --name log-rotacionado \
  --log-driver json-file \
  --log-opt max-size=1m \
  --log-opt max-file=2 \
  alpine sh -c 'while true; do echo "tick $(date)"; sleep 1; done'

echo ""
echo "=== Exercício 10: Onde os logs ficam no disco ==="
docker inspect --format='{{.LogPath}}' log-rotacionado
# Em Docker Desktop esse caminho é DENTRO da VM — não dá pra abrir do host.
# Em Linux nativo, você pode 'tail -f' esse arquivo direto.

echo ""
echo "=== Exercício 11: docker events (últimos 5 minutos) ==="
# --since pega histórico recente; sem --until ele streamaria pra sempre
docker events --since 5m --until 0s | head -20 || true

echo ""
echo "=== Limpeza ==="
docker rm -f log-demo log-rotacionado >/dev/null
echo "Pronto!"
