# Módulo 05 — Prática: imagem mínima com nginx servindo um HTML
#
# FROM = imagem base. Aqui usamos nginx:alpine (nginx em cima do Alpine Linux,
# minúsculo — uns 50MB). Em produção, fixe a versão (ex: nginx:1.27-alpine)
# ou até o digest (ver AULA.md).
FROM nginx:alpine

# Metadados úteis (opcional, mas boa prática)
LABEL org.opencontainers.image.title="modulo-05-pratica" \
      org.opencontainers.image.description="Hello from my image - curso docker" \
      org.opencontainers.image.source="curso-docker/modulo-05-build-tag-push"

# Substitui o index.html default do nginx pelo nosso.
# /usr/share/nginx/html/ é a pasta que o nginx serve por padrão.
COPY index.html /usr/share/nginx/html/index.html

# Documenta a porta que a app escuta (nginx default = 80).
# É só documentação — quem mapeia porta de verdade é o `docker run -p`.
EXPOSE 80

# A imagem nginx:alpine já tem CMD pra iniciar o nginx em foreground,
# então não precisamos definir nada aqui.
