#!/usr/bin/env bash
# Módulo 18 — Debugging
# Prática: 10 comandos pra exercitar a toolbox num container quebrado de propósito.
#
# Rode linha a linha (recomendado) ou bash comandos.sh pra rodar tudo.
# Vamos subir um container com typo no CMD e diagnosticar com cada ferramenta.

set +e  # NÃO parar no erro — queremos ver o container quebrar de propósito

NOME=mod18-quebrado
NOME_OK=mod18-vivo

# limpeza preventiva (caso a prática tenha rodado antes)
docker rm -f "$NOME" "$NOME_OK" >/dev/null 2>&1

echo "=== Exercício 1: Rodar container com problema (typo no CMD) ==="
# 'sleeep' não existe → exit code 127 (command not found)
docker run --name "$NOME" alpine sleeep 30
echo "↑ deve ter morrido instantaneamente. Vamos investigar."

echo ""
echo "=== Exercício 2: Ver os logs (o que a app disse antes de morrer) ==="
docker logs "$NOME"
# 'sh: sleeep: not found' — primeira pista

echo ""
echo "=== Exercício 3: Inspect — exit code e mensagem de erro ==="
echo "Exit code:"
docker inspect --format '{{.State.ExitCode}}' "$NOME"
echo "State.Error (erro do runtime, se houver):"
docker inspect --format '{{.State.Error}}' "$NOME"
echo "Comando que foi executado:"
docker inspect --format '{{.Config.Cmd}}' "$NOME"
# Exit 127 confirma: comando não existe. Diagnóstico fechado.

echo ""
echo "=== Exercício 4: Subir um container VIVO pra exercitar o resto ==="
# nginx fica rodando — perfeito pra exec, stats, top, port, diff
docker run -d --name "$NOME_OK" -p 8088:80 nginx
sleep 2
docker ps --filter name="$NOME_OK"

echo ""
echo "=== Exercício 5: Exec — entrar dentro do container vivo ==="
# Roda um comando de dentro sem precisar abrir TTY (bom pra script)
docker exec "$NOME_OK" sh -c 'echo "Estou dentro! hostname=$(hostname), nginx em $(which nginx)"'
# Pra entrada interativa de verdade, use:
#   docker exec -it $NOME_OK sh

echo ""
echo "=== Exercício 6: Top — processos rodando dentro ==="
docker top "$NOME_OK"
# Deve mostrar o master do nginx + workers

echo ""
echo "=== Exercício 7: Stats — recursos em tempo real (snapshot) ==="
docker stats --no-stream "$NOME_OK"
# --no-stream = uma medição só, em vez de ficar atualizando

echo ""
echo "=== Exercício 8: Port — quais portas estão mapeadas ==="
docker port "$NOME_OK"
# Deve mostrar 80/tcp -> 0.0.0.0:8088

echo ""
echo "=== Exercício 9: Diff — criar arquivo dentro e ver mudança no FS ==="
docker exec "$NOME_OK" sh -c 'echo "investigando" > /tmp/evidencia.txt'
docker diff "$NOME_OK"
# A = added, C = changed, D = deleted
# Deve aparecer A /tmp/evidencia.txt

echo ""
echo "=== Exercício 10a: cp — tirar o arquivo de dentro pro host ==="
docker cp "$NOME_OK":/tmp/evidencia.txt ./evidencia.txt
ls -la ./evidencia.txt
cat ./evidencia.txt
rm -f ./evidencia.txt

echo ""
echo "=== Exercício 10b: events — o que aconteceu na última hora ==="
# stream de eventos do daemon: create, start, die, kill, etc.
docker events --since 1h --until 0s --filter container="$NOME" --filter container="$NOME_OK" 2>/dev/null | head -10
# o '--until 0s' faz ele parar agora (senão fica streaming)

echo ""
echo "=== Limpeza ==="
docker rm -f "$NOME" "$NOME_OK" >/dev/null
echo "Containers de prática removidos."

echo ""
echo "=== Pronto! ==="
echo "Você usou: logs, inspect, exec, top, stats, port, diff, cp, events."
echo "Próximo: desafio/Dockerfile — 3 bugs pra você caçar."
