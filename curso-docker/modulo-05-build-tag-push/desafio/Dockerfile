# 🎯 DESAFIO MÓDULO 05 — sua imagem publicada
#
# Objetivo: empacotar uma app simples (página HTML + um arquivo .txt
# com a versão) e publicar no seu Docker Hub com 3 tags.
#
# Você pode customizar a página como quiser — adicione seu nome,
# data, qualquer coisa. O importante é o fluxo build → tag → push.

FROM nginx:alpine

LABEL org.opencontainers.image.title="modulo-05-desafio" \
      org.opencontainers.image.authors="seu-nome-aqui"

# Copia tudo da pasta atual pra dentro do nginx (HTML + arquivos extras).
# Em projetos reais, copie só o necessário — aqui simplificamos.
COPY index.html /usr/share/nginx/html/index.html
COPY VERSION.txt /usr/share/nginx/html/VERSION.txt

EXPOSE 80
