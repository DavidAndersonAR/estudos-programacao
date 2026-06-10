# 🎯 DESAFIO DO MÓDULO 06 — Refatorar Dockerfile pra MAXIMIZAR cache
#
# Cenário:
# Você herdou um Dockerfile escrito por alguém que não conhecia cache.
# O build leva 3 minutos toda vez que alguém edita uma linha de Python.
# Sua missão: reordenar e otimizar pra build incremental ficar em segundos.
#
# Pista: pense "o que muda MENOS fica em CIMA, o que muda MAIS fica EMBAIXO".
#
# Contexto do app (fictício):
# - Python 3.11
# - Precisa de git e curl (deps de sistema)
# - Tem requirements.txt com 20 libs
# - Código fica em ./src
# - Tem testes em ./tests (NÃO precisa pra rodar em produção)
# - Tem um arquivo VERSION com versão atual (muda a cada release)

# ============================
# ❌ DOCKERFILE ORIGINAL (RUIM)
# ============================
# Olhe e identifique TODOS os problemas antes de reescrever.
#
# FROM python:3.11-slim
# COPY . /app
# WORKDIR /app
# RUN apt-get update
# RUN apt-get install -y git
# RUN apt-get install -y curl
# RUN pip install -r requirements.txt
# RUN pip install pytest
# COPY VERSION /app/VERSION
# CMD ["python", "src/main.py"]
#
# Problemas:
# 1. COPY . /app antes de instalar deps → toda mudança de código refaz pip install
# 2. apt-get update e install em RUNs separados → mais camadas + cache pode "envelhecer"
# 3. Não limpa /var/lib/apt/lists/* → imagem inchada
# 4. pip install pytest em produção → instala teste em imagem final (desnecessário)
# 5. COPY VERSION depois de COPY . . → redundante (VERSION já veio no COPY .)
# 6. Sem .dockerignore → ./tests, .git, __pycache__ entram no contexto

# ============================
# ✏️ SUA SOLUÇÃO — preencha os TODOs
# ============================

# TODO 1: escolha a imagem base (sugestão: python:3.11-slim — pequena, oficial).
# FROM ...

# TODO 2: defina o WORKDIR. Vem cedo porque quase nunca muda.
# WORKDIR ...

# TODO 3: instale deps de sistema (git, curl) em UM ÚNICO RUN.
#   - Junte apt-get update + install + limpeza com && pra ser uma camada só.
#   - Use --no-install-recommends pra economizar.
#   - Limpe /var/lib/apt/lists/* no fim.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends ... && \
#     rm -rf /var/lib/apt/lists/*

# TODO 4: copie SÓ o requirements.txt (não o resto ainda).
# COPY requirements.txt ...

# TODO 5: instale as deps Python. Esta camada deve ficar CACHEADA
# enquanto requirements.txt não mudar.
# RUN pip install --no-cache-dir -r requirements.txt

# TODO 6: agora sim copie o código-fonte. SÓ o que precisa em runtime.
# COPY src/ ./src/
# COPY VERSION ./

# TODO 7: defina o comando de execução.
# CMD ["python", "src/main.py"]


# ============================
# ✅ SOLUÇÃO DE REFERÊNCIA
# ============================
# Descomente o bloco abaixo pra ver a versão final comentada.

# # 1. Base mínima e oficial. Pin de versão (3.11-slim) deixa o build reprodutível.
# FROM python:3.11-slim
#
# # 2. WORKDIR primeiro — instrução leve, raramente muda.
# WORKDIR /app
#
# # 3. Deps de sistema em UM RUN só (uma camada, cache estável, sem lixo).
# #    --no-install-recommends evita pacotes extras inúteis.
# #    rm -rf /var/lib/apt/lists/* deixa a imagem menor.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#         git \
#         curl && \
#     rm -rf /var/lib/apt/lists/*
#
# # 4. Copia SÓ o manifesto de deps Python.
# #    Mudança em código NÃO invalida esta camada — esse é o segredo.
# COPY requirements.txt ./
#
# # 5. Instala deps. --no-cache-dir evita salvar cache do pip dentro da imagem
# #    (a gente já tem o cache de CAMADA do Docker, não precisa do cache do pip).
# RUN pip install --no-cache-dir -r requirements.txt
#
# # 6. Copia código-fonte por último (é o que mais muda).
# #    Use paths específicos em vez de COPY . . — não traz tests/, .git/, etc.
# COPY src/ ./src/
# COPY VERSION ./
#
# # 7. Comando final.
# CMD ["python", "src/main.py"]
#
# # ➡ Bônus: crie um .dockerignore com:
# #     .git
# #     tests/
# #     __pycache__
# #     *.pyc
# #     .venv
# #   Isso reduz o contexto de build E mantém cache mais estável.
#
# # ➡ Resultado esperado:
# # - Build inicial: ~mesmo tempo (precisa instalar tudo de qualquer jeito).
# # - Rebuild após editar src/main.py: SEGUNDOS, não minutos.
# #   Porque deps de sistema + pip install ficam cacheados; só o COPY src/ refaz.
