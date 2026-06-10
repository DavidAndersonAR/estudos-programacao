#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 10 — Métricas Básicas
#
# Objetivo:
# Montar um mini "painel de métricas" caseiro pra 3 containers de cargas
# diferentes, filtrar logs de erro e configurar rotação.
#
# Tarefas:
# 1) Suba 3 containers que consomem recursos diferentes:
#    - nginx (servidor web idle — pouca CPU/mem)
#    - redis (cache em memória — mem maior, CPU baixa)
#    - alpine "stresser" que gera CPU e logs de ERROR (pra você filtrar depois)
#
# 2) Faça um "dashboard" em UMA linha de docker stats com --format,
#    mostrando NOME, CPU, MEM USAGE e MEM %.
#
# 3) No container "stresser", filtre só as linhas com ERROR usando grep.
#
# 4) Configure o stresser com rotação de log: max-size=512k, max-file=2.
#
# 💡 Dicas:
#   - --no-stream pra stats tirar um snapshot e sair.
#   - --format aceita Go template: {{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.MemPerc}}
#   - docker logs CONTAINER 2>&1 | grep -i ERROR  (filtra stdout+stderr)
#   - rotação: --log-opt max-size=512k --log-opt max-file=2
#   - pra ver onde o log fica: docker inspect --format='{{.LogPath}}' NOME

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: suba nginx em background com nome 'web'"
# docker run -d --name web ...

echo "TODO: suba redis em background com nome 'cache'"
# docker run -d --name cache ...

echo "TODO: suba o stresser 'app' com rotação de log, gerando INFO e ERROR"
# docker run -d --name app --log-opt max-size=... --log-opt max-file=... alpine sh -c '...'

echo "TODO: dashboard com docker stats --format (snapshot)"
# docker stats --no-stream --format ...

echo "TODO: filtre só ERRORs do container app"
# docker logs app 2>&1 | grep ...

echo "TODO: mostre o caminho do arquivo de log do app"
# docker inspect --format=...

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# Limpa qualquer execução anterior
docker rm -f web cache app 2>/dev/null || true

# 1) Três containers de cargas diferentes
docker run -d --name web -p 8088:80 nginx
docker run -d --name cache redis:7-alpine

# Stresser: queima CPU num loop leve e gera logs (INFO + ERROR)
docker run -d --name app \
  --log-driver json-file \
  --log-opt max-size=512k \
  --log-opt max-file=2 \
  alpine sh -c '
    i=0
    while true; do
      i=$((i+1))
      # gasta um pouquinho de CPU
      for n in 1 2 3 4 5; do echo $n > /dev/null; done
      if [ $((i % 4)) -eq 0 ]; then
        echo "ERROR  ciclo $i falhou (simulado)" >&2
      else
        echo "INFO   ciclo $i ok"
      fi
      sleep 1
    done
  '

# Deixa rodar uns segundos pra ter dados
sleep 6

# 2) Dashboard caseiro — uma chamada, snapshot, com colunas claras
echo ""
echo "===== MINI DASHBOARD ====="
docker stats --no-stream \
  --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" \
  web cache app

# 3) Filtrar só ERRORs (stderr+stdout juntos via 2>&1)
echo ""
echo "===== ERROS DO APP ====="
docker logs app 2>&1 | grep -i error | tail -10

# 4) Onde está o log no disco + tamanho atual
echo ""
echo "===== ARQUIVO DE LOG ====="
docker inspect --format='{{.LogPath}}' app

# Bonus: top do app (processos)
echo ""
echo "===== docker top app ====="
docker top app

# Limpeza (descomente quando quiser parar)
# docker rm -f web cache app
SOLUTION
