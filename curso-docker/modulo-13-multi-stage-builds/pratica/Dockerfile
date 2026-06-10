# Módulo 13 — Prática: Imagem Go enxuta com multi-stage build
#
# Objetivo: sair de uma imagem "ingênua" de ~800MB pra uma de ~12MB.
#
# Estratégia:
#   Stage 1 (builder) — usa golang:alpine pra compilar binário estático.
#   Stage 2 (final)   — usa scratch (imagem vazia) e só carrega o binário.

# ============================================================
# STAGE 1 — BUILDER (pesado, com toolchain Go)
# ============================================================
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copia primeiro só o go.mod pra aproveitar cache de dependências.
# (Detalhes em Módulo 06 — Camadas e Cache.)
COPY go.mod ./
# Se tivesse go.sum, copiaria também: COPY go.sum ./
# RUN go mod download   # baixaria deps; nosso projeto não tem nenhuma

# Agora o código.
COPY *.go ./

# Compila estático:
#   CGO_ENABLED=0  → sem libc, binário 100% Go (essencial pra scratch).
#   GOOS=linux     → garante target Linux (container roda Linux).
#   -ldflags="-s -w" → remove tabela de símbolos e DWARF (binário menor).
#   -o /servidor   → caminho do binário final.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /servidor

# ============================================================
# STAGE 2 — RUNTIME (imagem vazia, só o binário)
# ============================================================
FROM scratch

# Traz só o binário compilado do stage anterior.
COPY --from=builder /servidor /servidor

# Documenta a porta (não publica — quem publica é o `docker run -p`).
EXPOSE 8080

# Como scratch não tem shell, usar exec form (lista) é obrigatório.
ENTRYPOINT ["/servidor"]
