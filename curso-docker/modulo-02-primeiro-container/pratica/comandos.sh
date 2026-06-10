#!/usr/bin/env bash
# Módulo 02 — Primeiro Container
# Prática: ciclo de vida, run, exec, stop, logs
#
# Rode linha a linha (recomendado) ou: bash comandos.sh
# Alguns exercícios abrem shell interativo — nesse caso, rode na mão.

set -e  # para se algum comando falhar

echo "=== Exercício 1: nginx em background com nome e porta ==="
# -d  = detached (background)
# --name = facilita os próximos comandos
# -p 8080:80 = porta 8080 no seu PC vira porta 80 dentro do container
docker run -d --name web -p 8080:80 nginx
# Abra http://localhost:8080 no navegador — deve mostrar "Welcome to nginx!"

echo ""
echo "=== Exercício 2: Listar containers rodando (formato customizado) ==="
# --format usa templates Go — mostra só o que interessa
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Exercício 3: Ver os logs do nginx ==="
# logs mostra o que o processo principal escreveu na stdout/stderr
docker logs web | head -5
# Dica: use -f pra seguir os logs em tempo real (Ctrl+C pra sair).

echo ""
echo "=== Exercício 4: Ver os processos rodando DENTRO do container ==="
# docker top = ps do lado de fora vendo processos do container
docker top web

echo ""
echo "=== Exercício 5: Entrar no container com exec e ver arquivos ==="
# exec roda um comando NUM container que já existe e está rodando
# -it = interativo + terminal (necessário pra shell)
# Aqui rodamos um comando único, sem entrar de fato:
docker exec web ls /etc/nginx
# Pra entrar de verdade (rode na mão, sem o set -e atrapalhando):
#   docker exec -it web sh
#   # dentro: cat /etc/nginx/nginx.conf, exit pra sair

echo ""
echo "=== Exercício 6: Parar o nginx com graça (SIGTERM) ==="
# docker stop = SIGTERM, espera 10s, depois SIGKILL se precisar
docker stop web

echo ""
echo "=== Exercício 7: Confirmar que parou (mas continua existindo) ==="
docker ps                     # vazio
docker ps -a --filter "name=web" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=== Exercício 8: Religar e parar de novo, agora removendo ==="
docker start web
sleep 1
docker stop web
docker rm web                 # remove de vez

echo ""
echo "=== Exercício 9: Alpine interativo com shell e --rm ==="
# Rode na mão pra experimentar — comentado pra não travar o script:
#   docker run -it --rm alpine sh
#   # dentro: cat /etc/os-release, ls /, exit
# --rm garante que o container some sozinho ao sair.

echo ""
echo "=== Exercício 10: Execução pontual e descartável ==="
# Roda um comando único, mostra o resultado, container some.
docker run --rm alpine uname -a

echo ""
echo "=== Limpeza final: remove containers parados ==="
docker container prune -f

echo ""
echo "=== Pronto! Containers rodando agora: ==="
docker ps
