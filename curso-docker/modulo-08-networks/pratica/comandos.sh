#!/usr/bin/env bash
# Módulo 08 — Networks
# Prática: criar redes, fazer containers conversarem pelo nome, inspecionar.
#
# Rode linha a linha (ou bash comandos.sh pra rodar tudo).
# Cada exercício imprime o que está acontecendo.

set -e  # para se algum comando falhar

echo "=== Exercício 1: Listar redes que já existem ==="
# Vão aparecer: bridge (default), host, none — vem de fábrica.
docker network ls

echo ""
echo "=== Exercício 2: Criar uma rede user-defined (bridge custom) ==="
# Driver bridge é o default — não precisa especificar, mas vamos ser explícitos.
docker network create --driver bridge loja-net
docker network ls | grep loja-net

echo ""
echo "=== Exercício 3: Subir um Postgres DENTRO da loja-net ==="
# Repare: SEM -p. Ninguém de fora vai falar com esse banco.
docker run -d --name loja-db \
  --network loja-net \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=loja \
  postgres:16

echo "Esperando o Postgres subir..."
sleep 5

echo ""
echo "=== Exercício 4: Subir um Alpine na MESMA rede e fazer ping no Postgres pelo NOME ==="
# Mágica do DNS interno: 'loja-db' é resolvido automaticamente.
docker run --rm --network loja-net alpine sh -c \
  "apk add --no-cache curl bind-tools >/dev/null && \
   echo '--- ping ---' && \
   ping -c 2 loja-db && \
   echo '--- nslookup ---' && \
   nslookup loja-db"

echo ""
echo "=== Exercício 5: Conectar de verdade no Postgres pelo nome ==="
# Usa o cliente psql que vem na própria imagem postgres:16.
docker run --rm --network loja-net postgres:16 \
  psql -h loja-db -U postgres -d loja -c "SELECT version();" \
  PGPASSWORD=secret || true
# (Se der erro de senha, é porque PGPASSWORD precisa ser env — versão correta abaixo)
docker run --rm --network loja-net \
  -e PGPASSWORD=secret \
  postgres:16 \
  psql -h loja-db -U postgres -d loja -c "SELECT version();"

echo ""
echo "=== Exercício 6: Inspecionar a rede e ver os containers conectados ==="
# Repare no campo 'Containers' — vai aparecer o loja-db com IP interno.
docker network inspect loja-net | head -40

echo ""
echo "=== Exercício 7: Conectar um container EXISTENTE a uma segunda rede ==="
# Cria outra rede e pluga o loja-db nela também — multi-network.
docker network create extra-net
docker network connect extra-net loja-db
echo "loja-db agora está em DUAS redes:"
docker inspect loja-db --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
echo ""

echo ""
echo "=== Exercício 8: Desconectar da rede extra ==="
docker network disconnect extra-net loja-db
echo "Agora só na loja-net:"
docker inspect loja-db --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
echo ""

echo ""
echo "=== Exercício 9: Demonstrando 'host network' (sem isolamento) ==="
# No Linux funciona pleno. No Docker Desktop (Mac/Windows) é mais limitado,
# mas o comando roda. Aqui só rodamos um alpine que mostra as interfaces do host.
docker run --rm --network host alpine sh -c "ip addr | head -20 || ifconfig | head -20"
# Repare: as interfaces vistas são as do HOST, não as virtuais do Docker.

echo ""
echo "=== Exercício 10: Limpeza ==="
docker stop loja-db
docker rm loja-db
docker network rm loja-net extra-net
docker network prune -f

echo ""
echo "=== Pronto! ==="
echo "Redes restantes:"
docker network ls
