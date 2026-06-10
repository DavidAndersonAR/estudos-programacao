#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 01 — Seu próprio endpoint
#
# Objetivo:
# Criar um projeto Quarkus do zero e adicionar 2 endpoints novos.
#
# 1. Crie um projeto chamado "saudacao-api" (groupId com.estudo)
# 2. Rode em dev mode
# 3. Crie um SaudacaoResource em /saudacao com:
#    - GET /saudacao → "Olá mundo!"
#    - GET /saudacao/{nome} → "Olá, {nome}!"
# 4. Teste cada um com curl
# 5. (Bônus) Adicione a extensão openapi e abra /q/swagger-ui
#
# 💡 Dicas:
#   - @PathParam("nome") String nome  → pega o {nome} da URL
#   - Não esquece a anotação @GET acima do método
#   - Cada método precisa de @Path próprio se tiver subpath

set -e

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO 1: criar projeto saudacao-api"
# quarkus create app ...

echo "TODO 2: rodar dev mode (manualmente em outro terminal)"

echo "TODO 3: criar SaudacaoResource.java"
# Veja exemplo abaixo, ou no commented SOLUTION

echo "TODO 4: testar"
# curl http://localhost:8080/saudacao
# curl http://localhost:8080/saudacao/David

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# 1. Cria projeto
quarkus create app com.estudo:saudacao-api \
  --extension=rest-jackson \
  --java=21
cd saudacao-api

# 2. Cria o arquivo SaudacaoResource.java
mkdir -p src/main/java/com/estudo
cat > src/main/java/com/estudo/SaudacaoResource.java <<'JAVA'
package com.estudo;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/saudacao")
public class SaudacaoResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String ola() {
        return "Olá mundo!";
    }

    @GET
    @Path("/{nome}")
    @Produces(MediaType.TEXT_PLAIN)
    public String olaNome(@PathParam("nome") String nome) {
        return "Olá, " + nome + "!";
    }
}
JAVA

# 3. Rodar (em outro terminal):
#    quarkus dev

# 4. Testar:
#    curl http://localhost:8080/saudacao        → Olá mundo!
#    curl http://localhost:8080/saudacao/David  → Olá, David!

# 5. (BÔNUS) Adicionar OpenAPI:
quarkus ext add openapi
# Reinicia automaticamente (live reload).
# Abre http://localhost:8080/q/swagger-ui — vai ver os 2 endpoints documentados.
SOLUTION
