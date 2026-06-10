#!/bin/bash
# Gera par RSA pra assinar/verificar JWT.
# Rode na raiz do projeto Quarkus. Os .pem saem em src/main/resources/.

set -e

DEST="src/main/resources"
mkdir -p "$DEST"

# Chave privada (2048 bits) — assina os tokens. NUNCA committar.
openssl genrsa -out "$DEST/privateKey.pem" 2048

# Chave pública — verifica os tokens. Pode versionar.
openssl rsa -in "$DEST/privateKey.pem" -pubout -out "$DEST/publicKey.pem"

echo "OK: $DEST/privateKey.pem e $DEST/publicKey.pem gerados."
echo "Lembra de adicionar privateKey.pem no .gitignore!"
