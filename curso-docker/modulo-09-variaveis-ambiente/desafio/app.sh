#!/bin/sh
# App de configuração — imprime a config carregada do ambiente.
# Simula o que um app de verdade faria ao subir (log das configs ativas).

echo "================================================"
echo "  🚀 Subindo app..."
echo "================================================"
echo "  LOG_LEVEL    = ${LOG_LEVEL:-MISSING}"
echo "  PORT         = ${PORT:-MISSING}"
echo "  DB_HOST      = ${DB_HOST:-MISSING}"
echo "  FEATURE_FLAG = ${FEATURE_FLAG:-MISSING}"
echo "================================================"

# Simula comportamento condicional baseado em env
if [ "$FEATURE_FLAG" = "true" ]; then
  echo "  ✨ Feature nova LIGADA"
else
  echo "  💤 Feature nova desligada"
fi

if [ "$LOG_LEVEL" = "debug" ]; then
  echo "  🔍 [DEBUG] Conectando em $DB_HOST..."
  echo "  🔍 [DEBUG] Escutando em :$PORT"
fi

echo ""
echo "App pronta. (Em um app real, aqui começaria o servidor HTTP.)"
