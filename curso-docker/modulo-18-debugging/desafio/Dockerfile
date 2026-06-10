# 🎯 DESAFIO DO MÓDULO 18 — Dockerfile com 3 bugs
#
# Este Dockerfile NÃO funciona. Tem 3 bugs plantados:
#   BUG 1 — EXPOSE/porta errada (app escuta em outra)
#   BUG 2 — CMD com typo (comando não existe)
#   BUG 3 — env var obrigatória faltando (app crasha sem ela)
#
# Sua missão: rodar, diagnosticar usando a toolbox (logs, inspect, exec...)
# e propor o fix. As instruções de diagnóstico estão em desafio/comandos.sh.
#
# NÃO mude nada aqui em cima — leia os comentários # FIX no fim do arquivo
# depois que você diagnosticou sozinho.

FROM python:3.12-alpine

WORKDIR /app

# App fake: um servidor HTTP em Python que escuta na porta definida pela
# env var APP_PORT (sem default — propositalmente).
RUN cat > server.py <<'PY'
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

# Bug 3 fica aqui: se APP_PORT não vier, KeyError e crash.
PORT = int(os.environ["APP_PORT"])

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok\n")

print(f"servindo na porta {PORT}", flush=True)
HTTPServer(("0.0.0.0", PORT), H).serve_forever()
PY

# BUG 1: app vai escutar na porta vinda de APP_PORT (8000 no nosso caso),
# mas o EXPOSE tá apontando pra outra. Isso não impede o container subir,
# mas confunde a documentação e o -P automático.
EXPOSE 3000

# BUG 2: typo — 'pythn' em vez de 'python'. Exit code 127 na cara.
CMD ["pythn", "server.py"]


# ============================================================================
# 🩺 ROTEIRO DE DIAGNÓSTICO (siga em desafio/comandos.sh)
# ============================================================================
#
# 1. docker build -t mod18-desafio .
# 2. docker run -d --name desafio -p 8000:8000 mod18-desafio
# 3. docker ps -a       → container já morreu, Exited (127)
# 4. docker logs desafio → "exec: 'pythn': executable file not found" → BUG 2
# 5. docker inspect --format '{{.State.ExitCode}}' desafio → 127 confirma
# 6. Conserta CMD pra "python", rebuilda, sobe de novo
# 7. Container morre de novo: docker logs → KeyError: 'APP_PORT' → BUG 3
# 8. docker run ... -e APP_PORT=8000 ...  (passa a env var)
# 9. Container sobe! Mas curl localhost:8000 funciona, enquanto EXPOSE
#    diz 3000 — BUG 1, corrige pra EXPOSE 8000 pra coerência.
#
# ============================================================================
# ✅ SOLUÇÃO DE REFERÊNCIA — descomente pra ver o Dockerfile corrigido
# ============================================================================
#
# FROM python:3.12-alpine
# WORKDIR /app
# RUN cat > server.py <<'PY'
# ... (mesmo conteúdo, com default seguro:)
# PORT = int(os.environ.get("APP_PORT", "8000"))
# ... (resto igual)
# PY
#
# # FIX BUG 1: porta coerente com a que a app escuta
# EXPOSE 8000
#
# # FIX BUG 2: 'python' sem typo
# # FIX BUG 3: env var com default OU passar -e APP_PORT=8000 no run
# ENV APP_PORT=8000
# CMD ["python", "server.py"]
