#!/usr/bin/env bash
# Módulo 03 — Imagens e Registry
# Prática: explorar imagens, layers, digests, inspect e limpeza
#
# Rode linha a linha (ou bash comandos.sh pra rodar tudo).
# Alguns pulls demoram — paciência na primeira execução.

set -e  # para se algum comando falhar

echo "=== Exercício 1: Pull com tag específica ==="
# Sempre prefira tag fixa em vez de :latest
docker pull nginx:1.27-alpine
docker pull node:lts
docker pull node:lts-alpine

echo ""
echo "=== Exercício 2: Pull pelo digest (imutável) ==="
# Primeiro descobre o digest da imagem que acabamos de baixar
DIGEST=$(docker inspect --format '{{index .RepoDigests 0}}' nginx:1.27-alpine)
echo "Digest do nginx:1.27-alpine -> $DIGEST"
# Agora puxa pelo digest (vai dizer "Image is up to date" porque já temos)
docker pull "$DIGEST"

echo ""
echo "=== Exercício 3: Listar imagens com formato customizado ==="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"

echo ""
echo "=== Exercício 4: Comparar tamanhos node:lts vs node:lts-alpine ==="
echo "node:lts ->"
docker images node:lts --format "{{.Size}}"
echo "node:lts-alpine ->"
docker images node:lts-alpine --format "{{.Size}}"
# Diferença costuma ser ~10x. Alpine ganha quando o build aceita musl libc.

echo ""
echo "=== Exercício 5: Filtrar imagens (só tags alpine) ==="
docker images --filter "reference=*:*alpine*"

echo ""
echo "=== Exercício 6: Inspecionar metadados ==="
echo "-- Portas expostas pelo nginx:"
docker inspect --format '{{.Config.ExposedPorts}}' nginx:1.27-alpine
echo "-- CMD padrão do node:lts-alpine:"
docker inspect --format '{{.Config.Cmd}}' node:lts-alpine
echo "-- Arquitetura:"
docker inspect --format '{{.Architecture}} / {{.Os}}' nginx:1.27-alpine
echo "-- SHAs das layers (cada linha = uma camada read-only):"
docker inspect --format '{{range .RootFS.Layers}}{{println .}}{{end}}' nginx:1.27-alpine

echo ""
echo "=== Exercício 7: Histórico das camadas ==="
# Mostra o comando que criou cada layer e quanto cada uma pesa
docker history nginx:1.27-alpine

echo ""
echo "=== Exercício 8: rmi (remover imagem) ==="
docker pull hello-world
docker rmi hello-world
echo "hello-world removido com sucesso."

echo ""
echo "=== Exercício 9: Tentar remover imagem EM USO (vai dar erro) ==="
# Cria um container parado usando nginx — daí o rmi vai falhar
docker create --name temp-nginx nginx:1.27-alpine >/dev/null
echo "Tentando 'docker rmi nginx:1.27-alpine' (deve falhar)..."
# || true pra não interromper o script — o erro é esperado e didático
docker rmi nginx:1.27-alpine || echo "👆 Erro esperado: imagem em uso por container 'temp-nginx'."
# Limpa o container pra liberar a imagem
docker rm temp-nginx >/dev/null
echo "Container removido. Agora o rmi funcionaria normalmente."

echo ""
echo "=== Exercício 10: Limpeza com prune ==="
# Remove só as 'dangling' (sem tag, órfãs de builds antigos)
docker image prune -f
# Se quiser remover TUDO que não está em uso: docker image prune -a -f
# (cuidado — vai apagar imagens que talvez você queira)

echo ""
echo "=== Pronto! ==="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
