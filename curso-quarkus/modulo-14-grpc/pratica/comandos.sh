#!/usr/bin/env bash
# Roteiro pra rodar e testar o servico gRPC de Saudacao.
# Pre-requisitos:
#   - Quarkus 3.x + JDK 17+
#   - grpcurl instalado: https://github.com/fullstorydev/grpcurl
#       (Windows: scoop install grpcurl  |  Mac: brew install grpcurl)

# ============================================================
# 1) Criar o projeto e adicionar a extensao
# ============================================================
quarkus create app com.exemplo:saudacao-grpc
cd saudacao-grpc
quarkus ext add grpc

# ============================================================
# 2) Colocar os arquivos no lugar
# ============================================================
# saudacao.proto              -> src/main/proto/saudacao.proto
# SaudacaoGrpcService.java    -> src/main/java/com/exemplo/saudacao/
# SaudacaoResource.java       -> src/main/java/com/exemplo/saudacao/
# application.properties      -> src/main/resources/application.properties

mkdir -p src/main/proto
mkdir -p src/main/java/com/exemplo/saudacao
# (mova os arquivos da pratica/ pros caminhos acima)

# ============================================================
# 3) Subir em modo dev (compila o .proto automaticamente)
# ============================================================
quarkus dev
# Deve aparecer no log: "gRPC Server started on 0.0.0.0:9000"

# ============================================================
# 4) Testar via REST (mais rapido pro dev-loop)
# ============================================================
curl http://localhost:8080/saudacao/Davi
# -> Olá, Davi!

# Stream via SSE
curl -N http://localhost:8080/saudacao/stream/Davi

# ============================================================
# 5) Testar via grpcurl (gRPC direto)
# ============================================================
# Lista os servicos expostos (reflection vem ligado em dev)
grpcurl -plaintext localhost:9000 list

# Lista os metodos de Saudacao
grpcurl -plaintext localhost:9000 list saudacao.Saudacao

# Chamada unary
grpcurl -plaintext -d '{"nome":"Davi"}' localhost:9000 saudacao.Saudacao/DizerOla

# Chamada server streaming (vai aparecendo a cada item)
grpcurl -plaintext -d '{"nome":"Davi"}' localhost:9000 saudacao.Saudacao/DizerOlaStream

# ============================================================
# 6) Checar codigo gerado
# ============================================================
ls target/generated-sources/grpc/com/exemplo/saudacao/
# Voce vai ver: OlaRequest.java, OlaReply.java, Saudacao.java (interface Mutiny),
# SaudacaoGrpc.java (stub classico), entre outros.
