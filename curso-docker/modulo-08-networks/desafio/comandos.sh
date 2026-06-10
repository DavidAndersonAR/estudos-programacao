#!/usr/bin/env bash
# 🎯 DESAFIO DO MÓDULO 08 — Stack de 3 containers conversando entre si
#
# Objetivo:
# Subir uma "ministack" de 3 containers numa rede custom e validar a comunicação:
#
#   [seu navegador] ──► host:8080 ──► nginx ──► adminer ──► postgres
#                                     (só ele       (proxy        (banco invisível
#                                      tem -p)       reverso)      pro host)
#
# Regras:
# - Crie UMA rede user-defined chamada 'desafio-net'.
# - Containers:
#     1) postgres:16          name=desafio-db         (SEM -p)
#     2) adminer              name=desafio-adminer    (SEM -p)
#     3) nginx:alpine         name=desafio-nginx      (com -p 8080:80)
# - Do adminer (no navegador via nginx), conectar no postgres usando o HOSTNAME 'desafio-db'.
# - O nginx faz proxy reverso pra http://desafio-adminer:8080.
# - Do seu PC, SÓ se acessa http://localhost:8080 — postgres e adminer ficam invisíveis.
#
# 💡 Dicas:
#   - Adminer escuta na porta 8080 internamente.
#   - Postgres na 5432.
#   - Pro nginx fazer proxy reverso, ele precisa de um nginx.conf customizado.
#     Você pode montar via -v ou criar uma imagem custom. A solução abaixo monta com -v.
#   - DNS interno só funciona em rede user-defined — você já criou a desafio-net.
#   - Pra testar o ping entre containers: docker exec -it desafio-nginx ping desafio-db

# ============================
# SUA SOLUÇÃO ABAIXO
# ============================

echo "TODO: criar a rede 'desafio-net'"
# docker network create ...

echo "TODO: subir o postgres (desafio-db) na rede, SEM -p, com senha"
# docker run -d --name desafio-db ...

echo "TODO: subir o adminer (desafio-adminer) na rede, SEM -p"
# docker run -d --name desafio-adminer ...

echo "TODO: criar um arquivo nginx.conf que faz proxy_pass pra http://desafio-adminer:8080"
# cat > nginx.conf <<EOF
# ...
# EOF

echo "TODO: subir o nginx (desafio-nginx) na rede, COM -p 8080:80, montando o nginx.conf"
# docker run -d --name desafio-nginx ...

echo "TODO: validar — do nginx, conseguir ping no desafio-db"
# docker exec desafio-nginx ...

# Verifique no navegador: http://localhost:8080
# Deve abrir a tela do Adminer. Conecte com:
#   System:   PostgreSQL
#   Server:   desafio-db
#   Username: postgres
#   Password: secret
#   Database: postgres

docker ps

# ============================
# SOLUÇÃO DE REFERÊNCIA (descomente pra rodar)
# ============================

: <<'SOLUTION'
# Limpeza prévia (caso tenha sobrado de uma tentativa anterior)
docker rm -f desafio-db desafio-adminer desafio-nginx 2>/dev/null || true
docker network rm desafio-net 2>/dev/null || true

# 1) Rede user-defined — ESSENCIAL pro DNS por nome funcionar
docker network create desafio-net

# 2) Postgres — sem -p, invisível pro host
docker run -d --name desafio-db \
  --network desafio-net \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=postgres \
  postgres:16

# 3) Adminer — sem -p, só o nginx (na mesma rede) vai falar com ele
docker run -d --name desafio-adminer \
  --network desafio-net \
  adminer:latest

# 4) Config do nginx fazendo proxy reverso pro adminer
cat > nginx.conf <<'EOF'
events {}
http {
    server {
        listen 80;

        location / {
            # Resolve 'desafio-adminer' via DNS interno da rede Docker
            proxy_pass http://desafio-adminer:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# 5) Nginx — única porta exposta pro host: 8080
docker run -d --name desafio-nginx \
  --network desafio-net \
  -p 8080:80 \
  -v "$(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro" \
  nginx:alpine

# 6) Validações
echo "--- nginx consegue resolver 'desafio-db'? ---"
docker exec desafio-nginx getent hosts desafio-db || \
  docker exec desafio-nginx sh -c "nslookup desafio-db 2>/dev/null || ping -c 1 desafio-db"

echo "--- adminer consegue falar com postgres pelo nome? ---"
docker exec desafio-adminer sh -c \
  "nc -zv desafio-db 5432 2>&1 || echo 'tente: telnet desafio-db 5432'"

echo ""
echo "Abra no navegador: http://localhost:8080"
echo "  System:   PostgreSQL"
echo "  Server:   desafio-db"
echo "  Username: postgres"
echo "  Password: secret"
echo "  Database: postgres"
echo ""
echo "Observe: do host NÃO conseguimos acessar postgres (5432) nem adminer (8080 do container)."
echo "Só o nginx tem ponte pro mundo de fora."

# 7) Pra limpar tudo depois:
# docker rm -f desafio-db desafio-adminer desafio-nginx
# docker network rm desafio-net
# rm nginx.conf
SOLUTION
