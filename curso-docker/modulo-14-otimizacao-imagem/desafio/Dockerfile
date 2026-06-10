# 🎯 DESAFIO DO MÓDULO 14 — Reduzir Imagem em 80%
#
# Cenário: você herdou um microserviço Python (FastAPI) que faz UMA coisa:
# expõe GET /health respondendo {"status":"ok"}. A imagem atual tem ~1.1GB.
# Seu chefe pediu pra reduzir pra menos de 200MB sem quebrar nada.
#
# O Dockerfile INFLADO original (referência — não use assim!):
#
#   FROM python:3.12                          # ~1GB já de cara
#   WORKDIR /app
#   RUN apt-get update
#   RUN apt-get install -y curl git vim wget build-essential
#   RUN apt-get install -y postgresql-client  # nem usamos postgres
#   COPY . .
#   RUN pip install -r requirements.txt       # instala tudo, sem cache control
#   RUN pip install pytest black mypy         # ferramentas de dev em prod (!)
#   EXPOSE 8000
#   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
#
# Problemas a corrigir:
# [ ] Base 'python:3.12' é gigante — troque por alpine ou slim
# [ ] apt install com pacotes inúteis (curl, git, vim, wget, postgres-client)
# [ ] RUN separados sem cleanup → cache do apt mora na imagem
# [ ] COPY . . antes de pip install → cache morre toda hora
# [ ] Ferramentas de dev (pytest, black, mypy) em produção
# [ ] Sem .dockerignore (veja o arquivo ao lado)
# [ ] Roda como root (bônus — usuário não-root)
#
# Conteúdo da app (mínimo pro desafio fazer sentido):
#
#   main.py:
#     from fastapi import FastAPI
#     app = FastAPI()
#     @app.get("/health")
#     def health(): return {"status": "ok"}
#
#   requirements.txt:
#     fastapi==0.115.0
#     uvicorn==0.32.0
#
# Meta: imagem final < 200MB (idealmente < 100MB).
# Verifique com: docker images | grep desafio14

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

# TODO 1: escolha uma base pequena
# FROM ...

# TODO 2: WORKDIR

# TODO 3: copie SÓ requirements.txt primeiro (pro cache funcionar)

# TODO 4: instale deps SEM cache do pip e SEM dev tools
#   dica: pip install --no-cache-dir -r requirements.txt

# TODO 5: copie o código

# TODO 6 (bônus): rode como usuário não-root

# TODO 7: EXPOSE e CMD


# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra usar)
# ============================
#
# FROM python:3.12-alpine
#
# WORKDIR /app
#
# # Deps primeiro pra cache aproveitar
# COPY requirements.txt ./
# RUN pip install --no-cache-dir -r requirements.txt
#
# # Código depois
# COPY main.py ./
#
# # Usuário não-root (cria um user simples)
# RUN adduser -D appuser
# USER appuser
#
# EXPOSE 8000
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
#
# # Resultado esperado: ~80-100MB (vs 1.1GB original — ~92% de redução).
#
# # Variante ainda menor com multi-stage + distroless:
# #
# # FROM python:3.12-slim AS build
# # WORKDIR /app
# # COPY requirements.txt ./
# # RUN pip install --no-cache-dir --target=/install -r requirements.txt
# #
# # FROM gcr.io/distroless/python3-debian12
# # WORKDIR /app
# # COPY --from=build /install /usr/lib/python3.12/site-packages
# # COPY main.py ./
# # EXPOSE 8000
# # CMD ["-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
