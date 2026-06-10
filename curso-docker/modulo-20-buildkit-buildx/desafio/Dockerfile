# syntax=docker/dockerfile:1
# =====================================================
# 🎯 DESAFIO MÓDULO 20 — Build Go multi-platform com cache + secret
#
# Objetivo: construir uma imagem Go que:
#   1) Use CACHE MOUNT pro go mod cache e build cache (Go é exigente com cache!)
#   2) Use SECRET MOUNT pra um "token de build" simulado
#   3) Seja construída pra linux/amd64 E linux/arm64
#   4) Seja empurrada pra um registry LOCAL (rodando em localhost:5000)
#
# A app é trivial: imprime "Hello" + arch detectada.
# Foco é no Dockerfile + buildx, não no Go em si.
# =====================================================

# ============= TODO 1 =============
# Use uma imagem base do Go (multi-stage: builder + runtime).
# Dica: golang:1.23-alpine pro builder.

# FROM ____ AS builder

# ============= TODO 2 =============
# Configure WORKDIR e copie go.mod/go.sum primeiro (cache de camada).

# WORKDIR /app
# COPY go.mod go.sum ./

# ============= TODO 3 =============
# RUN com DOIS cache mounts:
#   - /go/pkg/mod    (cache de módulos baixados)
#   - /root/.cache/go-build (cache de compilação)
# E pra rodar `go mod download`.

# RUN --mount=type=cache,target=____ \
#     --mount=type=cache,target=____ \
#     go mod download

# ============= TODO 4 =============
# Copie o resto do código e compile com os MESMOS cache mounts.
# Bônus: use CGO_ENABLED=0 + -ldflags="-s -w" pra binário menor.
# Use os ARGs TARGETOS e TARGETARCH que o buildx injeta automaticamente
# em build multi-platform.

# COPY . .
# ARG TARGETOS
# ARG TARGETARCH
# RUN --mount=type=cache,target=____ \
#     --mount=type=cache,target=____ \
#     --mount=type=secret,id=build_token \
#     CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
#     go build -ldflags="-s -w" -o /out/app .

# ============= TODO 5 =============
# Stage final MAGRO (scratch ou alpine), copiando só o binário.

# FROM ____
# COPY --from=builder /out/app /app
# ENTRYPOINT ["/app"]
