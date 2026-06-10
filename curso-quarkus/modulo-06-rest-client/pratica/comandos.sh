#!/usr/bin/env bash
# Passo a passo do módulo 06 — REST Client com ViaCEP

# 1. Cria o projeto (se ainda não tiver)
quarkus create app com.exemplo:cep-app --extension=rest-jackson
cd cep-app

# 2. Adiciona a extensão de REST Client
quarkus ext add rest-client-jackson

# 3. Copia os arquivos da pasta pratica/ para src/main/java/com/exemplo/cep/
#    e application.properties para src/main/resources/

# 4. Sobe em modo dev
quarkus dev

# 5. Testa em outro terminal
curl -s http://localhost:8080/cep/01001000 | jq
# {
#   "cep": "01001-000",
#   "logradouro": "Praça da Sé",
#   "bairro": "Sé",
#   "localidade": "São Paulo",
#   "uf": "SP",
#   ...
# }

# CEP com formatação — o service limpa
curl -s http://localhost:8080/cep/01001-000 | jq

# CEP inválido (menos de 8 dígitos) → 400
curl -i http://localhost:8080/cep/123

# CEP que não existe → ViaCEP devolve {"erro": true} com 200,
# o resource transforma em 404
curl -i http://localhost:8080/cep/99999999

# 6. Abre o Dev UI e procura "REST Client"
# http://localhost:8080/q/dev → lista todos os clients e configs

# 7. Vê o log de request/response no console do quarkus dev
