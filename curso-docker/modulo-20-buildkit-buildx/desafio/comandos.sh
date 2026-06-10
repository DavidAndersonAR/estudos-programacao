#!/usr/bin/env bash
# 🎯 DESAFIO MÓDULO 20 — Build Go multi-platform com cache + secret + push registry local
#
# Cenário: você quer publicar sua app Go em um registry interno, suportando
# servidores amd64 (clássicos) e arm64 (AWS Graviton, Mac M1, Raspberry Pi).
#
# Passos:
#  1. Sobe um registry LOCAL (Docker Registry v2) na porta 5000
#  2. Cria a app Go mínima
#  3. Completa o Dockerfile (ver TODOs no arquivo)
#  4. Builda multi-platform e dá push pro registry local
#  5. Inspeciona o manifest pra confirmar duas arquiteturas
#
# 💡 Dicas:
#   - O registry local não tem TLS — o builder buildx (driver docker-container)
#     PRECISA estar configurado pra aceitar registry inseguro, OU use host.docker.internal
#     dependendo do setup. Se der ruim, ver SOLUÇÃO mais embaixo.
#   - TARGETOS/TARGETARCH são automaticamente preenchidos pelo buildx em multi-platform.

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: sobe um registry local na porta 5000"
# docker run -d ...

echo "TODO: cria app-go/main.go e app-go/go.mod"
# mkdir -p app-go && cd app-go ...

echo "TODO: copia o Dockerfile preenchido pra app-go/"

echo "TODO: cria um builder buildx multi-platform (se ainda não tiver)"
# docker buildx create ...

echo "TODO: cria um token fake pra usar como secret"
# echo "token-do-desafio" > /tmp/...

echo "TODO: buildx build multi-platform empurrando pro registry local"
# docker buildx build --platform linux/amd64,linux/arm64 \
#   --secret id=build_token,src=... \
#   -t localhost:5000/go-app:1.0 \
#   --push .

echo "TODO: inspecionar o manifest e confirmar 2 plataformas"
# docker buildx imagetools inspect localhost:5000/go-app:1.0

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# === 1. Sobe registry local ===
docker run -d -p 5000:5000 --restart=always --name registry-local registry:2
# Confirma que tá no ar:
curl -s http://localhost:5000/v2/_catalog

# === 2. Cria a app Go mínima ===
mkdir -p app-go && cd app-go

cat > go.mod <<'EOF'
module desafio20

go 1.23
EOF

cat > main.go <<'EOF'
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("Hello do desafio 20! OS=%s ARCH=%s\n", runtime.GOOS, runtime.GOARCH)
}
EOF

# go.sum vazio (sem deps externas)
touch go.sum

# === 3. Dockerfile preenchido (cole isso em ./Dockerfile, sobrescrevendo o stub) ===
cat > Dockerfile <<'DOCKERFILE'
# syntax=docker/dockerfile:1

FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copia manifestos primeiro pra aproveitar cache de camada
COPY go.mod go.sum ./

# Cache mounts pra módulos (não rebaixa entre builds)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

COPY . .

# TARGETOS e TARGETARCH são injetados pelo buildx em multi-platform.
# Sem isso, você compilaria sempre pra arch do builder, não pra arch alvo.
ARG TARGETOS
ARG TARGETARCH

# Secret usado SÓ durante o build, NUNCA vai pra imagem.
# Aqui simulamos "ler token e usar em algo". Em real seria git clone privado,
# download de pacote de registry interno, etc.
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=secret,id=build_token \
    if [ -f /run/secrets/build_token ]; then \
      echo "Build autorizado (token len=$(wc -c < /run/secrets/build_token))"; \
    fi && \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o /out/app .

# Imagem final mínima (scratch = literalmente vazia, só o binário)
FROM scratch
COPY --from=builder /out/app /app
ENTRYPOINT ["/app"]
DOCKERFILE

# === 4. Builder buildx multi-platform ===
# Criamos o builder com a flag --driver-opt pra aceitar nosso registry
# inseguro (sem TLS) em localhost:5000. Sem isso o push dá erro.
docker buildx create \
  --name desafio20-builder \
  --driver docker-container \
  --driver-opt network=host \
  --use 2>/dev/null || docker buildx use desafio20-builder

docker buildx inspect --bootstrap | head -25

# === 5. Cria o secret ===
echo "token-super-secreto-do-desafio-20" > /tmp/desafio-token.txt

# === 6. Build multi-platform + push ===
# OBS: o registry tá em localhost:5000 do HOST. Como o builder roda em
# container, ele enxerga via 'host.docker.internal' ou via network=host
# (que setamos acima). Por isso usamos localhost:5000 mesmo.
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --secret id=build_token,src=/tmp/desafio-token.txt \
  -t localhost:5000/go-app:1.0 \
  --push \
  .

# === 7. Confirmar que tem AMBAS as plataformas ===
docker buildx imagetools inspect localhost:5000/go-app:1.0
# Você deve ver algo tipo:
#   Manifests:
#     Name:      localhost:5000/go-app:1.0@sha256:...
#     Platform:  linux/amd64
#     Name:      localhost:5000/go-app:1.0@sha256:...
#     Platform:  linux/arm64

# === 8. Rodar a imagem (vai pegar a arch do seu host) ===
docker run --rm localhost:5000/go-app:1.0
# Saída esperada: Hello do desafio 20! OS=linux ARCH=amd64 (ou arm64)

# === 9. Limpeza ===
# rm -f /tmp/desafio-token.txt
# docker stop registry-local && docker rm registry-local
# docker buildx rm desafio20-builder

# === Critérios de "passou no desafio" ===
# ✅ docker buildx imagetools inspect mostra DOIS Platform diferentes
# ✅ docker history da imagem não tem o token
# ✅ Build 2 (com cache quente) é visivelmente mais rápido que build 1
# ✅ Imagem final é pequena (scratch + binário Go com -ldflags="-s -w" ≈ alguns MB)
SOLUTION
