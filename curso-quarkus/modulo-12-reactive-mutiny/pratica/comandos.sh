#!/usr/bin/env bash
# Módulo 12 — Programação Reativa com Mutiny
#
# COMO USAR:
# 1. Copie os arquivos .java pra src/main/java/com/exemplo/cotacao/
#    (ajuste o package se seu groupId for diferente).
# 2. Em um terminal, rode:  quarkus dev
# 3. Em outro terminal, rode este script linha a linha.
#
# Esperado:
# - /cotacao devolve um JSON depois de ~300ms (chamada externa simulada)
# - /cotacao/stream empurra um evento por segundo, sem polling

set -e
BASE="http://localhost:8080/cotacao"

echo "=== 1) Uma cotação (Uni<Cotacao>) ==="
curl -s "$BASE" | jq

echo ""
echo "=== 2) Cotação por moeda (path param) ==="
curl -s "$BASE/eur" | jq

echo ""
echo "=== 3) Tempo de resposta — repare nos ~300ms de delay simulado ==="
time curl -s "$BASE" > /dev/null

echo ""
echo "=== 4) Stream SSE (Multi<Cotacao>) ==="
echo "Vai imprimir uma cotação por segundo. Aperte Ctrl+C pra sair."
echo "O -N do curl é OBRIGATORIO: desliga buffering, senao voce nao ve nada chegar em tempo real."
echo ""
curl -N "$BASE/stream"
