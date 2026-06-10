#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 18 — Diagnosticar Dockerfile com 3 bugs
#
# O Dockerfile ao lado tem 3 bugs plantados:
#   BUG 1 — EXPOSE com porta errada (cosmético, mas confuso)
#   BUG 2 — CMD com typo ('pythn' em vez de 'python')
#   BUG 3 — env var APP_PORT obrigatória, sem default
#
# Sua missão:
# 1. Buildar a imagem.
# 2. Rodar e ver quebrar.
# 3. Diagnosticar cada bug usando SÓ a toolbox do módulo
#    (logs, inspect, exec, run --entrypoint sh).
# 4. Propor o fix e validar que funciona.
#
# 💡 Dicas:
#   - Sempre comece por docker logs.
#   - docker inspect --format '{{.State.ExitCode}}' mata o mistério rapidinho.
#   - Pra entrar num container que nem sobe: docker run --rm -it --entrypoint sh IMAGEM
#   - Pra passar env var em runtime: -e CHAVE=valor

set +e  # não pare ao primeiro erro — queremos VER os erros

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO Etapa 1: buildar a imagem mod18-desafio"
# docker build -t mod18-desafio .

echo "TODO Etapa 2: rodar o container e ver morrer"
# docker run -d --name desafio mod18-desafio
# docker ps -a | grep desafio

echo "TODO Etapa 3: ler os logs e o exit code"
# docker logs desafio
# docker inspect --format '{{.State.ExitCode}}' desafio

echo "TODO Etapa 4: sobrepor o entrypoint pra investigar dentro da imagem"
# docker run --rm -it --entrypoint sh mod18-desafio
# (lá dentro: which python ; ls -la ; cat server.py)

echo "TODO Etapa 5: depois de consertar BUG 2 e rebuildar, achar o BUG 3"
# docker rm -f desafio
# (consertar CMD no Dockerfile, depois:)
# docker build -t mod18-desafio .
# docker run -d --name desafio mod18-desafio
# docker logs desafio   → KeyError APP_PORT

echo "TODO Etapa 6: rodar passando a env var pra confirmar o diagnóstico"
# docker rm -f desafio
# docker run -d --name desafio -e APP_PORT=8000 -p 8000:8000 mod18-desafio
# docker logs desafio
# docker exec desafio wget -qO- localhost:8000

# Limpeza:
# docker rm -f desafio
# docker rmi mod18-desafio

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente o bloco SOLUTION pra rodar)
# ============================

: <<'SOLUTION'
# --- Etapa 1: build ---
docker build -t mod18-desafio .

# --- Etapa 2: rodar e ver morrer ---
docker rm -f desafio 2>/dev/null
docker run -d --name desafio mod18-desafio
sleep 1
docker ps -a --filter name=desafio
# Status: Exited (127)

# --- Etapa 3: diagnóstico do BUG 2 ---
echo "--- LOGS ---"
docker logs desafio
# exec: "pythn": executable file not found

echo "--- EXIT CODE ---"
docker inspect --format '{{.State.ExitCode}}' desafio
# 127 → command not found

echo "--- CMD APLICADO ---"
docker inspect --format '{{.Config.Cmd}}' desafio
# [pythn server.py] → typo confirmado

# --- Etapa 4: entrar na imagem pra confirmar que 'python' existe ---
docker run --rm --entrypoint sh mod18-desafio -c 'which python && python --version'
# /usr/local/bin/python e Python 3.12.x → o binário existe, é só typo no CMD

# --- Etapa 5: consertar BUG 2 no Dockerfile (pythn → python), rebuildar ---
# (faça a edição no Dockerfile; aqui simulo com sed pra demo automatizada)
sed -i.bak 's/"pythn"/"python"/' Dockerfile
docker build -t mod18-desafio .

docker rm -f desafio
docker run -d --name desafio mod18-desafio
sleep 1
docker logs desafio
# KeyError: 'APP_PORT' → BUG 3 revelado

# --- Etapa 6: validar BUG 3 passando env var ---
docker rm -f desafio
docker run -d --name desafio -e APP_PORT=8000 -p 8000:8000 mod18-desafio
sleep 1
docker logs desafio
# "servindo na porta 8000"
docker exec desafio wget -qO- localhost:8000
# ok

# --- BUG 1: EXPOSE 3000 mas app escutando em 8000 ---
# Sintoma silencioso. Confirma com:
docker inspect --format '{{json .Config.ExposedPorts}}' desafio
# {"3000/tcp":{}}  ← inconsistente com a porta real
# Fix: trocar EXPOSE 3000 → EXPOSE 8000 no Dockerfile.

# --- Fix definitivo (resumo das 3 mudanças no Dockerfile) ---
# 1. EXPOSE 8000              (era 3000)
# 2. CMD ["python","server.py"]  (era "pythn")
# 3. ENV APP_PORT=8000        (linha nova, antes do CMD)
#    OU sempre passar -e APP_PORT=... no run

# Limpeza
docker rm -f desafio
docker rmi mod18-desafio
mv Dockerfile.bak Dockerfile  # restaura o original com bugs pra próxima vez
SOLUTION
