#!/bin/sh
# Script de demonstração — lê envs e imprime.
# Note que :- "valor" é fallback do shell se a var estiver não definida ou vazia.

echo "============================================"
echo "  App versão: ${APP_VERSION:-?}"
echo "============================================"
echo "  $SAUDACAO, $NOME!"
echo "============================================"
echo ""
echo "Todas as envs do container (debug):"
env | sort
